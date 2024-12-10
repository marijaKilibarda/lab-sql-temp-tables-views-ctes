USE sakila;

-- Step 1: Create a View
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Step 2: Create a Temporary Table
CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT 
    crs.customer_id,
    crs.customer_name,
    crs.email,
    crs.rental_count,
    SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id, crs.customer_name, crs.email, crs.rental_count;

-- Step 3: Create a CTE and the Customer Summary Report

WITH customer_summary_cte AS (
    SELECT 
        crs.customer_id,
        crs.customer_name,
        crs.email,
        crs.rental_count,
        SUM(p.amount) AS total_paid,
        CASE 
            WHEN crs.rental_count > 0 THEN SUM(p.amount) / crs.rental_count
            ELSE 0
        END AS average_payment_per_rental
    FROM customer_rental_summary crs
    LEFT JOIN payment p ON crs.customer_id = p.customer_id
    GROUP BY crs.customer_id, crs.customer_name, crs.email, crs.rental_count
)
SELECT 
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(average_payment_per_rental, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY total_paid DESC;


