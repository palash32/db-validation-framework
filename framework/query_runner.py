"""
query_runner.py
───────────────
Reads a .sql file from disk and executes it against the database,
returning the result set as a pandas DataFrame.
"""

import pandas as pd
from sqlalchemy import text


def run_query(engine, sql_path: str) -> pd.DataFrame:
    """
    Execute a SQL file and return the result as a DataFrame.

    Args:
        engine:   SQLAlchemy engine (from db_connector.get_connection)
        sql_path: Path to a .sql file containing a single SELECT query

    Returns:
        pd.DataFrame with the query results
    """
    with open(sql_path, "r") as f:
        raw_sql = f.read()

    with engine.connect() as conn:
        df = pd.read_sql(text(raw_sql), conn)

    return df
