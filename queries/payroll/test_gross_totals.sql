-- PAY-01: Monthly gross total per employee for March 2024
-- Expected: one row per employee with their gross total for the month

SELECT employee_id, SUM(gross_amount) AS total
FROM payroll_records
WHERE month = '2024-03'
  AND gross_amount IS NOT NULL
GROUP BY employee_id
ORDER BY employee_id;
