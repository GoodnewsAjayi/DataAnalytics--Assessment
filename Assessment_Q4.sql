-----Question 4
-----Customer Lifetime Value (CLV) Estimation

WITH transaction_stats AS (
    SELECT
        s.owner_id, -- Identifier for the owner of the savings account
        COUNT(*) AS total_transactions, -- Count of all transactions for each owner
        AVG(0.001 * s.confirmed_amount) AS avg_profit_per_transaction -- Calculate the average profit per transaction (assuming 'confirmed_amount' needs to be multiplied by 0.001 to represent profit)
    FROM
        savings_savingsaccount s -- Alias the 'savings_savingsaccount' table as 's'
    GROUP BY
        s.owner_id -- Group by owner ID to aggregate transaction data per owner
),
tenure_stats AS (
    SELECT
        u.id AS owner_id, -- Identifier for the user
        DATEDIFF(MONTH, u.date_joined, GETDATE()) AS tenure_months -- Calculate the tenure of each user in months based on their join date
    FROM
        users_customuser u -- Alias the 'users_customuser' table as 'u'
),
clv_estimate AS (
    SELECT
        t.owner_id, -- Identifier for the owner
        te.tenure_months, -- Tenure of the customer in months
        t.total_transactions, -- Total number of transactions for the customer
        t.avg_profit_per_transaction, -- Average profit per transaction for the customer
        -- CLV formula: (Average Transactions per Month) * (Average Profit per Transaction) * (Customer Lifespan in Months)
        -- Assuming a 12-month lifespan for simplicity in this calculation
        ROUND(
            (CAST(t.total_transactions AS FLOAT) / NULLIF(te.tenure_months, 0)) -- Calculate the average number of transactions per month
            * 12 * t.avg_profit_per_transaction, 2 -- Multiply by an assumed lifespan of 12 months and the average profit per transaction
        ) AS estimated_clv -- Estimated Customer Lifetime Value
    FROM
        transaction_stats t -- Alias the 'transaction_stats' CTE as 't'
    JOIN
        tenure_stats te ON t.owner_id = te.owner_id -- Join 'transaction_stats' with 'tenure_stats' on the owner ID
)
SELECT
    c.owner_id, -- Identifier for the owner
    c.tenure_months, -- Tenure of the customer in months
    c.total_transactions, -- Total number of transactions
    ROUND(c.avg_profit_per_transaction, 4) AS avg_profit_per_transaction, -- Average profit per transaction
    c.estimated_clv -- Estimated Customer Lifetime Value
FROM
    clv_estimate c -- Alias the 'clv_estimate' CTE as 'c'
ORDER BY
    c.estimated_clv DESC; -- Order the results by estimated CLV in descending order (highest CLV first)