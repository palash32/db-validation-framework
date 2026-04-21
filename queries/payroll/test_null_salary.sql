-- PAY-03: NULL salary records check
-- Asserts: no employee should have a NULL gross_amount in active months
-- Expected: zero rows (empty result = PASS)

SELECT employee_id, month, gross_amount
FROM payroll_records
WHERE gross_amount IS NULL
  AND month = '2024-03';
