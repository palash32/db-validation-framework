-- INT-03: Duplicate primary key detection
-- Checks the audit_log table for duplicate log_id values.
-- Expected: log_id 2 appears twice.

SELECT log_id, COUNT(*) AS occurrence_count
FROM audit_log
GROUP BY log_id
HAVING COUNT(*) > 1
ORDER BY log_id;
