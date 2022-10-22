### Case Study Analytics
  
  show databases;
  use dannys_diner;
  
  
  #### 1 ###
  SELECT
	s.customer_id,
    SUM(price) AS total_amount_spent
  FROM sales as S
  JOIN menu
  ON s.product_id = menu.product_id
  GROUP BY customer_id;
  
  ### 2 ###
  SELECT 
	s.customer_id,
    count(distinct(order_date)) as no_of_days_visited
from sales as s
group by customer_id;

### 3 ###
# create a cte to rank the orders according to order_date
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
#and customer_id = 'A'
#and customer_id = 'B'
#and customer_id = 'C'
#limit 1
;

/*lets try another method for this question 3*/
select s.customer_id, m.product_name
from sales as s 
join menu as m
on s.product_id = m.product_id
where order_date = (select order_date
from sales
order by s.customer_id
limit 1
);

### 4 ###
select m.product_name, count(s.product_id) as product_count 
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_id
order by count(s.product_id) DESC
LIMIT 1 ;
#### Anither method for the 4th question
SELECT product_name, max(product_count)
from (select m.product_name, count(s.product_id) as product_count 
from sales as s
join menu as m
on s.product_id = m.product_id
group by m.product_id) AS derived;

### 5 ###
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

### 6 ###
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

### 7 ###
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

### 8 ###
select s.customer_id,
	count(s.product_id) as items,
	sum(m.price) as amount_spent
from sales as s
join menu as m 
ON s.product_id = m.product_id
join members
on members.customer_id = s.customer_id
where s.order_date < members.join_date
group by s.customer_id
;

### 9 ###
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

### 10 ###
select s.customer_id,
	s.order_date
from sales as s
join members as m
where s.order_date between m.join_date and date_add(m.join_date, interval 6 day)
and s.customer_id in (select m.customer_id from members as m )
;

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

### bonus question 1 ###
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

-- bonus question 2 --
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