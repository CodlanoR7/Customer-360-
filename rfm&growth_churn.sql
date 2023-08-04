select *, concat(R, F, M) as Segmentation
from (select CustomerID, Recency, Frequency, Monetary,
           NTILE (4) OVER (ORDER BY Recency desc) R,
           NTILE (4) OVER (ORDER BY Frequency) F,
           NTILE (4) OVER (ORDER BY Monetary) M
from (select CustomerID, datediff('2022-09-01' ,max(cast(Purchase_Date as date))) as Recency,
       count(distinct (Purchase_Date)) / (m.contract_duration_years) as Frequency,
       sum(GMV) / (m.contract_duration_years) as Monetary
from customer_transaction ct
left join (select ID , datediff('2022-09-01',cast(created_date as date))/365 as contract_duration_years
from customer_registered where stopdate is null and cast(created_date as date) <= '2022-09-01') m on ct.CustomerID = m.ID
group by CustomerID) A
where Monetary > 0 ) B

-- Growth - Churn rate --
select A.date as date , growth_rate, churn_rate
from(
(select cast(created_date as date) as date,count(*) as growth_rate
from customer_registered where cast(created_date as date) <= '2022-09-01'
group by cast(created_date as date)) A
LEFT JOIN (
select cast(stopdate as date) as date, count(*) as churn_rate
from customer_registered where stopdate is not null and cast(created_date as date) <= '2022-09-01'
group by cast(stopdate as date)) B on A.date = B.date ) order by date
