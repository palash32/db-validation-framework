"""
comparator.py
─────────────
Compares actual query results (DataFrame) against an expected CSV file.
Returns a dict with pass/fail status and diff details on mismatch.
"""

import pandas as pd


def compare(actual: pd.DataFrame, expected_csv: str, tolerance: float = 0.0) -> dict:
    """
    Compare a query result DataFrame against an expected CSV dataset.

    Args:
        actual:       DataFrame returned by query_runner.run_query()
        expected_csv: Path to the .csv file with expected data
        tolerance:    Absolute numeric tolerance for float comparisons
                      (e.g., 0.01 for penny-level precision). Default 0.0 = exact match.

    Returns:
        dict with keys:
            status – "PASS" or "FAIL"
            diff   – None on pass, or a string describing the mismatch
    """
    expected = pd.read_csv(expected_csv)

    # Align column order to the expected CSV
    try:
        actual = actual[expected.columns]
    except KeyError as e:
        return {
            "status": "FAIL",
            "diff": f"Column mismatch — missing in actual result: {e}",
        }

    # Reset indices for clean comparison
    actual = actual.reset_index(drop=True)
    expected = expected.reset_index(drop=True)

    try:
        pd.testing.assert_frame_equal(
            actual,
            expected,
            check_dtype=False,
            atol=tolerance,
        )
        return {"status": "PASS", "diff": None}
    except AssertionError as e:
        return {"status": "FAIL", "diff": str(e)}
