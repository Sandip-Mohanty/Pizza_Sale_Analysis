-- Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_order
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
round(sum(orders_details.quantity*pizzas.price),2) AS total_revenue
FROM orders_details 
JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT ps.pizza_id , pt.name, ps.price
FROM pizza_types AS pt
JOIN pizzas AS ps
ON pt.pizza_type_id = ps.pizza_type_id
ORDER BY ps.price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pz.size, COUNT(od.quantity) AS Count_of_Pizza
FROM orders_details AS od
JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
GROUP BY pz.size
ORDER BY Count_of_Pizza DESC ;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name, COUNT(od.quantity) AS Quantity
FROM pizza_types AS pt
JOIN pizzas AS ps 
ON pt.pizza_type_id = ps.pizza_type_id
JOIN orders_details AS od
ON od.pizza_id = ps.pizza_id
GROUP BY pt.name
ORDER BY Quantity DESC LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pt.category AS Category,  SUM(od.quantity) AS Quantity
FROM orders_details AS od
JOIN pizzas AS ps
ON od.pizza_id = ps.pizza_id
JOIN pizza_types AS pt
ON ps.pizza_type_id = pt.pizza_type_id
GROUP BY pt.Category
ORDER BY Quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS Order_Hour,
COUNT(order_id) AS Total_Order
FROM orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) 
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(qnty),0) AS Avg_quantity_per_day FROM
(SELECT orders.order_date, 
SUM(orders_details.quantity) AS qnty
FROM orders
JOIN orders_details
ON orders.order_id = orders_details.order_id
GROUP BY order_date) AS Sum_quantity_per_day ;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, 
SUM(orders_details.quantity*pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY revenue DESC
LIMIT 3 ;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
CONCAT(ROUND(SUM(orders_details.quantity*pizzas.price)/
(SELECT SUM(orders_details.quantity*pizzas.price)
FROM orders_details
JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id)*100,2),'%') AS pecentage_of_contribution
FROM orders_details
JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.
SELECT order_date, ROUND(SUM(revenue) OVER (ORDER BY order_date),2) AS cumulative_revenue
FROM (SELECT orders.order_date,
SUM(orders_details.quantity*pizzas.price) AS revenue
FROM orders
JOIN orders_details
ON orders.order_id = orders_details.order_id
JOIN pizzas 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name,revenue from
(SELECT category,name,revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS RANK_
FROM
(SELECT pizza_types.category, pizza_types.name, 
SUM(orders_details.quantity*pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS cnr)cnr1
WHERE RANK_<=3;
