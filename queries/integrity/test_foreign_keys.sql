-- INT-01: Orphaned foreign keys
-- Finds payroll records whose employee_id does NOT exist in the employees table.
-- Expected: employee_id 999 (seeded as an orphan)

SELECT p.employee_id, p.month, p.gross_amount
FROM payroll_records p
LEFT JOIN employees e ON p.employee_id = e.employee_id
WHERE e.employee_id IS NULL
ORDER BY p.employee_id;
