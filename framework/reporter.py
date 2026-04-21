"""
reporter.py
───────────
Utilities for pytest-html report customisation.

Import the hooks from this module into conftest.py to:
  - Set a custom report title
  - Add environment metadata (DB host, environment, timestamp)
  - Generate timestamped report file paths
"""

import os
import pathlib
from datetime import datetime


_PROJECT_ROOT = pathlib.Path(__file__).resolve().parent.parent
REPORTS_DIR = _PROJECT_ROOT / "reports"


def get_report_path() -> str:
    """
    Return a timestamped path for the HTML report.

    Example: reports/report_20240321_143022.html
    """
    REPORTS_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return str(REPORTS_DIR / f"report_{timestamp}.html")


def get_environment_metadata() -> list[tuple[str, str]]:
    """
    Return environment metadata pairs for the pytest-html Environment table.
    """
    import yaml

    env = os.getenv("ENV", "local")
    config_path = _PROJECT_ROOT / "config" / "db_config.yaml"

    try:
        with open(config_path, "r") as f:
            config = yaml.safe_load(f)[env]
        db_host = config.get("host", "unknown")
        db_name = config.get("database", "unknown")
    except Exception:
        db_host = "unknown"
        db_name = "unknown"

    return [
        ("Environment", env),
        ("DB Host", db_host),
        ("Database", db_name),
        ("Timestamp", datetime.now().strftime("%Y-%m-%d %H:%M:%S")),
    ]
