-- PAY-02: Tax deduction validation for March 2024
-- Verifies that tax_deduction is calculated correctly
-- (compared with tolerance in the test)

SELECT employee_id, gross_amount, tax_deduction,
       ROUND(tax_deduction / gross_amount * 100, 2) AS tax_rate_pct
FROM payroll_records
WHERE month = '2024-03'
  AND gross_amount IS NOT NULL
ORDER BY employee_id;
