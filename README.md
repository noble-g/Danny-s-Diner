# Case Study 1 - Danny's Diner
Danny's Diner is the 1st case sudy in the ['#8weeksSQLchallenge](https://8weeksqlchallenge.com) created by Danny Ma

## Introduction

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: *sushi, curry and ramen*.

Danny’s Diner is in need of my assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided me with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for me to write fully functioning SQL queries to help him answer his questions!

Danny has shared with me 3 key datasets for this case study:

* `sales`
* `menu`
* `members`
The entity relationship diagram and example data are abelow.

----------
![ER Diagram of Danny's Diner](https://github.com/noble-g/Danny-s-Diner/blob/main/ER%20scrnsht.png)
<!--<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/noble-g/Danny-s-Diner/blob/main/ER%20scrnsht.png
">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/noble-g/Danny-s-Diner/blob/main/ER%20scrnsht.png
">
  <img alt="The ER diagram of Danny's Diner." src="https://github.com/noble-g/Danny-s-Diner/blob/main/ER%20scrnsht.png
">
</picture>-->

## Datasets
All datasets exist within the dannys_diner database schema

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

###                                                           Case Study Question

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
we used the `SUM(price)` to obtain the total amount spent at the restaurant and we grouped by `customer_id` using the line `GROUP BY customer_id` in the code above to obtain the `total_amount_spent` for *each customer*. And of course, `AS` was used to give the total column a befitting alias - `total_amount_spent`
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
We used the function `count(distinct(order_date))` to count the unique `order_date` that the customers have visited the restaurant. We then obtained for *each* customer by using the `group by customer_id` statement and thus, the following table was obtained

![number of days visited](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%202.png)

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
To know the 1st item purchased by each customer from the menu without hardcoding it, we first need to rank the orders for each customer and that's what we have done in the common table expression (CTE) with the dense_rank() function where we `order by order_date` and `partition by customer_id` while aliasing the dense_rank() as `ranking` and the CTE as `ranked_purchase_cte`. you can check out [here](https://mode.com/blog/use-common-table-expressions-to-keep-your-sql-clean/) and [here](https://towardsdatascience.com/how-to-use-sql-rank-and-dense-rank-functions-7c3ebf84b4e8) to know more about [CTE](https://mode.com/blog/use-common-table-expressions-to-keep-your-sql-clean/) and [dense rank](https://towardsdatascience.com/how-to-use-sql-rank-and-dense-rank-functions-7c3ebf84b4e8) respectively
Since our interest is in the first item purchased by each customer from the menu, we selected the needed columns `where ranking = 1` while grouping by `customer_id`

There are many ways to kill a rat or so they say, we could try another approach to this question. infact, a much simpler approach. Either way we'll be getting the same result

```MySQL
select s.customer_id, m.product_name
from sales as s 
join menu as m
on s.product_id = m.product_id
where order_date = (select order_date
from sales
order by s.customer_id
limit 1
)
group by s.customer_id;
```
Here, we used a subquery to obtain the first date from the sales table and then filter the `order date` by the first row of the subquery result which was obtained by using the snippet `limit = 1` in the subquery. Then, we `group by s.customer_id` to obtain the first order in the first day for each customer since there are more than one order for each customer on the first day   

![First item purchased by each customer](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%203.png)     

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

to obtain the most purchased item on the menu, we first need to join the concerned tables i.e the sales table and the menu table (PS: default `join` in SQL is the inner join.) Then, we `select count(s.product_id) as product_count` and order by the count function in descending order before limiting our result to the first row which is the *most purchased item on the menu* 
Another method for the 4th question

```MySQL
SELECT product_name, max(product_count)
from (select m.product_name, count(s.product_id) as product_count 
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_id) AS derived;
```
Here, we used the max() function to obtain the product in the menu with maximum count after which we had written a subquery - __derived__ whichh basically selects the products and their respective counts.   
![Most purchased item on the menu](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%204.png)

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
Before jumping into the coding aspect, we first need to understand the question.
the question says *Which item was the most popular for each customer*, key-phrases are *most popular* and *each customer* 
most poular item for each customer - that is, item each customer bought the most (i.e: product with highest count for each customer).
After understanding the question, we proceeded to create a Common Table Expression (CTE) called popularity_cte, the `popularity_cte` used the count() function on `product_id` to count all products and alias it as `order_count` then it grouped the count by customer and product, and ordered by count and customer.   
the popularity_cte will result in this table below:

![most popular item for each customer](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/5a.png)

Thus from the popularity_cte, we select the maximum count using the max() function and other important attributes like the `customer_id`, `product_name` and `order_count`, we then further on to `group by customer_id` and the resulting and final table looks like this   
![most popular item for each customer](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%205.png)   

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
Quite tricky a question, It is tricky because we need to answer these questions before we can proceed:
* are all customers members?
* if not, which of the customers are members and which are not?
* when did each member gain membership?
* which items were purchased after they gained membership?
* and lastly, which items was  purchased first immediately after they gained membership?   

This question exhausts all the tables in the database - sales, menu and members table.  To answer the implicit questions, we filtered the query by the where statement `WHERE sales.order_date >= members.join_date` with the assumption that the customers joined members before ordering on the day they joined, therefore the `>=` filter. The `group by` statement was used to limit all the items bought by each members on the day they joined to the very first product purchased that very day i.e the item that was purchased first immediately after they gained membership.   

![1^st^ purchase](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%206.png)   

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
Similar to the last analysis and just as tricky, we are to obtain the very last product bought by each member as an ordinary customer before they joined. And that explains our usage of `<` in the filter statement `WHERE sales.order_date < members.join_date`.

 ![purchase before joining](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%207.png)

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
the phrase *for each member* indicates we should group by customer_id after inner joining the requred tables. We applied the functions `count()` on `product_id` and `sum()` on `price`to obtain the total number of items and total amount respectively after which we joined all the tables in the schema   
![Total amount spent before joining](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%208.png)

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
A tricky one, imust confess.
$1 = 10 points but sushi  = 2*$1 = $2
therefore, from the menu table we  will create query that will look something like this:

|product_name|price|points|
|------------|----:|-----:|
|Sushi|10|10*$2 = $20 | 
|Curry|15|15*$1 = $15|
|Ramen|12|12*$1 =$12|

and thats what we have done in the subwuery we aliased as *points_table*
we then join the sales table with points_table (the newly created subquery). After which we selected `sum(points_table.points)` and `sum(points_table.price)` for every customer. that is `group by s.customer_id`.
The resulting table below is basically teling us the total points and total price for each customer's transaction history.

![points per $](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/no%209.png)   

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


Condition: In the first week of membership- members get 2X points, others get 1X poits while still upholding the earlier condition ($1 = 10 points but sushi  = 2*$1 = $2) in the question above (question 9).     

The first week constraint make this analysis a bit more complicated than expected, therefore we find the date and duration of the first week for every member as all members did not gain membership on the same day. So, we used the `date_add()` function on `members.join_date` and used 6 days interval and join date as the 7th day which makes the week as the question clearly stated that *...including their join date...*.
```MySQL
select 
	m.customer_id,
	m.join_date,
	date_add(m.join_date, interval 6 day) 
from sales as s
join members as m
group by m.customer_id;
```
![first week start and end date](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/10%20a.png)   The table above shows us the only two customers who are members and their respective start and end date for the first week where the join date = the start of the week.


```MySQL
select s.customer_id,
	s.order_date
from sales as s
join members as m
where s.order_date between m.join_date and date_add(m.join_date, interval 6 day)
and s.customer_id in (select m.customer_id from members as m )
;
```
Having obtained the first week's start and end date for every member, we wrote a query to obtain the order dates that fall in between the first week of membership filtering with the snippet `where s.order_date between m.join_date and date_add(m.join_date, interval 6 day)
and s.customer_id in (select m.customer_id from members as m )` .
the subquery in the snippet was used to obtain `customer_id` from the table `members`   
![order dates in the first week](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/10b.png)


Having done all these, we have to calculate points for just the month of January, so we went ahead to write a CTE- promo_cte which obtained features from the sales table, members `join_date`, `date_add(m.join_date, interval 6 day)` as `1st_wk`, `end_of_january`, `product_name`, `price`, and `promo points` which was computed with the help of case when statement.
We then used the promo_cte to compute the `total_member_points`

```SQL
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

![total_member_points](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/10c.png)    

### Bonus Question
A. ####Join All The Things
From the data given so far, create a table that'll have the columns:
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
the table below does not only gives us a comprehensive list of all orders, it also shows the customer ordering it, the product that was ordered, the order date, price of the product ordered, and finally whether the customer mking the order is a member or not, indicating membership wiht *Y* and otherwise with *N*   

![Join All Things](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/bonus%201.png)

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
Danny likes stressing the hell out of us :laugh: :laugh: :laugh: So, in addition to the bonus question A analyzed above, we helped Danny with the ranking of members-only using `case when` statement and `dense_rank` function

![Rank All Things](https://github.com/noble-g/Danny-s-Diner/blob/main/wk1%20-%20Danny's%20diner/result%20pics/bonus%202.png)







---
I hope you gained somethings from this SQL analysis and technical write up, if you do kindly give this repo a star
---
criticize my work and connect with me on :
* [LinkedIn](https://www.linkedin.com/in/oloyede-abdulganiyu-420785214)
* [Twitter](https://twitter.com/NobleGee6?t=3OiaIJJ8Iu__0VaIYkL3Hg&s=09)
* [Whatsapp](wa.link/keftwj)


