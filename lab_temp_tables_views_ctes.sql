USE sakila;

-- Step 1: Create a View
CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(*) AS rental_count
FROM 
    customer AS c
    JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id
ORDER BY 
    rental_count DESC; 

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
WITH customer_summary_report AS (
    SELECT 
        crs.customer_name,
        crs.email,
        crs.rental_count,
        tcp.total_paid
    FROM 
        customer_rental_summary crs
        JOIN temp_customer_payments tcp ON crs.customer_id = tcp.customer_id
)
SELECT 
    *,
    total_paid / CASE WHEN rental_count > 0 THEN rental_count ELSE 1 END AS average_payment_per_rental
FROM 
    customer_summary_report
ORDER BY 
    rental_count DESC;


