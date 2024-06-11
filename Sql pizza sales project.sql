use pizzahut_project;
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;

#retrieve  the total number of order placed
select count(order_id)  as "total number of orders" from orders;
#.pizza_id,o.quantity,p.price
#calculate the total revenue generated from the pizza sales
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS 'total sales'
FROM
    order_details o
        INNER JOIN
    pizzas p ON o.pizza_id = p.pizza_id;

#identify the highest priced pizaa    
SELECT 
    pizzatype.name, pizza.price
FROM
    pizza_types pizzatype
        INNER JOIN
    pizzas pizza ON pizzatype.pizza_type_id = pizza.pizza_type_id
ORDER BY pizza.price DESC
LIMIT 1;


#identify the most common pizza size ordered
SELECT 
    *
FROM
    pizza_types;
SELECT 
    *
FROM
    pizzas;
SELECT 
    size, COUNT(size) AS 'no of orders'
FROM
    pizzas
GROUP BY size
ORDER BY 'no of orders'
LIMIT 1;

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS 'total'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY 'total' DESC
LIMIT 5
;

#Join the necessary tables to find the total quantity of each pizza categorry ordered

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) 'total orders'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY 'total orders';



#determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS 'hrs', COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time);


#group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS 'quantity'
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


#join the relevant tables to find the category wise distribution of pizzas
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


#determine top 3 most ordered pizzas based on the revenve
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS 'revenue'
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


#calculate the percentage contribution of each pizza type to total revemue
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;






#analyze the cummalative revenue generated over time

select order_date,sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue from orders
join order_details
on orders.order_id=order_details.order_id
join pizzas
on pizzas.pizza_id=order_details.pizza_id
group by orders.order_date) as sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from orders;
select * from order_details;
select * from pizza_types;
select * from pizzas;
select name,revenue
from
(select category,name,revenue,
rank() over(partition by category order by revenue) as "rn"
from
(select pizza_types.category,pizza_types.name,sum(order_details.quantity*pizzas.price) as "revenue"
from pizzas
join order_details
on pizzas.pizza_id=order_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.category,pizza_types.name
order by pizza_types.category) as a) as b
where rn<=3;

select