--��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
SELECT * FROM Warehouse.StockItems WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'animal%';

--�����������, � ������� �� ���� ������� �� ������ ������
select s.SupplierID, s.SupplierName, o.PurchaseOrderID  from Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders o ON o.SupplierID=s.SupplierID 
WHERE o.SupplierID IS NULL;

--������� � ��������� ������
SELECT o.OrderID, DATENAME(m, o.OrderDate) OrderMonth,
	((MONTH(o.OrderDate) - 1)/3 + 1) OrderQuart ,
	((MONTH(o.OrderDate) -1)/4 + 1) OrderThird
FROM Sales.Orders o
INNER JOIN Sales.OrderLines l ON l.OrderID = o.OrderID
WHERE (l.UnitPrice > 100 OR l.Quantity > 20) AND NOT o.PickingCompletedWhen IS NULL
GROUP BY o.OrderID, o.OrderDate
ORDER BY OrderQuart, OrderThird, o.OrderDate

--������� ������������
SELECT o.OrderID, DATENAME(m, o.OrderDate) OrderMonth,
	((MONTH(o.OrderDate) - 1)/3 + 1) OrderQuart ,
	((MONTH(o.OrderDate) -1)/4 + 1) OrderThird
FROM Sales.Orders o
INNER JOIN Sales.OrderLines l ON l.OrderID = o.OrderID
WHERE (l.UnitPrice > 100 OR l.Quantity > 20) AND NOT o.PickingCompletedWhen IS NULL
GROUP BY o.OrderID, o.OrderDate
ORDER BY OrderQuart, OrderThird, o.OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY

-- ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post
select po.*, s.SupplierName, p.FullName
from Purchasing.PurchaseOrders po
left join Purchasing.Suppliers s on s.SupplierID=po.SupplierID
left join Application.DeliveryMethods m on m.DeliveryMethodID=po.DeliveryMethodID
left join Application.People p on p.PersonID=po.ContactPersonID 
where 
	IsOrderFinalized=1
	and (m.DeliveryMethodName like 'Road Freight' or m.DeliveryMethodName like 'Post')
	and YEAR(po.OrderDate)=2014

--10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����
select top 10 o.*, c.CustomerName, p.FullName StaffName
from Sales.Orders o
left join Sales.Customers c on o.CustomerID=c.CustomerID
left join Application.People p on p.PersonID=o.SalespersonPersonID
order by o.OrderDate desc

--��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g
select distinct c.CustomerID, c.CustomerName, c.PhoneNumber
from Sales.Customers c
inner join Sales.Orders o on o.CustomerID=c.CustomerID
left join Sales.OrderLines ol on ol.OrderID=o.OrderID
left join Warehouse.StockItems items on items.StockItemID=ol.StockItemID
where items.StockItemName like 'Chocolate frogs 250g'
order by c.CustomerID









