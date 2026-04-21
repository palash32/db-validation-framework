-- ATT-02: Overlapping leave entries
-- Detects if any employee has two approved leave records where the
-- date ranges overlap. Expected: zero rows (no overlaps).

SELECT a.employee_id,
       a.leave_id   AS leave_a,
       b.leave_id   AS leave_b,
       a.start_date AS a_start,
       a.end_date   AS a_end,
       b.start_date AS b_start,
       b.end_date   AS b_end
FROM leave_records a
JOIN leave_records b
  ON  a.employee_id = b.employee_id
  AND a.leave_id    < b.leave_id
  AND a.start_date <= b.end_date
  AND a.end_date   >= b.start_date
WHERE a.status = 'approved'
  AND b.status = 'approved';
