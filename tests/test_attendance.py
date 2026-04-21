"""
test_attendance.py
──────────────────
Attendance & leave module validation tests.

ATT-01  Approved leave days calculated correctly
ATT-02  No overlapping leave entries for the same employee
"""

import pytest
from framework.query_runner import run_query
from framework.comparator import compare


class TestAttendance:
    """Attendance and leave data validation suite."""

    # ── ATT-01 ───────────────────────────────────────────────────────
    def test_leave_balance(self, db_engine):
        """Total approved leave days per employee match expected values."""
        result = run_query(db_engine, "queries/attendance/test_leave_balance.sql")
        outcome = compare(result, "queries/attendance/test_leave_balance.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"

    # ── ATT-02 ───────────────────────────────────────────────────────
    def test_overlapping_leaves(self, db_engine):
        """No employee should have overlapping approved leave records."""
        result = run_query(
            db_engine, "queries/attendance/test_overlapping_leaves.sql"
        )
        outcome = compare(result, "queries/attendance/test_overlapping_leaves.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"
