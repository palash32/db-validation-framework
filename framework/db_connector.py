"""
db_connector.py
───────────────
Creates a SQLAlchemy engine connected to MySQL (local or AWS RDS).

Connection parameters (host, port, database) are read from config/db_config.yaml.
Credentials (DB_USER, DB_PASSWORD) are read from environment variables.
The target environment is selected via the ENV variable (default: "local").
"""

import os
import pathlib
import yaml
from sqlalchemy import create_engine

# Resolve project root (one level up from framework/)
_PROJECT_ROOT = pathlib.Path(__file__).resolve().parent.parent


def get_connection():
    """
    Build and return a SQLAlchemy engine for the active environment.

    Environment variables used:
        ENV          – "local" (default) or "rds"
        DB_USER      – MySQL username
        DB_PASSWORD  – MySQL password

    Returns:
        sqlalchemy.engine.Engine
    """
    env = os.getenv("ENV", "local")

    config_path = _PROJECT_ROOT / "config" / "db_config.yaml"
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)[env]

    user = os.getenv("DB_USER", "root")
    password = os.getenv("DB_PASSWORD", "")

    connection_url = (
        f"mysql+mysqlconnector://{user}:{password}"
        f"@{config['host']}:{config['port']}/{config['database']}"
    )

    engine = create_engine(connection_url, echo=False)
    return engine
