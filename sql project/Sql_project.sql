create database sql_project1;
use sql_project1;
create table employee(employee_id int primary key ,last_name text, first_name text,title text,reports_to int , levels text , 
birthdate date,hiredate date,address text,city text,state text,country text,postal_code text, phone char(17),facts text,email text);

create table customer(customer_id int primary key,first_name text,last_name text,company text,address text,city text,state text,
country text,postal_code text,phone text,facts text,email text,support_rep_id int,foreign key(support_rep_id) 
references employee(employee_id) on update cascade on delete cascade);

create table invoice(invoice_id int primary key ,customer_id int ,invoice_date text,billing_address text, billing_city text,
billing_state text,billing_country text,billing_postal_code text,total double,foreign key(customer_id) 
references customer(customer_id) on update cascade on delete cascade);
 
create table artist(artist_id int primary key,name text);

create table playlist(playlist_id int primary key,name text);

create table media_type(media_type_id int primary key,name text);

create table genre(genre_id int primary key, name text);

create table album(album_id int primary key,title text,artist_id int,
foreign key(artist_id) references artist(artist_id) on update cascade on delete cascade);

create table track(track_id int primary key,name text,album_id int,media_type_id int,genre_id int,composer text,
milliseconds bigint,bytes bigint,unit_price double,
 foreign key(album_id) references album(album_id) on update cascade on delete cascade,
 foreign key(media_type_id) references media_type(media_type_id) on update cascade on delete cascade,
 foreign key(genre_id) references genre(genre_id) on update cascade on delete cascade);


create table invoice_line(invoice_line_id int primary key, invoice_id int,track_id int,unit_price double,quantity int,foreign key (track_id) references track(track_id) 
on update cascade on delete cascade,foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade);
select * from invoice_line;

create table playlist_track(playlist_id int,track_id int,
foreign key(playlist_id) references playlist(playlist_id) on update cascade on delete cascade,
foreign key(track_id) references track(track_id) on update cascade on delete cascade);

## Easy Queries
#1
select employee_id  from employee order by levels desc limit 1;
#2
select billing_country,count(billing_country) as count from invoice  group by billing_country order by count desc limit 1;
#3
select distinct(total) from invoice order by total desc limit 3;
#4
select billing_city,sum(total) as total_invoice from invoice group by billing_city order by total_invoice desc limit 1;
#5
select concat(c.first_name," ",c.last_name) as customer_name,sum(i.total) as total_invoice  
from invoice as i inner join customer as c using(customer_id) group by i.customer_id order by total_invoice desc limit 1;

## Medium Queries
#1
select distinct(c.first_name),c.last_name,c.email from customer as c inner join invoice as i using(customer_id) inner join 
invoice_line as il using(invoice_id) inner join track as t using(track_id) inner join genre as g using(genre_id) where g.name = "Rock"  
order by c.email ;
#2
select a.name from artist as a inner join album as al using(artist_id) inner join track as t using(album_id) 
inner join genre as g using(genre_id)  where g.name = "Rock" group by a.name order by count(t.track_id) desc limit 10;
#3
with cte as (select avg(milliseconds) as avg from track) 
select name,milliseconds from track,cte where milliseconds > cte.avg order by milliseconds desc;

## Hard
#1
select concat(c.first_name," ",c.last_name) as customer_name,a.name,sum(il.unit_price) as total_spent from customer as c 
inner join invoice as i using(customer_id) inner join invoice_line as il using(invoice_id) inner join track as t using(track_id) 
inner join album as al using(album_id) inner join artist as a  using(artist_id) group by a.name,c.customer_id;

#2
with cte as (select i.billing_country,g.name,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from invoice as i  inner join invoice_line as il using(invoice_id) inner join track as t using(track_id)
 inner join genre as g using(genre_id) group by i.billing_country,g.name)
 select billing_country,name,purchase_amount  from cte where a=1 ;
 
 #3
 with cte as (select i.billing_country,c.customer_id,sum(i.total) as purchase_amount,
dense_rank() over(partition by i.billing_country order by sum(i.total) desc)  as a
 from customer as c inner join  invoice as i using(customer_id) group by i.billing_country,c.customer_id)
 select billing_country,customer_id,purchase_amount  from cte where a=1 ;




