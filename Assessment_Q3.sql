-- Assessment_Q3.
---Account Inactivity Alert
-- Find customers with more than 3 withdrawals and show total withdrawn amount

-- The initial comment in the query is slightly misleading.
-- The query below actually identifies potentially inactive accounts based on the last transaction date,
-- not specifically customers with more than 3 withdrawals.
-- There is no 'withdrawals' table or column in the provided schema to directly count withdrawals.

EXEC sp_help plans_plan; -- Display information about the 'plans_plan' table
EXEC sp_help savings_savingsaccount; -- Display information about the 'savings_savingsaccount' table

SELECT
    p.id AS plan_id, -- Identifier for the plan
    p.owner_id, -- Identifier for the owner of the plan
    'Savings' AS type, -- Indicates the type of plan (assuming it relates to savings)
    MAX(s.transaction_date) AS last_transaction_date, -- The most recent transaction date for this owner across their savings accounts
    DATEDIFF(DAY, MAX(s.transaction_date), GETDATE()) AS inactivity_days -- Calculate the number of days since the last transaction
FROM
    plans_plan p -- Alias the 'plans_plan' table as 'p'
LEFT JOIN
    savings_savingsaccount s
    ON p.owner_id = s.owner_id -- Join 'plans_plan' with 'savings_savingsaccount' on the owner ID
GROUP BY
    p.id, p.owner_id -- Group the results by plan ID and owner ID to find the latest transaction per owner
HAVING
    MAX(s.transaction_date) IS NULL -- Include owners who have never had a transaction
    OR DATEDIFF(DAY, MAX(s.transaction_date), GETDATE()) > 365 -- Include owners whose last transaction was more than 365 days ago (1 year)
ORDER BY
    inactivity_days DESC; -- Order the results by the number of inactivity days in descending order (most inactive first)


EXEC sp_help savings_savingsaccount;
sp_help savings_savingsaccount;
WITH transaction_stats AS (
    SELECT
        s.owner_id, -- Identifier for the owner of the savings account
        COUNT(*) AS total_transactions, -- Count of all transactions for each owner
        AVG(0.001 * s.amount) AS avg_profit_per_transaction -- Calculate the average profit per transaction (assuming 'amount' needs to be multiplied by 0.001 to represent profit)
    FROM
        savings_savingsaccount s -- Alias the 'savings_savingsaccount' table as 's'
    GROUP BY
        s.owner_id -- Group by owner ID to aggregate transaction data per owner
),
tenure_stats AS (
    SELECT
        u.id AS owner_id, -- Identifier for the user
        DATEDIFF(MONTH, u.date_joined, GETDATE()) AS tenure_months -- Calculate the tenure of each user in months
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
            (CAST(t.total_transactions AS FLOAT) / NULLIF(te.tenure_months, 0)) -- Average transactions per month
            * 12 * t.avg_profit_per_transaction, 2 -- Multiply by 12 (assumed lifespan in months) and average profit
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
WITH transaction_stats AS (
    SELECT
        s.owner_id,
        COUNT(*) AS total_transactions,
        AVG(0.001 * s.amount) AS avg_profit_per_transaction
    FROM
        savings_savingsaccount s
    GROUP BY
        s.owner_id
),
tenure_stats AS (
    SELECT
        u.id AS owner_id,
        DATEDIFF(MONTH, u.date_joined, GETDATE()) AS tenure_months
    FROM
        users_customuser u
),
clv_estimate AS (
    SELECT
        t.owner_id,
        te.tenure_months,
        t.total_transactions,
        t.avg_profit_per_transaction,
        -- CLV formula
        ROUND(
            (CAST(t.total_transactions AS FLOAT) / NULLIF(te.tenure_months, 0))
            * 12 * t.avg_profit_per_transaction, 2
        ) AS estimated_clv
    FROM
        transaction_stats t
    JOIN
        tenure_stats te ON t.owner_id = te.owner_id
)
SELECT
    c.owner_id,
    c.tenure_months,
    c.total_transactions,
    ROUND(c.avg_profit_per_transaction, 4) AS avg_profit_per_transaction,
    c.estimated_clv
FROM
    clv_estimate c
ORDER BY
    c.estimated_clv DESC;