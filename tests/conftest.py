"""
conftest.py
───────────
Shared Pytest fixtures and pytest-html report hooks.

Provides:
  - db_engine (session-scoped) — SQLAlchemy engine for all tests
  - pytest-html customisations  — title, environment metadata
"""

import pytest
from dotenv import load_dotenv

from framework.db_connector import get_connection
from framework.reporter import get_environment_metadata

# ── Load .env at the start of the test session ──────────────────────
load_dotenv()


# ── Fixtures ─────────────────────────────────────────────────────────

@pytest.fixture(scope="session")
def db_engine():
    """
    Create a single SQLAlchemy engine shared across all tests in the session.
    The engine is disposed after all tests complete.
    """
    engine = get_connection()
    yield engine
    engine.dispose()


# ── pytest-html hooks ────────────────────────────────────────────────

def pytest_html_report_title(report):
    """Set a custom title for the HTML report."""
    report.title = "DB Validation Report — HRMS"


def pytest_configure(config):
    """Add environment metadata to the HTML report."""
    try:
        metadata = config._metadata
    except AttributeError:
        # pytest-metadata not installed or metadata not available
        return

    for key, value in get_environment_metadata():
        metadata[key] = value
