"""
test_integrity.py
─────────────────
Data integrity validation tests.

INT-01  Orphaned foreign keys in payroll_records
INT-02  NOT NULL violations in mandatory payroll fields
INT-03  Duplicate primary-key values in audit_log
"""

import pytest
from framework.query_runner import run_query
from framework.comparator import compare


class TestIntegrity:
    """Data integrity validation suite."""

    # ── INT-01 ───────────────────────────────────────────────────────
    def test_foreign_keys(self, db_engine):
        """Detect orphaned employee_id in payroll with no matching employee."""
        result = run_query(db_engine, "queries/integrity/test_foreign_keys.sql")
        outcome = compare(result, "queries/integrity/test_foreign_keys.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"

    # ── INT-02 ───────────────────────────────────────────────────────
    def test_not_null(self, db_engine):
        """No NULL values in mandatory payroll amount columns for the reporting month."""
        result = run_query(db_engine, "queries/integrity/test_not_null.sql")
        outcome = compare(result, "queries/integrity/test_not_null.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"

    # ── INT-03 ───────────────────────────────────────────────────────
    def test_duplicate_keys(self, db_engine):
        """Detect duplicate log_id values in the audit_log table."""
        result = run_query(db_engine, "queries/integrity/test_duplicate_keys.sql")
        outcome = compare(result, "queries/integrity/test_duplicate_keys.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"
