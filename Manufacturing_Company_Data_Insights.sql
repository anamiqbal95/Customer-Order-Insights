-- Final Assignment:

CREATE SCHEMA `Company_Database`;

CREATE TABLE `Company_Database`.`Region` (
    `region_id` INT NOT NULL,
    `region_name` VARCHAR(45) NOT NULL,
    `super_region_id` INT,
    PRIMARY KEY (region_id),
    FOREIGN KEY (super_region_id)
        REFERENCES Company_Database.Region (region_id)
        ON UPDATE NO ACTION ON DELETE CASCADE
);
  
INSERT INTO `Company_Database`.`Region`(`region_id`, `region_name`, `super_region_id`)
VALUES 
(101, 'North America', null),
(102, 'USA', 101),
(103,'Canada', 101),
(104, 'USA-Northeast', 102),
(105, 'USA-Southeast', 102),
(106, 'USA-West', 102),
(107, 'Mexico', 101);

CREATE TABLE `Company_Database`.`Product` (
    `product_id` INT NOT NULL,
    `product_name` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`product_id`)
);

INSERT INTO `Company_Database`.`Product`(`product_id`, `product_name`)
VALUES 
(1256, 'Gear - Large'),
(4437, 'Gear - Small'),
(5567, 'Crankshaft'),
(7684, 'Sprocket');

CREATE TABLE `Company_Database`.`Sales_Totals` (
    `product_id` INT NOT NULL,
    `region_id` INT NOT NULL,
    `year` INT NOT NULL,
    `month` INT NOT NULL,
    `sales` INT NOT NULL,
    PRIMARY KEY (`product_id` , `region_id` , `year` , `month`),
    FOREIGN KEY (product_id)
        REFERENCES Company_Database.Product (product_id)
        ON UPDATE NO ACTION ON DELETE CASCADE,
    FOREIGN KEY (region_id)
        REFERENCES Company_Database.Region (region_id)
        ON UPDATE NO ACTION ON DELETE CASCADE
);

INSERT INTO `Company_Database`.`Sales_Totals`(`product_id`,  `region_id`,  `year`, `month`, `sales`)
VALUES
(1256, 104, 2020, 1, 1000),
(4437, 105, 2020, 2, 1200),
(7684, 106, 2020, 3, 800),
(1256, 103, 2020, 4, 2200),
(4437, 107, 2020, 5, 1700),
(7684, 104, 2020, 6, 750),
(1256, 104, 2020, 7, 1100),
(4437, 105, 2020, 8, 1050),
(7684, 106, 2020, 9, 600),
(1256, 103, 2020, 10, 1900),
(4437, 107, 2020, 11, 1500),
(7684, 104, 2020, 12, 900);

-- 1: Write a CASE expression that can be used to return the quarter number (1, 2, 3, or 4) only based on the month.
SELECT 
    month,
    CASE
        WHEN month >= 1 AND month <= 3 THEN 1
        WHEN month >= 4 AND month <= 6 THEN 2
        WHEN month >= 7 AND month <= 9 THEN 3
        WHEN month >= 10 AND month <= 12 THEN 4
        ELSE 0
    END quarter_no
FROM
    `Company_Database`.`Sales_Totals`
ORDER BY month;

-- 2: Write a query which will pivot the Sales_Totals data so that there is a column for each of the 4
-- products containing the total sales across all months of 2020. 
SELECT 
    SUM(CASE
        WHEN product_id = 1256 THEN sales
        ELSE 0
    END) tot_sales_large_gears,
    SUM(CASE
        WHEN product_id = 4437 THEN sales
        ELSE 0
    END) tot_sales_small_gears,
    SUM(CASE
        WHEN product_id = 5567 THEN sales
        ELSE 0
    END) tot_sales_crankshafts,
    SUM(CASE
        WHEN product_id = 7684 THEN sales
        ELSE 0
    END) tot_sales_sprockets
FROM
    `Company_Database`.`Sales_Totals`;

-- 3:  Write a query that retrieves all columns from the Sales_Totals table, along with a column called
-- sales_rank which assigns a ranking to each row based on the value of the Sales column in descending
-- order.
SELECT *,
rank() over(order by sales desc) sales_rank
FROM `Company_Database`.`Sales_Totals`;

-- 4:  Write a query that retrieves all columns from the Sales_Totals table, along with a column called
-- product_sales_rank which assigns a ranking to each row based on the value of the Sales column in
-- descending order, with a separate set of rankings for each product.
SELECT *,
rank() over (partition by product_id order by sales desc) product_sales_rank
FROM `Company_Database`.`Sales_Totals`;

-- 5:  Expand on the query from question #4 by adding logic to return only those rows with a
-- product_sales_rank of 1 or 2.
SELECT *
FROM
(SELECT *,
rank() over (partition by product_id order by sales desc) product_sales_rank
FROM `Company_Database`.`Sales_Totals`) rank_num
WHERE rank_num.product_sales_rank = 1 or rank_num.product_sales_rank = 2;


-- 6: . Write a set of SQL statements which will add a row to the Region table for Europe, and then add a
-- row to the Sales_Total table for the Europe region and the Sprocket product (product_id = 7684) for
-- October 2020, with a sales total of $1,500.
START TRANSACTION;
INSERT INTO Company_Database.Region(region_id, region_name, super_region_id)
VALUES 
(108, 'Europe', null);
INSERT INTO Company_Database.Sales_Totals(product_id,  region_id,  year, month, sales)
VALUES
(7684, 108, 2020, 10, 1500);
SELECT 
    *
FROM
    Company_Database.Region;
SELECT 
    *
FROM
    Company_Database.Sales_Totals;
COMMIT;

-- 7:  Write a statement to create a view called Product_Sales_Totals which will group sales data by product
-- and year. 
CREATE OR REPLACE VIEW Product_Sales_Totals AS
    SELECT 
        product_id,
        year,
        CASE
            WHEN product_id = 1256 THEN SUM(sales)
            WHEN product_id = 4437 THEN SUM(sales)
            WHEN product_id = 5567 THEN SUM(sales)
            WHEN product_id = 7684 THEN SUM(sales)
        END product_sales,
        (CASE
            WHEN product_id = 1256 THEN SUM(sales)
            WHEN product_id = 4437 THEN SUM(sales)
            ELSE 0
        END) AS gear_sales
    FROM
        Company_Database.Sales_Totals
    GROUP BY product_id , year;
    
SELECT 
    *
FROM
    Product_Sales_Totals;

 
 -- 8:  Write a query to return all sales data for 2020, along with a column showing the percentage of sales
-- for each product. Columns should include product_id, region_id, month, sales, and pct_product_sales.
SELECT product_id, region_id, month, sales,
round((sum(sales) OVER (PARTITION BY (sales)))/ (sum(sales) over()) * 100,1) pct_product_sales
FROM  Company_Database.Sales_Totals
ORDER BY month;

-- 9:  Write a query to return the year, month, and sales columns, along with a 4th column named
-- prior_month_sales showing the sales from the prior month.
SELECT year, month, sum(sales) sales ,
LAG(sum(sales)) over(order by month asc) prior_month_sales
FROM Company_Database.Sales_Totals
GROUP BY (month);

-- 10:  If the tables used in this prompt are in the ‘sales’ database, write a query to retrieve the name and
-- type of each of the columns in the Product table. Please specify the 'sales' database in your answer.
SELECT 
    column_name, column_type
FROM
    information_schema.columns
WHERE
    table_schema = 'Company_Database'
        AND table_name = 'Product';
