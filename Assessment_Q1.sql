-- Assessment_Q1
-- High-Value Customers with Multiple Products

SELECT
    u.id AS owner_id, -- Unique identifier for the customer
    u.name, -- Name of the customer
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count, -- Count of distinct regular savings plans for each customer
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count, -- Count of distinct investment fund plans for each customer
    ROUND(SUM(CAST(sa.confirmed_amount AS FLOAT)) / 100.0, 2) AS total_deposits -- Total confirmed deposits for the customer, converting kobo to naira
FROM
    users_customuser u -- Alias the users_customuser table as 'u'
INNER JOIN
    plans_plan p ON u.id = p.owner_id -- Join users_customuser with plans_plan on the owner_id
INNER JOIN
    savings_savingsaccount sa ON u.id = sa.owner_id -- Join users_customuser with savings_savingsaccount on the owner_id
WHERE
    (p.is_regular_savings = 1 OR p.is_a_fund = 1) -- Filter for customers who have at least one savings or investment plan
GROUP BY
    u.id, u.name -- Group the results by customer ID and name to aggregate data per customer
HAVING
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) > 0 AND
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) > 0 -- Filter out customers who don't have at least one of each product type (savings and investment)
ORDER BY
    total_deposits DESC; -- Order the results by total deposits in descending order to find high-value customers first