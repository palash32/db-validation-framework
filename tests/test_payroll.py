"""
test_payroll.py
───────────────
Payroll module validation tests.

PAY-01  Monthly gross totals per employee
PAY-02  Tax deduction calculation accuracy
PAY-03  No NULL salary records in active month
"""

import pytest
from framework.query_runner import run_query
from framework.comparator import compare


class TestPayroll:
    """Payroll data validation suite."""

    # ── PAY-01 ───────────────────────────────────────────────────────
    def test_gross_totals(self, db_engine):
        """Monthly gross total per employee matches expected seed data."""
        result = run_query(db_engine, "queries/payroll/test_gross_totals.sql")
        outcome = compare(result, "queries/payroll/test_gross_totals.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"

    # ── PAY-02 ───────────────────────────────────────────────────────
    def test_tax_deduction(self, db_engine):
        """Tax deduction and derived tax rate match within 0.01 tolerance."""
        result = run_query(db_engine, "queries/payroll/test_tax_deduction.sql")
        outcome = compare(
            result,
            "queries/payroll/test_tax_deduction.csv",
            tolerance=0.01,
        )
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"

    # ── PAY-03 ───────────────────────────────────────────────────────
    def test_null_salary(self, db_engine):
        """No employee should have NULL gross_amount in the active month."""
        result = run_query(db_engine, "queries/payroll/test_null_salary.sql")
        outcome = compare(result, "queries/payroll/test_null_salary.csv")
        assert outcome["status"] == "PASS", f"Data mismatch:\n{outcome['diff']}"
