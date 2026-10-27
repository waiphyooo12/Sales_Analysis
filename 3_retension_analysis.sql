
--retension analysis
with cohort as(
select 
  orderdate , 
  customerkey,
  extract(year from min(orderdate)over(partition by customerkey)) as cohort_yr,
  row_number()over(partition by customerkey order by orderdate desc) as rn
from sales
order by 2),
 status_cte as(
select *,
  case when 
  (select max(orderdate) from sales) - INTERVAL '6 months' > orderdate then 'Churned'
  else 'Active'
  end as status 
from cohort
WHERE rn = 1
  
)
select * ,
sum(customer_count)over(partition by cohort_yr) , 
ROUND(
    customer_count * 100.0 /
    SUM(customer_count) OVER(PARTITION BY cohort_yr),
    2
) AS percentage
from (
select cohort_yr, status ,count(*) as customer_count
from status_cte
group by cohort_yr,status
order by 1)
;
