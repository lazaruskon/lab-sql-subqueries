-- Lab | SQL Subqueries -- 

use sakila;

--    1. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;
select * from film;

# step 1. 
select film_id, title from film where title = 'Hunchback Impossible'; -- notice how I selected title here. That will be a problem for the final query that's why it's not there

# final step
select count(inventory_id) as number_of_copies from inventory
where film_id = (select film_id from film where title = 'Hunchback Impossible');

--    2. List all films whose length is longer than the average of all the films.
select * from film;

# step 1. 
select avg(length) as average_length from film;

# final step
select film_id, title, length from film 
where length > (
select avg(length) as average_length from film
);

--    3. Use subqueries to display all actors who appear in the film Alone Trip.
select * from film;
select * from film_actor;
select * from actor;

# step 1. 
select film_id from film where title = "Alone Trip";

# step 2.
select actor_id from film_actor
where film_id = (
select film_id from film where title = "Alone Trip"
);

# final step
select first_name, last_name from actor
where actor_id in (
select actor_id from (
select actor_id from film_actor 
where film_id = (select film_id from film where title = "Alone Trip") 
) sub1
);

--    4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select * from category;
select * from film_category;
select * from film;

# step 1. 
select category_id from category where name = "Family";

# step 2.
select film_id from film_category
where category_id = (
select category_id from category where name = "Family"
);

# final step
select title from film
where film_id in (
select film_id from (
select film_id from film_category
where category_id = (select category_id from category where name = "Family") 
) sub1
);

--    5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- 		 Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
select * from customer;
select * from address;
select * from city;
select * from country;

select first_name, last_name, email from customer c
join address a 
on a.address_id = c.address_id
join city ci
on ci.city_id = a.city_id
join country co
on co.country_id = ci.country_id
where co.country = "Canada";

# now with subqueries

# step 1.
select country_id from country where country = "Canada";

#step 2.
select city_id from city where country_id = (
select country_id from country where country = "Canada");

# step 3.
select address_id from address where city_id in (
select city_id from (
select city_id from city where country_id = (
select country_id from country where country = "Canada")
) sub1
);

# final step

select first_name, last_name, email from customer where address_id in (
select address_id from (
select address_id from address where city_id in (
select city_id from (
select city_id from city where country_id = (
select country_id from country where country = "Canada")
) sub2
)
) sub1
);

--    6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
-- 		 First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select * from actor;
select * from film_actor;
select * from inventory;
select * from film;

# step 1.
select actor_id from (
select actor_id, count(film_id), rank() over(order by count(film_id) desc) as actor_ranking from film_actor
group by actor_id
) sub1
where actor_ranking = 1;

# step 2.
select film_id from film_actor
where actor_id = (
select actor_id from (
select actor_id, count(film_id), rank() over(order by count(film_id) desc) as actor_ranking from film_actor
group by actor_id
) sub1
where actor_ranking = 1
);

# final step
select title from film
where film_id in (
select film_id from (
select film_id from film_actor where actor_id = (
select actor_id from ( 
select actor_id, count(film_id), rank() over(order by count(film_id) desc) as actor_ranking from film_actor
group by actor_id
) sub2
where actor_ranking = 1
) 
) sub1
);

--    7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
select * from payment;
select * from customer;
select * from inventory;
select * from rental;

# step 1.
select customer_id from (
select customer_id, sum(amount), rank() over(order by sum(amount) desc) as customer_ranking from payment
group by customer_id
) sub1
where customer_ranking = 1;

# step 2 -- getting the most profitable customer as an inventory_id
select inventory_id from rental
where customer_id in (
select customer_id from (
select customer_id, sum(amount), rank() over(order by sum(amount) desc) as customer_ranking from payment
group by customer_id
) sub1
where customer_ranking = 1
);

# step 3 -- getting the film_id
select film_id from inventory
where inventory_id in (
select inventory_id from (
select inventory_id from rental
where customer_id in (
select customer_id from (
select customer_id from (
select customer_id, sum(amount), rank() over(order by sum(amount) desc) as customer_ranking from payment
group by customer_id
)sub1
where customer_ranking = 1
)sub2
)
)sub3
);

-- final query
select title as rented_by_profitable_customer from film
where film_id in (
select film_id from (
select film_id from inventory
where inventory_id in (
select inventory_id from (
select inventory_id from rental
where customer_id in (
select customer_id from (
select customer_id from (
select customer_id, sum(amount), rank() over(order by sum(amount) desc) as customer_ranking from payment
group by customer_id
)sub1
where customer_ranking = 1
)sub2
)
)sub3
)
)sub4
);

--    8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
select * from customer;
select * from payment;

-- step 1.
select customer_id, avg(amount) as individual_average from payment
group by customer_id;

-- step 2.
select avg(individual_average) as total_average from (
select customer_id, avg(amount) as individual_average from payment
group by customer_id
)sub1;

-- final step
select customer_id, sum(amount) as total_amount_spent from payment
group by customer_id
having total_amount_spent > (
select avg(average_per_client) as global_average from (
select customer_id, avg(amount) as average_per_client from payment
group by customer_id
)sub1
)
order by total_amount_spent desc;