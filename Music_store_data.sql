Q1. Who is the senior most employee bases on Job Tittle?

select * from employee
order by levels desc
Limit 1

Q2. Which countries have the most Invoices?

select * from invoice 

select count(*) as c,billing_country
from invoice
group by billing_country
order by c desc

Q3. What are the top values of total invoice

select total from invoice
order by total desc
limit 3

Q4 Which city has the best customers?We would like to throw a promotional music Festival in the city
we made the most money.Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals

select * from invoice

select sum(total) as invoice_total,billing_city 
from invoice
group by billing_city
order by invoice_total desc


Q5 Who is the  best customer? The customer who has spent the most money will be declared the best 
customer.Write a Query that returns the person who has spent the most money

select * from customer

Select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

Q4 Write query to return the email ,first name,last name & genre of all rock music listeners.
Return your list alphabetically by Email starting with A

SELECT DISTINCT email,first_name,last_name
from customer
join invoice ON customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock'
)
order by email;

Q5 LETS INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC OUR DATASET.
 WRITE A QUERY THAT RETURNS THE ARTIST NAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS

SELECT a1.artist_id,a1.name,COUNT(a1.artist_id) AS number_of_songs
 FROM track t
 join album a on a.album_id = t.album_id
 join artist a1 ON a1.artist_id = a.artist_id
 join genre g ON g.genre_id =t.genre_id
 where g.name like 'Rock'
 group by a1.artist_id
 order by number_of_songs desc
 limit 10;

Q6 Return all the track names that have a song length longer than the average song length.Return the name
and millisecond for eack track.Order by the song length with the logest song listed first.

select name, milliseconds
from track
where milliseconds >(
select avg (milliseconds) as avg_track_length
	from track)
	order by milliseconds desc;
	
Q7 Find how much amount spent by each customer on artists?write a query to retun customer name,artist name,total spent

with best_selling_artist as(
select artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id=invoice_line.track_id
	join album on album.album_id=track.album_id
	join artist on artist.artist_id=album.artist_id
	group by 1
	order by 3 Desc
	limit 1
	)
	select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
	sum(il.unit_price*il.quantity) as amount_spent
	from invoice i 
	join customer c on c.customer_id=i.customer_id
	join invoice_line il on il.invoice_id=i.invoice_id
	join track t on t.track_id=il.track_id
	join album alb on alb.album_id =t.album_id
	join best_selling_artist bsa on bsa.artist_id=alb.artist_id
	group by 1,2,3,4
	order by 5 desc
	
Q8 We want to find out the most popular music genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top genre.
For countries where the maximum number of purchases is shared return all genres.

with popular_genre as
(select count(invoice_line.quantity) as purchases,customer.country,genre.name,genre.genre_id,
 Row_number() over(partition by customer.country order by count (invoice_line.quantity) Desc) as rowno
 from invoice_line
 Join invoice on invoice.invoice_id=invoice_line.invoice_id
 join customer on customer.customer_id=invoice.customer_id
 join track on track.track_id=invoice_line.track_id
 join genre on genre.genre_id=track.genre_id
 group by 2,3,4
 order by 2 asc ,1 desc
 )
 select * from popular_genre where RowNo<=1
 
Q9 Write a query that determines the customer that has spent the most
 on music for each country.Write a query that return the country along with the top
customer and how much they spent.For countries where the top amount spent is shared,provide
all customer who spent this amount

with recursive 
customer_with_country AS(
SELECT Customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending
from invoice
Join customer on customer.customer_id=invoice.customer_id
group by 1,2,3,4
Order by 2,3 Desc),

country_max_spending as(
select billing_country,max(total_spending) as max_spending
from customer_with_country
group by billing_country)

select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by 1;

--- Using CTE--------

With customer_with_country as(
SELECT Customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total)desc) as RowNo
from invoice
Join customer on customer.customer_id=invoice.customer_id
group by 1,2,3,4
Order by 4 ASC ,5 DESC)
SELECT * FROM customer_with_country WHERE RowNo<=1
