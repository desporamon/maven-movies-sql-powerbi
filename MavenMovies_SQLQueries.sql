use mavenmovies;

/*
1.	We will need a list of all staff members, including their first and last names, 
email addresses, and the store identification number where they work. 
*/ 
select first_name, last_name, email, store_id
from staff;

/*
2.	We will need separate counts of inventory items held at each of your two stores. 
*/ 

-- WORKS but REDUNDANT - unnecessary JOIN
-- store table is joined just to get store_id,
-- but inventory ALREADY has store_id in it!
select s.store_id, count(i.inventory_id) as inventory_items
from store s
left join inventory i
	on s.store_id = i.store_id
group by s.store_id;

-- BETTER - simpler, same result, one table only
-- inventory has store_id built in - no JOIN needed
select store_id, count(inventory_id) as inventory_items
from inventory
group by store_id;

/*
3.	We will need a count of active customers for each of your stores. Separately, please. 
*/
select *
from customer;

select store_id, count(customer_id) as active_customers
from customer
where active = 1
group by store_id;

/*
4.	In order to assess the liability of a data breach, we will need you to provide a count 
of all customer email addresses stored in the database. 
*/
select count(email) as total_emails
from customer;

/*
5.	We are interested in how diverse your film offering is as a means of understanding how likely 
you are to keep customers engaged in the future. Please provide a count of unique film titles 
you have in inventory at each store and then provide a count of the unique categories of films you provide. 
*/
select store_id, count(distinct film_id) as unique_films
from inventory
group by store_id;

-- Part b OPTION 1: counts categories actually ASSIGNED to films
-- more business-relevant - only categories in active use
select count(distinct category_id) as unique_categories
from film_category;

-- Part B OPTION 2: counts all categories that EXIST in the system
-- includes categories even if no films are assigned to them
select count(distinct name) as unique_categories
from category;

-- Both return 16 here because all categories happen to be in use.
-- In a real business scenario they could differ if some categories
-- exist in the system but have no films assigned yet.


/*
6.	We would like to understand the replacement cost of your films. 
Please provide the replacement cost for the film that is least expensive to replace, 
the most expensive to replace, and the average of all films you carry. ``	
*/
select
	min(replacement_cost) as least_expensive,
    max(replacement_cost) as most_expensive,
    avg(replacement_cost) as avg_replacement_cost
from film;

/*
7.	We are interested in having you put payment monitoring systems and maximum payment 
processing restrictions in place in order to minimize the future risk of fraud by your staff. 
Please provide the average payment you process, as well as the maximum payment you have processed.
*/
select 
	avg(amount) as avg_payment,
    max(amount) as max_payment
from payment;


/*
8.	We would like to better understand what your customer base looks like. 
Please provide a list of all customer identification values, with a count of rentals 
they have made all-time, with your highest volume customers at the top of the list.
*/

select customer_id, count(rental_id) as num_of_rentals
from rental
group by customer_id
order by num_of_rentals desc;

/* 
9. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 

select 
    st.store_id,
    s.first_name as manager_first_name,
    s.last_name as manager_last_name,
    a.address,
    c.city,
    co.country
from store st
    left join staff s on st.manager_staff_id = s.staff_id
    left join address a on st.address_id = a.address_id
    left join city c on a.city_id = c.city_id
    left join country co on c.country_id = co.country_id;
	
/*
10.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

select 
	i.store_id,
    i.inventory_id,
    f.title,
    f.rating,
    f.rental_rate,
    f.replacement_cost
from inventory i
left join film f on i.film_id = f.film_id;

/* 
11.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

select 
	i.store_id,
    f.rating,
    count(i.inventory_id) as inventory_items
from inventory i
left join film f on i.film_id = f.film_id
group by i.store_id, f.rating;

/* 
12. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 

select 
    i.store_id,
    ca.name                    as category,
    count(i.inventory_id)      as num_films,
    avg(f.replacement_cost)    as avg_replacement_cost,
    sum(f.replacement_cost)    as total_replacement_cost
from inventory i
    left join film f         on i.film_id = f.film_id
    left join film_category fc on f.film_id = fc.film_id
    left join category ca    on fc.category_id = ca.category_id
group by i.store_id, ca.name
order by sum(f.replacement_cost) desc;

/*
13.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/

select 
    c.first_name,
    c.last_name,
    c.store_id,
    c.active,
    a.address,
    ci.city,
    co.country
from customer c
    left join address a  on c.address_id = a.address_id
    left join city ci    on a.city_id = ci.city_id
    left join country co on ci.country_id = co.country_id;

/*
14.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

select 
    c.first_name,
    c.last_name,
    count(r.rental_id)  as total_rentals,
    sum(p.amount)       as total_payment_amount
from customer c
    left join rental r  on c.customer_id = r.customer_id
    left join payment p on r.rental_id = p.rental_id
group by c.first_name, c.last_name
order by sum(p.amount) desc;
    
/*
15. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/

select 'investor' as type, first_name, last_name, company_name
from investor
union
select 'advisor' as type, first_name, last_name, null
from advisor;

/*
16. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
select 
    -- group actors by how many award types they have
    case
        when awards = 'Emmy, Oscar, Tony '          then '3 awards'
        when awards in ('Emmy, Oscar','Emmy, Tony',
                        'Oscar, Tony')              then '2 awards'
        else                                             '1 award'
    end                                         as number_of_awards,
    -- avg of 1s and 0s = % of actors whose films we carry
    -- actor_id is null = we dont carry their films
    avg(case when actor_id is null then 0 else 1 end) as pct_carried
from actor_award
group by
    case
        when awards = 'Emmy, Oscar, Tony '          then '3 awards'
        when awards in ('Emmy, Oscar','Emmy, Tony',
                        'Oscar, Tony')              then '2 awards'
        else                                             '1 award'
    end;


