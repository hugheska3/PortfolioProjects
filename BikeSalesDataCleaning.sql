SELECT * FROM BikeSalesData;

-- This data needs to be cleaned

-- dealing with missing values

-- Found that the day was null on an order where the date included the day
SELECT * FROM BikeSalesData 
WHERE Day IS NULL;

UPDATE BikeSalesData
SET Day= 5
WHERE Day IS NULL;

-- Found a null value for order_quantity, matched the order quantity to an order with the same mountain bike with the same prices

SELECT * FROM BikeSalesData 
WHERE Order_Quantity IS NULL;

SELECT * FROM BikeSalesData 
WHERE Product_Description= 'Mountain-500 Black, 42';


UPDATE BikeSalesData
SET Order_Quantity= 1
WHERE Sales_Order= 261716;

-- Update the cost and revenue of orders

SELECT * FROM BikeSalesData
WHERE Unit_Price= 0.00 OR Unit_Cost= 0.00;

SELECT * FROM BikeSalesData WHERE Product_Description = 'Mountain-200 Black, 46'

UPDATE BikeSalesData
SET Unit_Cost= 1252.00
WHERE Product_Description = 'Mountain-200 Black, 46';

SELECT * FROM BikeSalesData
WHERE Unit_Price= 0.00 OR Unit_Cost= 0.00;

SELECT * FROM BikeSalesData WHERE Product_Description = 'Mountain-400-W Silver, 42';

UPDATE BikeSalesData
SET Unit_Price= 769.00
WHERE Product_Description = 'Mountain-400-W Silver, 42';

-- Finding the correct costs (Total costs) of the bikes sold and creating a new column for that data

SELECT Order_Quantity, Unit_Cost, Unit_Price, Profit, Cost, Revenue, (Order_Quantity * Unit_Cost) AS Total_Cost
FROM BikeSalesData;

ALTER TABLE BikeSalesData
ADD Total_Cost money;

UPDATE BikeSalesData
SET Total_Cost= (Order_Quantity * Unit_Cost);

SELECT * FROM BikeSalesData;

--Finding the correct revenue (Total revenue) of the bikes sold and creating a new column for that data

SELECT Order_Quantity, Unit_Cost, Unit_Price, Profit, Total_Cost, Revenue, (Profit + Total_Cost) AS Total_Revenue
FROM BikeSalesData;

ALTER TABLE BikeSalesData
ADD Total_Revenue money;

UPDATE BikeSalesData
SET Total_Revenue= (Profit + Total_Cost);

SELECT * FROM BikeSalesData;

-- Deleting the Cost and Revenue Columns to be replaced by the new total cost and total revenue/ deleting unused columns

ALTER TABLE BikeSalesData
DROP COLUMN	Cost, Revenue;

SELECT * FROM BikeSalesData;

-- Correcting the Age Group column to have a consistent data type

SELECT Customer_Age, Age_Group,
	CASE 
		WHEN Customer_Age < 25 THEN 'Youth'
		WHEN Customer_Age>= 25 AND Customer_Age <=34 THEN 'Young Adults'
		WHEN Customer_Age>= 35 AND Customer_Age<=64 THEN 'Adults'
		ELSE Age_Group
	END AS Age_Group
FROM BikeSalesData;

UPDATE BikeSalesData
SET Age_Group = CASE 
		WHEN Customer_Age < 25 THEN 'Youth'
		WHEN Customer_Age>= 25 AND Customer_Age <=34 THEN 'Young Adults'
		WHEN Customer_Age>= 35 AND Customer_Age<=64 THEN 'Adults'
		ELSE Age_Group
	END;

SELECT * FROM BikeSalesData;

-- Repeat Sales_Order numbers

SELECT Sales_Order, COUNT(*)
FROM  BikeSalesData
GROUP BY Sales_Order
HAVING COUNT(*) >1;

SELECT *
FROM BikeSalesData
WHERE Sales_Order= 261695 OR Sales_Order= 261701;


-- Updating the Sales_Order number for rows that had different data but the same sales_order number

UPDATE BikeSalesData
SET Sales_Order= 261696
WHERE Sales_Order= 261695 AND State= 'California';

-- Deleting the duplicate row using CTE and ROW_NUMBER

SELECT Sales_Order, COUNT(*)
FROM  BikeSalesData
GROUP BY Sales_Order
HAVING COUNT(*) >1;

SELECT * FROM BikeSalesData WHERE Sales_Order= 261701;


SELECT 
	Sales_Order,
	Date,
	State, 
	Product_Description,
	ROW_NUMBER() OVER(
		PARTITION BY Sales_Order
		ORDER BY Sales_Order
		) row_num 
		FROM 
		BikeSalesData
		ORDER BY Sales_Order;


WITH CTE AS
(SELECT 
	Sales_Order,
	Date,
	State, 
	Product_Description,
	ROW_NUMBER() OVER(
		PARTITION BY Sales_Order
		ORDER BY Sales_Order
		) row_num 
		FROM 
		BikeSalesData)
	DELETE FROM CTE WHERE row_num> 1;


