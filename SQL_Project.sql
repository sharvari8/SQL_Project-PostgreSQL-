-- Create a list of all the different (distinct) replacement costs of the films.--
-- Question 1: What's the lowest replacement cost? --
SELECT DISTINCT replacement_cost AS cost
FROM film
ORDER BY cost ASC

--Write a query that gives an overview of how many films have replacements costs in the following cost ranges--
-- Question 2: How many films have a replacement cost in the "low" group? --
SELECT COUNT(*),
(SELECT CASE
WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
ELSE 'high'
END) AS cost_range
FROM film
GROUP BY cost_range

--Create a list of the film titles including their title, length, and category name ordered descendingly by length. 
--Filter the results to only the movies in the category 'Drama' or 'Sports'.
-- Question 3:  In which category is the longest film and how long is it?--
SELECT title, length, name
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE name IN ('Drama','Sports')
ORDER BY length DESC

-- Create an overview of how many movies (titles) there are in each category (name).
-- Question 4: Which category (name) is the most common among the films? --
SELECT COUNT(title), name
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
GROUP BY name
ORDER BY COUNT(*) DESC

--Create an overview of the actors' first and last names and in how many movies they appear in.
-- Question 5:Which actor is part of most movies?? --
SELECT first_name, last_name, COUNT(title)
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
INNER JOIN film f
ON fa.film_id = f.film_id
GROUP BY first_name, last_name
ORDER BY COUNT(title) DESC


--Create an overview of the addresses that are not associated to any customer.
-- Question 6:How many addresses are that? --
SELECT COUNT(*)
FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE customer_id IS NULL

--Create the overview of the sales  to determine the from which city 
--(we are interested in the city in which the customer lives, not where the store is) most sales occur.
-- Question 7:What city is that and how much is the amount? --
SELECT city, SUM(amount) AS total_amount
FROM city c
INNER JOIN address a
ON c.city_id = a.city_id
INNER JOIN customer cu
ON a.address_id = cu.address_id
INNER JOIN payment p
ON cu.customer_id = p.customer_id
GROUP BY city
ORDER BY total_amount desc

--Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".
-- Question 8:Which country, city has the least sales? --
SELECT country ||', '|| city AS loc, SUM(amount) AS total_amount
FROM country c
INNER JOIN city ci
ON c.country_id = ci.country_id
INNER JOIN address a
ON ci.city_id = a.city_id
INNER JOIN customer cu
ON a.address_id = cu.address_id
INNER JOIN payment p
ON cu.customer_id = p.customer_id
GROUP BY loc
ORDER BY SUM(amount) ASC

--Create a list with the average of the sales amount each staff_id has per customer.
-- Question 9:Which staff_id makes on average more revenue per customer? --
SELECT staff_id, ROUND(AVG(total_amount), 2) avg_amount
FROM (SELECT staff_id,customer_id,SUM(amount) as total_amount FROM payment
	 GROUP BY customer_id, staff_id
	 ORDER BY customer_id) a
GROUP BY staff_id

--Create a query that shows average daily revenue of all Sundays.
-- Question 10:What is the daily average revenue of all Sundays? --
SELECT ROUND(AVG(total_amount),2) AS avg_amount
FROM
(SELECT DATE(payment_date), SUM(amount) total_amount
FROM 
(SELECT *, EXTRACT(DOW FROM payment_date) AS day_of_week
FROM payment
WHERE  EXTRACT(DOW FROM payment_date) = 0
) AS a
GROUP BY DATE(payment_date))

--Create a list of movies - with their length and their replacement cost - that are longer than the average 
--length in each replacement cost group.
-- Question 11:Which two movies are the shortest on that list and how long are they? --
SELECT title, length
FROM film f1
WHERE length >
(SELECT AVG(length) FROM film f2
 WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY length ASC

--Create a list that shows the "average customer lifetime value" grouped by the different districts.
-- Question 12:Which district has the highest average customer lifetime value?--
SELECT ad.district, ROUND(AVG(total_amount), 2) AS avg_cus_spent
FROM 
(SELECT c.address_id,c.customer_id,SUM(amount) AS total_amount
FROM payment p
INNER JOIN customer c
ON c.customer_id = p.customer_id
GROUP BY c.customer_id) a
INNER JOIN address ad
ON a.address_id = ad.address_id
GROUP BY ad.district
ORDER BY avg_cus_spent DESC

