-- Q1 Who is the senior most employee based on job title? 

SELECT * FROM employee
order by levels desc
limit 3

-- Q2. Which country have the most invoice?

select COUNT(*) as count,billing_country 
from invoice
group by billing_country
order by count desc


-- Q3 What are the top 3 Values of the total invoice?


SELECT total as total_invoice
FROM invoice
order by total desc
limit 3


-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals *


SELECT billing_city,SUM(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc
limit 1


-- Q5.Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

SELECT 
    customer.customer_id,
	customer.first_name,
	customer.last_name, SUM(invoice.total) as total 
FROM customer
JOIN invoice on customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc
limit 1


-- Q6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A. 



SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email


-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands..


SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


-- Q8: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;

-- Q9.Find how much amount spent by each customer on artists?
--Write a query to return customer name, artist name and total spent 

WITH best_selling_artist AS (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 DESC
	limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;



-- Q10.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.?

WITH popular_genre AS 
	(
    select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
   	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT (invoice_line.quantity) desc) as Row_no
	from invoice_line 
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
    join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
SELECT * 
FROM popular_genre
WHERE Row_no <= 1



--  Q11.Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.



WITH customer_with_country AS (
     SELECT customer.customer_id,first_name,last_name,billing_country, SUM(total) AS Total_Spending,
	 ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) Row_No
	 FROM invoice
	JOIN customer on customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC)
SELECT *
FROM customer_with_country
WHERE Row_No <=1;
	





