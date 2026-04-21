-- INT-02: NOT NULL field violations for March 2024
-- Checks for NULL values in fields that should be mandatory:
--   payroll_records.gross_amount, tax_deduction, net_amount
-- Expected: zero rows for the reporting month (data is clean)

SELECT payroll_id, employee_id, month, gross_amount, tax_deduction, net_amount
FROM payroll_records
WHERE month = '2024-03'
  AND (gross_amount  IS NULL
   OR  tax_deduction IS NULL
   OR  net_amount    IS NULL)
ORDER BY payroll_id;
