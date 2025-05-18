---- Assessment_Q2
---Customer Transactions frequency
----Transaction Frequency Analysis

WITH monthly_transactions AS (
    SELECT
        owner_id, -- Identifier for the customer
        CAST(DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS DATE) AS txn_month, -- Extract the first day of the month from the transaction date
        COUNT(*) AS tx_count -- Count of transactions for each customer in each month
    FROM
        savings_savingsaccount
    GROUP BY
        owner_id, -- Group transactions by customer
        DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) -- Group transactions by the first day of the month
),
avg_tx_per_customer AS (
    SELECT
        owner_id, -- Identifier for the customer
        AVG(CAST(tx_count AS FLOAT)) AS avg_transactions_per_month -- Calculate the average number of transactions per month for each customer
    FROM
        monthly_transactions
    GROUP BY
        owner_id -- Group by customer to calculate their average monthly transaction count
),
categorized AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category, -- Categorize customers based on their average monthly transaction frequency
        avg_transactions_per_month -- The calculated average monthly transaction count
    FROM
        avg_tx_per_customer
)
SELECT
    frequency_category, -- The category of transaction frequency
    COUNT(*) AS customer_count, -- Count of customers in each frequency category
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month -- Average transaction frequency for each category
FROM
    categorized
GROUP BY
    frequency_category; -- Group the results by the frequency category to get counts and averages for each category