--1.Revenue contribution by gender(with % share)
with gender_revenue as(
select
gender,
sum(purchaseamount) as total_revenue
from dbo.customer_behavior
group by gender
)
select 
gender,
total_revenue,
cast(
total_revenue* 100.0/sum(total_revenue)over() as decimal(5,2) ) as revenue_percenage
from gender_revenue
order by total_revenue desc;

--2.High- value customers who used Disconts
 select 
 customerid,
 sum(purchaseamount) as total_spent
 from dbo.customer_behavior
 where discountapplied = 'yes'
 group by customerid
 having sum(purchaseamount) >(select avg(purchaseamount) from dbo.customer_behavior)
 order by total_spent desc;

--3.Top 5 products by Avarage Review
select top 5
itempurchased,
round(avg(reviewrating),2)as avg_rating,
count(*) as total_reviews
from dbo.customer_behavior
group by itempurchased
having count(*) >=5
order by avg_rating desc;

--4.Impact of shopping Type on Revenue order value
select
shippingtype,
count(*) as total_orders,
round(avg(purchaseamount),2) as avg_order_value,
sum(purchaseamount) as total_revenue
from dbo.customer_behavior
group by shippingtype
order by total_revenue desc;


--5.Subscribes vs Non-Subscribers
select
subscriptionstatus,
count(distinct customerid) as total_customers,
round(avg(purchaseamount),2) as avg_purchase_value,
sum(purchaseamount) as total_revenue
from dbo.customer_behavior
group by subscriptionstatus;
--6.Products most Dependent on Discounts
select top 5
itempurchased,
cast 
    (sum(case when discountapplied ='yes' then 1 else 0 end)*100.0/count(*) over() as decimal(5,2)) as discount_purchase_percentage
    from dbo.customer_behavior
    group by itempurchased
    order by discount_purchase_percentage

--7.Customer Segmenrtation (New/ Returning/Loyal)
select 
case 
     when previouspurchases =0 then 'New'
     when previouspurchases between 1 and 5 then 'Returning'
     else 'Loyal'
  end as customer_segment,
  count(distinct customerid) as customer_count
from dbo.customer_behavior
group by 
     case 
     when previouspurchases =0 then 'New'
     when previouspurchases between 1 and 5 then 'Returning'
     else 'Loyal'
end;

--8.Top 3 Products per category(Most Purchased)
with ranked_products as(
 select
 category,
 itempurchased,
 count(*) as total_purchases,
 rank() over(partition by category order by count(*) desc) as Rnk
 from dbo.customer_behavior
 group by category,itempurchased
 )
 select
 category,
 itempurchased,
 total_purchases
 from ranked_products
 where rnk< =3
 order by category,total_purchases desc;
 
 --9.are loyal customer more likely to subscribe?
 select
 subscriptionstatus,
 count(*) as loyal_customers
 from dbo.customer_behavior
 where previouspurchases> 5
 group by subscriptionstatus;
 
 --10.Revenue contribution by age group
 select
 age_group,
 sum(purchaseamount)as total_revenue
 from dbo.customer_behavior
 group by age_group
 order by total_revenue desc;