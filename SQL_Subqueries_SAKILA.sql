USE sakila;

# 1. Número de copias de la película "Hunchback Impossible" en el inventario

SELECT COUNT(i.inventory_id) AS num_copias
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

# 2. Enumerar todas las películas cuya duración es superior a la duración media de todas las películas de la base de datos Sakila.

SELECT title
FROM film
WHERE length > (
    SELECT AVG(length)
    FROM film
);

# 3. Utilice una subconsulta para mostrar todos los actores que aparecen en la película «Alone Trip».

SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

# BONUS

# 4. Las ventas han disminuido entre las familias jóvenes y quieres promocionar las películas familiares. Identifique todas las películas clasificadas como familiares.

# Consulta SQL para encontrar todas las películas de la categoría "Familiar":

SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

# 5. Nombre y correo electrónico de los clientes de Canadá utilizandosubconsultas y uniones.

SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

/* 6. Determinar que peliculas fueron protagonizadas por el actor más prolífico en la base de datos Sakila -> Actor que ha actuado en el mayor numero de películas
	Primero se debera encontrar al actor mas prolífico
    Segundo utilizar ese actor_id para encontrar las diferentes peliculas que ha protagonizado */

SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS num_peliculas
FROM film_actor fa
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY fa.actor_id
ORDER BY num_peliculas DESC
LIMIT 1;

SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT fa.actor_id
    FROM film_actor fa
    GROUP BY fa.actor_id
    ORDER BY COUNT(fa.film_id) DESC
    LIMIT 1
);

/* 7. Encontrar las peliculas alquiladas por el cliente más rentable. 
Puede utilizar las tablas de clientes y pagos para encontrar el cliente más rentable, 
es decir, el cliente que ha realizado la mayor suma de pagos. */

# Encontrar al cliente más rentable

SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_pago
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_pago DESC
LIMIT 1;

# Encontrar las películas alquiladas por el cliente más rentable

SELECT f.title
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT c.customer_id
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
    ORDER BY SUM(p.amount) DESC
    LIMIT 1
);

# 8. Recuperar el id_cliente y el importe_total_gastado de aquellos clientes que gastaron más que la media del importe_total_gastado por cada cliente.

/*
Paso 1: Calcular el gasto total de cada cliente
En primer lugar, necesitamos calcular el total gastado por cada cliente. Para esto, utilizamos la tabla payment, donde almacenamos los pagos de los clientes, y calculamos la suma total de los pagos de cada cliente.

Paso 2: Calcular la media del gasto total
Una vez que tenemos el total gastado por cada cliente, calcularemos la media de todos los clientes.

Paso 3: Filtrar a los clientes que gastaron más que la media
Finalmente, utilizamos una subconsulta para seleccionar solo aquellos clientes cuyo gasto total sea mayor que la media calculada en el paso anterior.
*/

SELECT p.customer_id AS id_cliente, SUM(p.amount) AS importe_total_gastado
FROM payment p
GROUP BY p.customer_id
HAVING SUM(p.amount) > (
    SELECT AVG(total_gasto)
    FROM (
        SELECT SUM(p.amount) AS total_gasto
        FROM payment p
        GROUP BY p.customer_id
    ) AS subconsulta
);
