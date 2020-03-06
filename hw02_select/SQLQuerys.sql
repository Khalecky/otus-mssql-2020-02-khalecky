--¬се товары, в которых в название есть пометка urgent или название начинаетс€ с Animal
SELECT * FROM Warehouse.StockItems WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'animal%';

--ѕоставщиков, у которых не было сделано ни одного заказа
select s.SupplierID, s.SupplierName, o.PurchaseOrderID  from Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders o ON o.SupplierID=s.SupplierID 
WHERE o.SupplierID IS NULL;

--ѕродажи с названием мес€ца
SELECT DISTINCT o.OrderID, o.OrderDate, DATENAME(m, o.OrderDate) OrderMonth,
	(DatePart(q, o.OrderDate)) OrderQuart,
	((MONTH(o.OrderDate) -1)/4 + 1) OrderThird
FROM Sales.Orders o
INNER JOIN Sales.OrderLines l ON l.OrderID = o.OrderID
WHERE (l.UnitPrice > 100 OR l.Quantity > 20) AND o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuart, OrderThird, o.OrderDate;

--ѕродажи постраничные
SELECT DISTINCT o.OrderID, o.OrderDate, DATENAME(m, o.OrderDate) OrderMonth,
	(DatePart(q, o.OrderDate)) OrderQuart,
	((MONTH(o.OrderDate) -1)/4 + 1) OrderThird
FROM Sales.Orders o
INNER JOIN Sales.OrderLines l ON l.OrderID = o.OrderID
WHERE (l.UnitPrice > 100 OR l.Quantity > 20) AND o.PickingCompletedWhen IS NOT NULL
ORDER BY OrderQuart, OrderThird, o.OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;

-- «аказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post
select po.*, s.SupplierName, p.FullName ContactName
from Purchasing.PurchaseOrders po
left join Purchasing.Suppliers s on s.SupplierID=po.SupplierID
left join Application.DeliveryMethods m on m.DeliveryMethodID=po.DeliveryMethodID
left join Application.People p on p.PersonID=po.ContactPersonID 
where 
	IsOrderFinalized=1
	and m.DeliveryMethodName in ('Road Freight', 'Post')
	and po.OrderDate >= '2014-01-01' and po.OrderDate < '2015-01-01'

--10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ
select top 10 o.*, c.CustomerName, p.FullName StaffName
from Sales.Orders o
left join Sales.Customers c on o.CustomerID=c.CustomerID
left join Application.People p on p.PersonID=o.SalespersonPersonID
order by o.OrderDate desc

--¬се ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
select distinct c.CustomerID, c.CustomerName, c.PhoneNumber
from Sales.Customers c
inner join Sales.Orders o on o.CustomerID=c.CustomerID
left join Sales.OrderLines ol on ol.OrderID=o.OrderID
left join Warehouse.StockItems items on items.StockItemID=ol.StockItemID
where items.StockItemName = 'Chocolate frogs 250g'
order by c.CustomerID









