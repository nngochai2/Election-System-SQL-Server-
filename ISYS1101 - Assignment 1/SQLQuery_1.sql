SELECT * FROM [film] 
    WHERE [rental_rate] = 2.99 
    AND length <= 45;

SELECT * FROM [film] 
    WHERE [rental_rate] = 2.99
    OR length <= 45

CREATE INDEX length_ids ON [film](length);

SELECT c.first_name, c.last_name
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE f.title = 'Metropolis Coma';

