# Case Study 1 - Danny's Diner
Danny's Diner is the 1st case sudy in the ['#8weeksSQLchallenge](https://8weeksqlchallenge.com) created by Danny Ma

## Introduction

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: *sushi, curry and ramen*.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:

* `sales`
* `menu`
* `members`
You can inspect the entity relationship diagram and example data below.

----------
[image](https://user-images.githubusercontent.com/24557310/196964165-67363a15-c588-4932-955f-a4990de785b4.png)
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://dbdiagram.io/embed/608d07e4b29a09603d12edbd
">
  <source media="(prefers-color-scheme: light)" srcset="https://dbdiagram.io/embed/608d07e4b29a09603d12edbd
">
  <img alt="The ER diagram of Danny's Diner." src="https://dbdiagram.io/embed/608d07e4b29a09603d12edbd
">
</picture>

## Datasets
All datasets exist within the dannys_diner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

### Table 1: sales
The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered

|customer_id|order_date|product_id|
|----------:|---------:|----------|
|A	        |2021-01-01|1         |
|A        	|2021-01-01|2         |
|A        	|2021-01-07|2         |
|A          |2021-01-10|3         |
|A        	|2021-01-11|3         |
|A        	|2021-01-11|3         |
|B        	|2021-01-01|2         |
|B        	|2021-01-02|2         |
|B        |2021-01-04  |1         |
|B        |2021-01-11  |1         |
|B        |2021-01-16  |3         |
|B        |2021-02-01  |3         |
|C        |2021-01-01  |3         |
|C        |2021-01-01  |3         |
|C        |2021-01-07  |3         |

### Table 2: menu
The `menu` table maps the `product_id` to the actual `product_name` and `price` of each menu item.

|product_id|	product_name|	price|
|----------|--------------|------|
|1	|sushi	|10|
|2	|curry	|15|
|3	|ramen	|12|


### Table 3: members

The final `members` table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

|customer_id	|join_date|
|------------|----------|
|A  |2021-01-07|
|B	|2021-01-09|

###                                                           Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:

1. What is the total amount each customer spent at the restaurant?

```MySQL
SELECT
	s.customer_id,
    SUM(price) AS total_amount_spent
  FROM sales as S
  JOIN menu
  ON s.product_id = menu.product_id
  GROUP BY customer_id;
```
and we got the table below as the total amount each customer spent at the restaurant

![total amount each customer spent at the restaurant](https://user-images.githubusercontent.com/24557310/197329054-0200ed96-1860-4458-ac75-0b5e9d42a46f.png)

2. How many days has each customer visited the restaurant?

```MySQL
SELECT 
	s.customer_id,
    count(distinct(order_date)) as no_of_days_visited
from sales as s
group by customer_id;
```

3. What was the first item from the menu purchased by each customer?
```MySQL
with ranked_purchase_cte as  
(select 
	s.customer_id,
    s.order_date,
    m.product_name,
	dense_rank() over(partition by s.customer_id 
    order by s.order_date) as ranking
from sales as s join menu as m
on s.product_id = m.product_id)
## ...then select the 1st orders i.e orders with rank = 1
select customer_id, product_name, ranking
from ranked_purchase_cte
where ranking  = 1 
group by customer_id
;
```
...or we could try another approach to this question, either way we'll be getting similar result
```MySQL
select s.customer_id, m.product_name
from sales as s 
join menu as m
on s.product_id = m.product_id
where order_date = (select order_date
from sales
order by s.customer_id
limit 1
);
```
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```MySQL
select m.product_name, count(s.product_id) as product_count 
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_id
order by count(s.product_id) DESC
LIMIT 1 ;
```
Another method for the 4th question

```MySQL
SELECT product_name, max(product_count)
from (select m.product_name, count(s.product_id) as product_count 
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_id) AS derived;
```

5. Which item was the most popular for each customer?
```MySQL
with popularity_cte as (
select s.customer_id,
	m.product_name,
	count(s.product_id) as order_count
from sales as s
join menu as m
on s.product_id = m.product_id
group by s.customer_id, s.product_id
order by order_count desc, customer_id desc)

select customer_id, 
	max(order_count),
	product_name,
	order_count
from popularity_cte
group by customer_id;

```

6. Which item was purchased first by the customer after they became a member?
```MySQL
SELECT sales.customer_id, 
	sales.order_date,
	menu.product_name
FROM sales
JOIN menu 
ON sales.product_id = menu.product_id
JOIN members 
ON members.customer_id = sales.customer_id
WHERE sales.order_date >= members.join_date
GROUP BY customer_id
ORDER BY customer_id,order_date
;

```
7. Which item was purchased just before the customer became a member?
```MySQL
SELECT sales.customer_id, 
	sales.order_date,
	menu.product_name
FROM sales
JOIN menu 
ON sales.product_id = menu.product_id
JOIN members 
ON members.customer_id = sales.customer_id
WHERE sales.order_date < members.join_date
GROUP BY customer_id
ORDER BY order_date
;

```
8. What is the total items and amount spent for each member before they became a member?
```MySQL
SELECT 
    s.customer_id,
    COUNT(s.product_id) AS items,
    SUM(m.price) AS amount_spent
FROM
    sales AS s
        JOIN
    menu AS m ON s.product_id = m.product_id
        JOIN
    members ON members.customer_id = s.customer_id
WHERE
    s.order_date < members.join_date
GROUP BY s.customer_id
;

```
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```MySQL
select s.customer_id, 
	sum(points_table.price),
	sum(points_table.points)
from sales as s
join 
(select * , 
	case when m.product_name = 'sushi' 
    then m.price*2*10
    else m.price*10 
    end as points
from menu as m) as points_table
on s.product_id = points_table.product_id
group by s.customer_id
;
```
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```MySQL
select s.customer_id,
	s.order_date
from sales as s
join members as m
where s.order_date between m.join_date and date_add(m.join_date, interval 6 day)
and s.customer_id in (select m.customer_id from members as m )
;

-- then
with promo_cte as (
select s.*,
	m.join_date,
    date_add(m.join_date, interval 6 day) as 1st_wk,
	last_day('2021-01-01') as end_of_january,
    menu.product_name,
    menu.price,
    case when menu.product_name = 'sushi' 
    then menu.price*2*10
    when s.order_date between m.join_date and date_add(m.join_date, interval 6 day)
    then menu.price*2*10
    else menu.price*10 
    end as promo_points
from sales as s
join members as m
on s.customer_id = m.customer_id
join menu
on s.product_id = menu.product_id
where s.order_date <= last_day('2021-01-01') 
and s.customer_id in (select m.customer_id from members as m )
)
select customer_id, 
	sum(promo_points) as total_member_points
from promo_cte
group by customer_id 
;

```

### Bonus Question
A. ####Join All The Things
From the data given so far, create a tablethat'll have the columns:
* `customer_id`
* `order_date`
* `product_name`
* `price`
* `member`

```MySQL
SELECT s.customer_id,
	s.order_date,
    m.product_name,
    m.price,
    CASE WHEN s.order_date >= mem.join_date
    THEN 'Y'
    ELSE 'N'
    END AS membership
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members as mem
ON s.customer_id = mem.customer_id;

```

B. #### Rank All The Things
Danny also requires further information about the `ranking` of customer products, but he purposely does not need the `ranking` for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```MySQL
with cust_prod_ranking as 
(SELECT s.customer_id,
	s.order_date,
    m.product_name,
    m.price,
    CASE WHEN s.order_date >= mem.join_date
    THEN 'Y'
    ELSE 'N'
    END AS membership
FROM sales AS s
LEFT JOIN menu AS m
ON s.product_id = m.product_id
LEFT JOIN members as mem
ON s.customer_id = mem.customer_id)

select cust_prod_ranking.*,
	case when membership = 'Y'
    then DENSE_RANK() over (partition by customer_id, membership order by order_date)
    else null
    end as ranking
from cust_prod_ranking;
```
