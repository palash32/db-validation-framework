-- ATT-01: Leave balance consumed after approval
-- Returns the total approved leave days per employee for March 2024
-- (end_date - start_date + 1 = number of days)

SELECT employee_id,
       SUM(DATEDIFF(end_date, start_date) + 1) AS approved_leave_days
FROM leave_records
WHERE status = 'approved'
  AND start_date >= '2024-03-01'
  AND end_date   <= '2024-03-31'
GROUP BY employee_id
ORDER BY employee_id;
