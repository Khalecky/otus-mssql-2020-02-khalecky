
--1. ¬ыберите сотрудников, которые €вл€ютс€ продажниками, и еще не сделали ни одной продажи
select * from Application.People
where 
	People.IsSalesperson = 1 and 
	NOT EXISTS (select * from Sales.Invoices as I where People.PersonID=I.SalespersonPersonID);

--2. ¬ыберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса
select * from Warehouse.StockItems where UnitPrice <= ALL(select UnitPrice from Warehouse.StockItems);
select * from Warehouse.StockItems where UnitPrice = (select MIN(UnitPrice) from Warehouse.StockItems);

--3.¬ыберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
-- 3.1
with CustomersMaxAmount as
(
	select distinct CT.CustomerID from Sales.CustomerTransactions CT 
	left join (
		--5 различных максимальных платежей
		select distinct top 5  TransactionAmount 
		from Sales.CustomerTransactions order by TransactionAmount desc
	) as MT 
		on MT.TransactionAmount=CT.TransactionAmount
	where MT.TransactionAmount is not null
)
select * from Sales.Customers as C where exists(select * from CustomersMaxAmount where CustomerID=C.CustomerID);

--3.2
with 
--минимальный порог TransactionAmount
MinAmount as
(
	select distinct TransactionAmount 
	from Sales.CustomerTransactions 
	order by TransactionAmount desc
	offset 4 rows fetch next 1 rows only
),
--список CustomerID, дл€ которых TransactionAmount >= минимального порога
CustomersMaxAmount as
(
	select distinct CT.CustomerID from Sales.CustomerTransactions as CT
	where CT.TransactionAmount >= (select * from MinAmount)
)
select * from Sales.Customers where CustomerID in (select * from CustomersMaxAmount);

--3.3
SELECT c.CustomerName, ct.TransactionAmount 
FROM Sales.CustomerTransactions AS ct  
JOIN Sales.Customers c ON c.CustomerID = ct.CustomerID 
WHERE ct.TransactionAmount IN ( SELECT TOP 5 t.TransactionAmount FROM Sales.CustomerTransactions t ORDER BY TransactionAmount DESC);

--4.¬ыберите города (ид и название), в которые были доставлены товары, вход€щие в тройку самых дорогих товаров, а также »м€ сотрудника, который осуществл€л упаковку заказов
with 
ExpensiveItems as
(
	select top 3 * from Warehouse.StockItems
	order by UnitPrice desc	
),
ExpensiveOrders as
(
	select O.* from Sales.Orders as O
	inner join Sales.OrderLines as OL on OL.OrderID = O.OrderID
	where exists(select * from ExpensiveItems as EI where EI.StockItemID = OL.StockItemID) 
)
select Cities.CityID, Cities.CityName, P.FullName as PickPersonName
from Sales.Customers as C
inner join Sales.Orders as O on O.CustomerID=C.CustomerID
left join Application.Cities as Cities on Cities.CityID=C.DeliveryCityID
left join Application.People as P on P.PersonID=O.PickedByPersonID
where exists(select * from ExpensiveOrders as EO where EO.OrderID=O.OrderID);

--5. ќптимизаци€ запроса
-- „то делает запрос - получение данных Invoice собранных заказов
-- ќптимизировал с точки зрени€ читабельности кода
WITH SalesTotal AS
(
	SELECT InvoiceID AS InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines	GROUP BY InvoiceId --HAVING TotalSumm > 27000
),
CompletedOrders AS
(
	SELECT Orders.OrderId AS OrderId FROM Sales.Orders WHERE Orders.PickingCompletedWhen IS NOT NULL
),
TotalOrderPickedItems AS
(
	SELECT OrderLines.OrderId AS OrderId, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) AS Total FROM Sales.OrderLines
	WHERE exists(SELECT * FROM CompletedOrders WHERE OrderId = OrderLines.OrderId)
	GROUP BY OrderLines.OrderId
)
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName FROM Application.People WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName,
	ST.TotalSumm AS TotalSummByInvoice,
	(SELECT Total FROM TotalOrderPickedItems WHERE OrderId = Invoices.OrderId) AS TotalSummForPickedItems
FROM Sales.Invoices 
JOIN SalesTotal AS ST ON Invoices.InvoiceID = ST.InvoiceID AND ST.TotalSumm > 27000
ORDER BY ST.TotalSumm DESC
