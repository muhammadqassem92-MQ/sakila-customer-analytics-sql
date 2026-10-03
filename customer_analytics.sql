-- ============================================================
-- SQL Customer Analytics & Segmentation Project
-- Database: Sakila / Pagila Sample Database
-- Dialect: SQLite / PostgreSQL Standard
-- ============================================================

-- 1. استعلام عرض إجمالي مدفوعات العميل مرتبة تنازلياً
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS cust_name,
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_payment DESC;


-- 2. استعلام عرض إجمالي مدفوعات العميل التي تتجاوز أو تساوي 150
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS cust_name,
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) >= 150
ORDER BY total_payment DESC;


-- 3. استعلام عرض المبيعات وإجمالي المدفوعات مقسمة حسب الدولة مع تصفيتها للدول التي يتجاوز إجماليها 5000
SELECT 
    cou.country,
    SUM(p.amount) AS total_payment
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
LEFT JOIN address ad ON c.address_id = ad.address_id
LEFT JOIN city ci ON ad.city_id = ci.city_id
LEFT JOIN country cou ON ci.country_id = cou.country_id
GROUP BY cou.country
HAVING SUM(p.amount) >= 5000
ORDER BY total_payment DESC;


-- 4. استعلام إيجاد العملاء الذين يتجاوز إنفاقهم متوسط إنفاق جميع العملاء (Subquery)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS cust_name,
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > (
    SELECT AVG(total_customer_spend)
    FROM (
        SELECT SUM(amount) AS total_customer_spend
        FROM payment
        GROUP BY customer_id
    ) AS customer_totals
)
ORDER BY total_payment DESC;


-- 5. استعلام تصنيف العملاء بناءً على شرائح الإنفاق (Low, Medium, High Value) باستخدام CTE و CASE
WITH customer_segment AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(p.amount) AS total_payment,
        CASE 
            WHEN SUM(p.amount) < 100 THEN 'Low Value'
            WHEN SUM(p.amount) BETWEEN 100 AND 150 THEN 'Medium Value'
            ELSE 'High Value'
        END AS customer_segment
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT * 
FROM customer_segment
ORDER BY total_payment DESC;


-- 6. استعلام تجميع البيانات وتحليل شرائح العملاء لمعرفة مجموع الإنفاق والمتوسط وعدد العملاء بكل شريحة
WITH customer_segment AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(p.amount) AS total_payment,
        CASE
            WHEN SUM(p.amount) < 100 THEN 'Low Value'
            WHEN SUM(p.amount) BETWEEN 100 AND 150 THEN 'Medium Value'
            ELSE 'High Value'
        END AS customer_segment
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
payment_by_segment AS (
    SELECT 
        cs.customer_segment,
        SUM(cs.total_payment) AS segment_payment,
        ROUND(AVG(cs.total_payment), 2) AS average_segment_payment,
        COUNT(cs.customer_id) AS count_of_customers
    FROM customer_segment cs
    GROUP BY cs.customer_segment
)
SELECT * 
FROM payment_by_segment
ORDER BY segment_payment DESC;


-- 7. استعلام تصنيف العملاء مقارنة بمتوسط الإنفاق العام (Top, Above Average, Below Average)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(p.amount) AS total_customer_spend,
    CASE
        WHEN SUM(p.amount) >= (
            SELECT AVG(total_paid) * 1.2
            FROM (SELECT SUM(amount) AS total_paid FROM payment GROUP BY customer_id)
        ) THEN 'Top Customer'
        WHEN SUM(p.amount) >= (
            SELECT AVG(total_paid)
            FROM (SELECT SUM(amount) AS total_paid FROM payment GROUP BY customer_id)
        ) THEN 'Above Average'
        ELSE 'Below Average'
    END AS customer_category
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_customer_spend DESC;


-- 8. استعلام ترتيب العملاء تنازلياً حسب إجمالي الإنفاق باستخدام دالة النافذة RANK()
WITH customer_spend AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(p.amount) AS total_spend
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
customer_rank AS (
    SELECT 
        customer_id,
        customer_name,
        total_spend,
        RANK() OVER (ORDER BY total_spend DESC) AS rank_number
    FROM customer_spend
)
SELECT * 
FROM customer_rank
ORDER BY rank_number ASC;


-- 9. استعلام إيجاد العميل الأعلى إنفاقاً فقط في كل دولة (Top Customer per Country) باستخدام ROW_NUMBER()
WITH customer_spend AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        cou.country,
        SUM(p.amount) AS total_spend
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    JOIN address ad ON c.address_id = ad.address_id
    JOIN city ci ON ad.city_id = ci.city_id
    JOIN country cou ON ci.country_id = cou.country_id
    GROUP BY c.customer_id, c.first_name, c.last_name, cou.country
),
customer_rank AS (
    SELECT 
        cs.customer_id,
        cs.customer_name,
        cs.country,
        cs.total_spend,
        ROW_NUMBER() OVER (
            PARTITION BY cs.country
            ORDER BY cs.total_spend DESC
        ) AS country_rank
    FROM customer_spend cs
)
SELECT 
    customer_id,
    customer_name,
    country,
    total_spend
FROM customer_rank
WHERE country_rank = 1
ORDER BY country ASC;


-- 10. استعلام تحليل التغير الشهري لإنفاق العملاء ومقارنته بالشهر السابق باستخدام LAG() و CASE
WITH monthly_sales AS (
    SELECT 
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        strftime('%Y-%m', p.payment_date) AS payment_month,
        SUM(p.amount) AS monthly_paid
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, strftime('%Y-%m', p.payment_date)
),
monthly_sales_comparison AS (
    SELECT 
        ms.customer_id,
        ms.customer_name,
        ms.payment_month,
        ms.monthly_paid,
        LAG(ms.monthly_paid) OVER (
            PARTITION BY ms.customer_id
            ORDER BY ms.payment_month
        ) AS previous_month_paid
    FROM monthly_sales ms
)
SELECT 
    customer_id,
    customer_name,
    payment_month,
    monthly_paid AS current_month_paid,
    previous_month_paid,
    ROUND(monthly_paid - COALESCE(previous_month_paid, 0), 2) AS payment_change,
    CASE
        WHEN previous_month_paid IS NULL THEN 'First Month'
        WHEN monthly_paid > previous_month_paid THEN 'Increase'
        WHEN monthly_paid < previous_month_paid THEN 'Decrease'
        ELSE 'No Change'
    END AS payment_movement
FROM monthly_sales_comparison
ORDER BY customer_id, payment_month;