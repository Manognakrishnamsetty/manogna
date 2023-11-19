create database sales_delivary;
use sales_delivary;


-- 1) Find the top 3 customers who have the maximum number of orders

select Customer_Name,count(cust_id) from market_fact m join cust_dimen c
using(Cust_id)
group by Customer_Name 
order by count(cust_id) desc
limit 3; ## mine

select Customer_Name,m.Cust_id, count(Ord_id) orders from cust_dimen c join market_fact m
on c.Cust_id = m.Cust_id
group by m.Cust_id,Customer_Name
order by orders desc
limit 3;## sai teja
-- 2) Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select *,datediff(str_to_date(sd.ship_date,'%d-%m-%Y'),str_to_date(od.order_date,'%d-%m-%Y')) as DaysTakenForDelivery 
from orders_dimen as od join shipping_dimen as sd
on od.Order_ID=sd.Order_ID;
-- 3) Find the customer whose order took the maximum time to get delivered.
with table1 (ship_id ,datedifference) as
(select Ship_id, DATEDIFF(str_to_date(ship_date, "%d-%m-%Y"),str_to_date(order_date, "%d-%m-%Y") ) AS DateDifference from orders_dimen o join shipping_dimen s
on o.Order_ID = s. Order_ID)
select distinct Cust_id ,max(datedifference) over(partition by t.Ship_id) max_delivery_time_days from table1 t join market_fact m
on t.ship_id = m.Ship_id
order by max_delivery_time_days desc
limit 1;

-- 4) Retrieve total sales made by each product from the data (use Windows function)
select distinct * from
(select product_category,product_sub_category,m.prod_id,round(sum(sales)over(partition by prod_id ),2) Total_Sales 
from prod_dimen pd join market_fact m 
using(prod_id)
order by Total_Sales desc)temp;
### rounded the sum to 2 d.p for better understanding.

-- 5) Retrieve the total profit made from each product from the data (use windows function)
select distinct prod_id, round(sum(profit)  over(partition by prod_id),2) total_profit from market_fact order by total_profit desc;

-- 6) Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

select date_format( str_to_date(order_date, "%d-%m-%Y") ,"%Y-%M") month_in_2011 ,COUNT(DISTINCT m.Cust_id) customer_count from market_fact m join orders_dimen o
on m.Ord_id = o.Ord_id
where date_format(str_to_date(order_date, "%d-%m-%Y"),"%Y-%M-%d") like '2011-%January%'
group by date_format( str_to_date(order_date, "%d-%m-%Y") ,"%Y-%M")
union
select date_format( str_to_date(order_date, "%d-%m-%Y") ,"%M-%Y") month_in_2011 ,COUNT(DISTINCT m.Cust_id) customer_count from market_fact m join orders_dimen o
on m.Ord_id = o.Ord_id
where year(str_to_date(order_date, "%d-%m-%Y")) = 2011
group by date_format( str_to_date(order_date, "%d-%m-%Y") ,"%M-%Y");

-- ------------------------------------------------------------ PART 2 ---------------------------------------------------------------------------------------------------

-- 1) We need to find out the total visits to all restaurants under all alcohol categories available.

select count(r.userID)total_visit,geoplaces2.alcohol
from rating_final r join geoplaces2
using(placeID)
where alcohol <> 'no_alcohol_served'
group by geoplaces2.alcohol;

-- 2) Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

select round(avg(rating_final.rating),3)Rating,geoplaces2.price,geoplaces2.alcohol
from geoplaces2
join rating_final
on geoplaces2.placeID=rating_final.placeID
group by geoplaces2.alcohol,geoplaces2.price
order by geoplaces2.price,avg(rating_final.rating);

-- 3) Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.

select parking_lot, alcohol,count(g.placeID) count_of_restaurants from geoplaces2 g join chefmozparking p 
on g.placeID = p.placeID
where parking_lot not like '%none%'
group by parking_lot, alcohol;

-- 4) Also take out the percentage of different cuisine in each alcohol type.

select alcohol,Rcuisine,round(count(distinct Rcuisine)/count(Rcuisine)*100,2) as percentage 
from geoplaces2 g  join chefmozcuisine c
on g.placeID = c. placeID
group by alcohol, Rcuisine;

-- 5) let’s take out the average rating of each state.

select state ,avg(rating) avg_rating 
from geoplaces2 g join rating_final r 
on g.placeID = r.placeID 
group by state;

-- 6) ' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

select placeID,Rcuisine from chefmozcuisine 
where placeID in 
(select placeID from geoplaces2
where state = 'Tamaulipas');

select placeID,Rcuisine from chefmozcuisine 
where placeID in 
(select placeID from geoplaces2
where country = 'mexico');

## alcohol is not sereved in this state
## Lack of varitey in cuisine (mostly mexican food)

-- 7) Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low. We encourage you to give it a try by not using joins.

select u.userID, g.placeID, avg(ifnull(weight,0)) Average_weight,food_rating,service_rating 
from userprofile u join usercuisine c
on u.userID = c.userID
join rating_final r
on c.userID = r.userID
join geoplaces2 g
on r.placeID = g.placeID
where (name like '%kfc%' and price = 'low') and  (Rcuisine in ('Mexican','Italian'))
group by u.userID, g.placeID,food_rating,service_rating;

-- -------------------------------------------------- PART 3 -----------------------------------------------------------------------------------

-- 1) Create two called Student_details and Student_details_backup.

create database student_info;
use student_info;

create table students(
student_id int primary key,
student_name varchar(30),
mail_id varchar (30),
mobile_no varchar (12) not null);


create table students_backup(
student_id int primary key,
student_name varchar(30),
mail_id varchar (30),
mobile_no varchar (12) not null);


insert into students values 
(01,'kratos','kratos@sparta.com',9898989898),
(02,'atreus','atreus@Midgard.com',8989898989),
(03,'odin','odin@Asgard.com',5635632147),
(04,'thor','thor@Asgard.com',9000023164), 
(05,'freya','freya@Alfheim.com',7777755555),
(06,'zeus','zeus@olympus.com',9874563210),
(07,'Athena','Athena@olympus.com',6320145877),
(08,'hades','hades@hell.com',9010203085),
(09,'poseidon','poseidon@ocean.com',9949596932),
(10,'helios','helios@olympus.com',8586764521),
(11,'chronos','chronos@desert.com',9685741232),
(12,'gaia','gaia@earth.com',8656464174);



create trigger backup_students_info 
after delete on students
for each row
insert into students_backup
VALUES (OLD.student_id, OLD.student_name, OLD.mail_id, OLD.mobile_no);

delete from students where student_id in (03,06,08);
select * from students;
select * from students_backup;