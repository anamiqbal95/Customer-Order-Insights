#Extracting insights from customer order data

CREATE SCHEMA `Prompt2_Database`;

CREATE TABLE `prompt2_database`.`Customer_Order` (
    `order_num` INT NOT NULL,
    `cust_id` INT NOT NULL,
    `order_date` CHAR(10)
);

INSERT INTO `prompt2_database`.`Customer_Order` (`order_num`, `cust_id`, `order_date`)
VALUES 
(1, 121, '01-15-2019'),
(2, 234, '07-24-2019'),
(3, 336, '05-02-2020'),
(4, 121, '01-15-2019'),
(5, 336, '03-19-2020'),
(6, 234, '07-24-2019'),
(7, 121, '01-15-2019'),
(8, 336, '06-12-2020');

-- Retrieving each unique customer ID (cust_id) from the Customer_Order table 
SELECT DISTINCT
    cust_id
FROM
    prompt2_database.customer_order;

-- Retrieving each unique customer ID (cust_id) along with the latest order date for each customer
SELECT 
    cust_id, MAX(order_date)
FROM
    prompt2_database.customer_order
GROUP BY cust_id
ORDER BY MAX(order_date);

-- Retrieving all rows and columns from the Customer_Order table, with the results sorted by order date descending (latest date first) and then by customer ID ascending
SELECT 
    *
FROM
    prompt2_database.customer_order c
ORDER BY c.order_date DESC , c.cust_id ASC;

-- Retrieving each unique customer (cust_id) whose lowest order number (order_num) is at least 3
SELECT 
    cust_id
FROM
    prompt2_database.customer_order c
GROUP BY cust_id
HAVING MIN(order_num) >= 3
;

-- Retrieving only those customers who had 2 or more orders on the same day
SELECT 
    cust_id, order_date, COUNT(order_num)
FROM
    prompt2_database.customer_order
GROUP BY order_date
HAVING COUNT(order_num) >= 2;

-- Along with the Customer_Order table, there is another Customer table below. Write a query that returns the name of each customer who has placed exactly 3 orders
CREATE TABLE `prompt2_database`.`Customer` (
    `cust_id` INT NOT NULL,
    `cust_name` VARCHAR(45) NOT NULL
);

INSERT INTO `prompt2_database`.`Customer`(`cust_id` , `cust_name`)
VALUES
(121, 'Acme Wholesalers'),
(234, 'Griffin Electric'),
(336, 'East Coast Marine Supplies'),
(544, 'Sanford Automotive');

SELECT 
    cust_name
FROM
    prompt2_database.customer c
WHERE
    EXISTS( SELECT 
            cust_id
        FROM
            prompt2_database.customer_order co
        WHERE
            co.cust_id = c.cust_id
        HAVING COUNT(co.cust_id) = 3);

-- Returning the same data as the previous question (name of each customer who has placed exactly 3 orders), but using a non-correlated subquery against the Customer_Order table
SELECT 
    cust_name
FROM
    prompt2_database.customer c
WHERE
    cust_id IN (SELECT 
            cust_id
        FROM
            prompt2_database.customer_order co
        GROUP BY (co.cust_id)
        HAVING COUNT(co.cust_id) = 3);

-- Returning the name of each customer, along with the total number of orders for each customer
SELECT 
    c.cust_name,
    (SELECT 
            COUNT(co.cust_id)
        FROM
            prompt2_database.customer_order co
        WHERE
            co.cust_id = c.cust_id) AS total_number_of_orders
FROM
    prompt2_database.customer c
;