#First, we tell the computer to use the Sakila Database. 
use sakila; 

#1a: Display first and last name from the actor table. 
#We can do this by selecting the two columns and which table they originated from. 
select  first_name, last_name from actor; 

#1b: Display the first and last name of each actor in a single column in upper case letters. 
#      Name the column Actor Name.
# We can do this by concatnating the two columns into one column and calling it "Actor Name". 
select 
     concat_ws(' ', first_name, last_name) as 'Actor Name'  
  from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
select 
actor_id
,first_name
,last_name
from actor where last_name like "Joe";

#2b. Find all actors whose last name contain the letters GEN: 
#We use the wildcards % sings which tell us to search anywhere in the last name. 
select 
concat_ws(' ', first_name, last_name) as 'Actor Name' 
from actor where last_name like "%GEN%";

#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
select 
concat_ws(' ', last_name, first_name) as 'Actor Name' 
from actor where last_name like "%LI%";

#2d. Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. 
#Hint: you will need to specify the data type.
alter table actor
drop middle_name;

alter table actor
add middle_name varchar(25) not null after first_name; 

#select * from actor

#3b. You realize that some of these actors have tremendously long last names. 
#Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name BLOB; 
#select * from actor

#3c. Now delete the middle_name column.
alter table actor
drop middle_name; 

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name; 

#4b. List last names of actors and the number of actors who have that last name, but only 
#for names that are shared by at least two actors
select last_name, count(last_name) from actor group by last_name having count(*) >1; 

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered 
#in the actor table as GROUCHO WILLIAMS, the name of Harpo's second 
#cousin's husband's yoga teacher. Write a query to fix the record.
update actor
set first_name ='HARPO'
where (first_name ='GROUCHO' and last_name = 'WILLIAMS');

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to 
#MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE 
#THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
update actor
set first_name = 'GROUCHO'
where (first_name = 'HARPO' and last_name = 'WILLIAMS');

#Note, I had to go into preferences to uncheck safe updated due to an error I got. 
#Otherwise the code below did not run. We can also try this: SET SQL_SAFE_UPDATES = 0;
update actor
set first_name = 'MUCHO GROUCHO' 
where first_name = 'GROUCHO';

#5a. You cannot locate the schema of the address table. 
#Which query would you use to re-create it? 
show create table address; 

#6a. Use JOIN to display the first and last names, as well as the address, 
#of each staff member. Use the tables staff and address:
#select * from staff
select staff.first_name, staff.last_name, address.address from staff 
inner join address on staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff 
#member in August of 2005. Use tables staff and payment.
select 
	staff.last_name, sum(payment.amount)
from staff 
inner join payment on 
staff.staff_id = payment.staff_id 
where payment.payment_date like '%2005_08%'
group by staff.last_name;

#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.

select film.title,
	count(film_actor.actor_id) as num_actors
from film inner join film_actor 
on film.film_id = film_actor.film_id
group by film.title; 

#6d. How many copies of the film Hunchback Impossible exist 
#in the inventory system?
select film_id from film
where title = 'Hunchback Impossible'; 
#This gives us a film id of 439
select count(*) from inventory where film_id = 439; 
#Now we have the number of copies of the movie Hunchback Impossible. 
#Now let's put it all together: 
select count(*) from inventory where film_id = (select film_id from film
where title = 'Hunchback Impossible'); 

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
select 
	customer.last_name, sum(payment.amount) as 'total payment'
from customer
inner join payment on 
customer.customer_id = payment.customer_id 
group by customer.last_name
order by customer.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also 
#soared in popularity. Use subqueries to display the titles of movies starting with 
#the letters K and Q whose language is English.
select * from film where (title like 'K%' or title like 'Q%')
and language_id = (select language_id from language where name = 'English' ); 

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select count(*) from film_actor where film_id = (select film_id from film
where title = 'Alone Trip'); 

#7c. You want to run an email marketing campaign in Canada, for which you will 
#need the names and email addresses of all Canadian customers. Use joins to 
#retrieve this information.

select concat_ws(' ', customer.first_name, customer.last_name) as 'Customer Name'  , customer.email
from customer
inner join address on customer.address_id = address.address_id
inner join city on address.city_id = city.city_id
where country_id = (select country_id from country where country = 'Canada');

#7d. Sales have been lagging among young families, and you wish to target all
#family movies for a promotion. Identify all movies categorized as family films.
select title from film where film_id in (select film_id from film_category 
where category_id = (select category_id from category where name = 'Family'));

#7e. Display the most frequently rented movies in descending order.
select count(rental.rental_date) as 'Rental Frequency', film.title from rental 
inner join inventory 
on rental.inventory_id = inventory.inventory_id
inner join film on inventory.film_id = film.film_id
group by film.film_id
order by count(rental.rental_date) desc; 

#7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount) from payment 
inner join customer on payment.customer_id = customer.customer_id
inner join store on customer.store_id = store.store_id
group by store.store_id;
#Let's check this. 
#select sum(amount) from payment

#7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country from store
inner join address on address.address_id = store.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
group by store.store_id;

#7h. List the top five genres in gross revenue (total amount) in descending order. 
#(Hint: you may need to use the following tables: category, film_category, 
#inventory, payment, and rental.)
select category.name, sum(payment.amount) as 'gross revenue' from category 
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on rental.customer_id = payment.customer_id
group by category.name 
order by sum(payment.amount) desc limit 5; 

#8a. In your new role as an executive, you would like to have an easy 
#way of viewing the Top five genres by gross revenue. Use the solution 
#from the problem above to create a view. If you haven't solved 7h, you 
#can substitute another query to create a view.
create view Revenue as select category.name, sum(payment.amount) as 'gross revenue' from category 
inner join film_category on film_category.category_id = category.category_id
inner join inventory on inventory.film_id = film_category.film_id
inner join rental on rental.inventory_id = inventory.inventory_id
inner join payment on rental.customer_id = payment.customer_id
group by category.name 
order by sum(payment.amount) desc limit 5; 


#8b. How would you display the view that you created in 8a?
select * from Revenue;

#Let's check to see if it in fact it saved the query as a view  
#show tables
#In fact, we do see the table "revenue" there. 

#8c. You find that you no longer need the view top_five_genres. 
#Write a query to delete it.
drop view Revenue; 