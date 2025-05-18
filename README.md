# DataAnalytics--Assessment

# SQL Solutions

This document outlines the approach taken to solve the four SQL assessment questions.

## Per-Question Explanations

### Question 1: High-Value Customers with Multiple Products

**Approach:**

The goal of this query was to identify high-value customers who hold both regular savings and investment fund products. To achieve this, I performed the following steps:

1.  **Joined Tables:** I joined the `users_customuser`, `plans_plan`, and `savings_savingsaccount` tables using the `owner_id` to link customer information with their plan details and savings account balances.
2.  **Counted Product Types:** I used conditional `COUNT(DISTINCT CASE WHEN ... THEN ... END)` statements to count the number of distinct regular savings plans (`is_regular_savings = 1`) and investment fund plans (`is_a_fund = 1`) for each customer.
3.  **Calculated Total Deposits:** I summed the `confirmed_amount` from the `savings_savingsaccount` table for each customer and converted it from kobo to naira by dividing by 100.0. The result was rounded to two decimal places.
4.  **Filtered for Multiple Products:** The `WHERE` clause ensured that only customers with at least one savings or investment plan were considered. The `HAVING` clause then specifically filtered these customers to include only those who had a count greater than zero for both savings and investment products.
5.  **Ordered by Total Deposits:** Finally, the results were ordered in descending order of `total_deposits` to easily identify the customers with the highest deposit values.

### Question 2: Customer Transactions Frequency

**Approach:**

This query aimed to categorize customers based on their monthly transaction frequency in their savings accounts. The approach involved these steps:

1.  **Monthly Transaction Count (CTE: `monthly_transactions`):** I first created a CTE to count the number of transactions per customer for each month. This was done by grouping the `savings_savingsaccount` table by `owner_id` and the first day of the `transaction_date` for each month using `DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1)`.
2.  **Average Monthly Transactions (CTE: `avg_tx_per_customer`):** Next, I calculated the average number of transactions per month for each customer by grouping the `monthly_transactions` CTE by `owner_id` and using the `AVG()` aggregate function.
3.  **Categorization (CTE: `categorized`):** I then categorized customers into 'High Frequency', 'Medium Frequency', and 'Low Frequency' based on their `avg_transactions_per_month` using a `CASE` statement.
4.  **Final Aggregation:** Finally, I selected the `frequency_category`, counted the number of customers in each category using `COUNT(*)`, and calculated the average transaction frequency for each category using `AVG()`, rounding the result to one decimal place. The results were grouped by `frequency_category`.

### Question 3: Account Inactivity Alert

**Approach:**

This query focused on identifying potentially inactive accounts based on the last transaction date in the `savings_savingsaccount` table. The steps were:

1.  **Joined Tables:** I joined the `plans_plan` and `savings_savingsaccount` tables on the `owner_id` to link plans with transaction history.
2.  **Found Last Transaction Date:** For each `owner_id`, I found the most recent `transaction_date` using the `MAX()` aggregate function.
3.  **Calculated Inactivity Days:** I used the `DATEDIFF(DAY, MAX(s.transaction_date), GETDATE())` function to calculate the number of days since the last transaction.
4.  **Filtered Inactive Accounts:** The `HAVING` clause filtered the results to include accounts where the `last_transaction_date` was either `NULL` (meaning no transactions ever occurred) or the `inactivity_days` were greater than 365 (one year).
5.  **Ordered by Inactivity:** The results were ordered by `inactivity_days` in descending order to show the most inactive accounts first.

    *Note: The initial comment in the provided query mentioned finding customers with more than 3 withdrawals. However, the database schema provided does not include a specific 'withdrawals' table or a way to directly track the number of withdrawals. Therefore, the query was adapted to identify inactivity based on the last transaction date.*

### Question 4: Customer Lifetime Value (CLV) Estimation

**Approach:**

This query aimed to estimate a simplified Customer Lifetime Value (CLV) for each customer based on their transaction history and tenure. The steps involved:

1.  **Transaction Statistics (CTE: `transaction_stats`):** I calculated the total number of transactions (`COUNT(*)`) and the average profit per transaction (`AVG(0.001 * s.confirmed_amount)`) for each customer from the `savings_savingsaccount` table. An assumption was made that `0.001 * confirmed_amount` represents the profit per transaction.
2.  **Customer Tenure (CTE: `tenure_stats`):** I calculated the tenure of each customer in months using the `DATEDIFF(MONTH, u.date_joined, GETDATE())` function from the `users_customuser` table.
3.  **CLV Estimation (CTE: `clv_estimate`):** I then combined the transaction statistics and tenure to estimate the CLV. A simplified formula was used: `(Average Transactions per Month) * (Average Profit per Transaction) * (Assumed Customer Lifespan in Months)`. An assumed customer lifespan of 12 months was used for this estimation. The result was rounded to two decimal places.
4.  **Final Selection:** Finally, I selected the `owner_id`, `tenure_months`, `total_transactions`, `avg_profit_per_transaction`, and the `estimated_clv`, ordering the results by `estimated_clv` in descending order to identify customers with the highest potential lifetime value.

## Challenges

During this assessment, I encountered the following challenges:

* **Misleading Comment in Question 3:** The initial comment in the provided code for Question 3 suggested identifying customers with more than 3 withdrawals. However, the provided database schema lacked a specific table or column to track withdrawals directly.
    * **Resolution:** I analyzed the available tables and columns and adapted the query to identify potentially inactive accounts based on the last transaction date, which is a common approach for flagging dormant users when withdrawal data is not explicitly available. I also added a note in the comments to clarify this discrepancy.
* **Interpreting 'Profit' in CLV Calculation:** Question 4 required estimating CLV. The provided `savings_savingsaccount` table had an `amount` or `confirmed_amount` column, but no explicit profit information.
    * **Resolution:** I made an assumption that a small percentage (0.1% or multiplying by 0.001) of the `confirmed_amount` could represent a simplified profit per transaction for the purpose of this estimation. This assumption was clearly documented in the comments within the query. In a real-world scenario, I would seek clarification on how profit is calculated.
* **Simplified CLV Formula:** The time constraints of an assessment often require using a simplified CLV formula.
    * **Resolution:** I used a basic formula incorporating average monthly transactions and an assumed customer lifespan of 12 months. In a production environment, a more sophisticated CLV model considering factors like churn rate, customer acquisition cost, and varying customer lifespans would be more appropriate. This limitation was implicitly understood within the context of the assessment.

Despite these challenges, I was able to develop SQL queries that addressed the core objectives of each question based on the provided data and common data analysis techniques.
