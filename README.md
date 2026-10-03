Sakila Customer Analytics & Segmentation SQL
An end-to-end SQL analytics project focused on evaluating customer purchasing patterns, financial segmentation, regional sales performance, and Month-over-Month (MoM) revenue trends using standard transactional database schemas (Sakila / Pagila).

📌 Project Overview
This repository contains a structured suite of SQL queries designed to transform raw transactional data into actionable business intelligence. The analysis spans basic aggregation to advanced analytical techniques, helping businesses identify high-value customer cohorts, regional revenue drivers, and individual spend trajectories over time.

🛠️ Key SQL Concepts & Analytical Techniques
Aggregate Functions & Filtering: SUM, AVG, COUNT, GROUP BY, HAVING

Multi-Table Joins: Combining relational entities across customer, payment, address, city, and country.

Common Table Expressions (CTEs): Structuring clean, modular, and readable multi-step queries.

Window Functions:

RANK() for overall spending leaderboards.

ROW_NUMBER() combined with PARTITION BY to find top performers per country.

LAG() for time-series trend analysis.

Conditional Business Logic: Complex CASE WHEN logic for customer value segmentation.

Null Handling & Formatting: COALESCE for clean numerical differences and ROUND for currency formatting.
