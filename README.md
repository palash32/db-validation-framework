# DB Validation Framework

**Automated SQL-based data integrity testing for MySQL & AWS RDS**

A Python + Pytest framework that executes SQL validation scripts against a MySQL database, compares the results to expected CSV datasets, and generates HTML reports — integrated with GitHub Actions for nightly CI runs.

---

## Architecture

```
┌──────────────┐     ┌───────────────┐     ┌──────────────────┐
│  .sql query  │────▶│ query_runner   │────▶│  MySQL / AWS RDS │
│  (queries/)  │     │ (pd.read_sql)  │     │    Database       │
└──────────────┘     └───────┬───────┘     └──────────────────┘
                             │ DataFrame
                             ▼
┌──────────────┐     ┌───────────────┐     ┌──────────────────┐
│  .csv file   │────▶│  comparator   │────▶│  PASS / FAIL     │
│  (expected)  │     │ (assert_frame │     │  + diff details  │
└──────────────┘     │  _equal)      │     └────────┬─────────┘
                     └───────────────┘              │
                                                    ▼
                                           ┌──────────────────┐
                                           │  pytest-html     │
                                           │  HTML Report     │
                                           └──────────────────┘
```

---

## Features

- **SQL-driven assertions** — write validation logic in plain `.sql` files
- **CSV expected datasets** — version-control your expected results alongside queries
- **Row-by-row diff** — pinpoint exactly which rows/columns differ on failure
- **Numeric tolerance** — support for float comparisons (e.g., tax calculations)
- **Environment switching** — toggle between `local` MySQL and `rds` via a single env var
- **HTML reports** — auto-generated, self-contained reports via `pytest-html`
- **CI/CD ready** — GitHub Actions workflow with MySQL service container
- **Seed data included** — one-command database setup for reproducible testing

---

## Folder Structure

```
db-validation-framework/
│
├── config/
│   ├── db_config.yaml          # DB connection params (host, port, db name)
│   └── env.example             # Template for .env (credentials never committed)
│
├── queries/
│   ├── payroll/
│   │   ├── test_gross_totals.sql / .csv
│   │   ├── test_tax_deduction.sql / .csv
│   │   └── test_null_salary.sql / .csv
│   ├── attendance/
│   │   ├── test_leave_balance.sql / .csv
│   │   └── test_overlapping_leaves.sql / .csv
│   └── integrity/
│       ├── test_foreign_keys.sql / .csv
│       ├── test_not_null.sql / .csv
│       └── test_duplicate_keys.sql / .csv
│
├── framework/
│   ├── db_connector.py         # SQLAlchemy engine (MySQL / AWS RDS)
│   ├── query_runner.py         # Execute .sql → DataFrame
│   ├── comparator.py           # Diff actual vs expected CSV
│   └── reporter.py             # pytest-html report utilities
│
├── tests/
│   ├── conftest.py             # Fixtures (db_engine) + report hooks
│   ├── test_payroll.py         # PAY-01, PAY-02, PAY-03
│   ├── test_attendance.py      # ATT-01, ATT-02
│   └── test_integrity.py       # INT-01, INT-02, INT-03
│
├── seed/
│   └── seed_data.sql           # DDL + sample data for all test tables
│
├── reports/                    # Auto-generated HTML reports (gitignored)
│
├── .github/workflows/
│   └── nightly_validation.yml  # GitHub Actions CI (nightly + on push)
│
├── requirements.txt
├── README.md
└── .env                        # DB credentials (never committed)
```

---

## Quick Start

### Prerequisites

- Python 3.10+
- MySQL 8.0 running locally (or Docker)

### 1. Clone & install

```bash
git clone https://github.com/your-username/db-validation-framework.git
cd db-validation-framework
pip install -r requirements.txt
```

### 2. Set up the database

```bash
# Create the database (if it doesn't exist)
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS test_hrms;"

# Seed tables and sample data
mysql -u root -p test_hrms < seed/seed_data.sql
```

### 3. Configure credentials

```bash
# Copy the template and fill in your credentials
cp config/env.example .env
```

Edit `.env`:
```
DB_USER=root
DB_PASSWORD=your_password
ENV=local
```

### 4. Run the tests

```bash
pytest tests/ --html=reports/report.html --self-contained-html -v
```

---

## Test Scenarios

### Payroll Module

| Test ID | Validates | Expected Outcome |
|---------|-----------|-----------------|
| PAY-01 | Monthly gross total per employee | Matches seed data |
| PAY-02 | Tax deduction calculation | Within 0.01 tolerance |
| PAY-03 | NULL salary records in active month | Zero rows returned |

### Attendance Module

| Test ID | Validates | Expected Outcome |
|---------|-----------|-----------------|
| ATT-01 | Leave balance after approval | Decremented correctly |
| ATT-02 | Overlapping leave entries | No duplicate date ranges |

### Data Integrity

| Test ID | Validates | Expected Outcome |
|---------|-----------|-----------------|
| INT-01 | Orphaned foreign keys | Detects employee_id 999 |
| INT-02 | NOT NULL field violations | Zero NULL rows in reporting month |
| INT-03 | Duplicate primary keys | Detects log_id 2 duplicate |

---

## Adding New Tests

1. **Write the SQL query** → `queries/<module>/test_<name>.sql`
2. **Create the expected CSV** → `queries/<module>/test_<name>.csv` (same columns as the query output)
3. **Add a test function** in `tests/test_<module>.py`:

```python
def test_new_check(self, db_engine):
    result = run_query(db_engine, "queries/<module>/test_<name>.sql")
    outcome = compare(result, "queries/<module>/test_<name>.csv")
    assert outcome["status"] == "PASS", f"Mismatch:\n{outcome['diff']}"
```

4. Run: `pytest tests/ -v`

---

## Environment Switching

Switch between local MySQL and AWS RDS by changing the `ENV` variable:

```bash
# Local MySQL
export ENV=local

# AWS RDS
export ENV=rds
```

Update `config/db_config.yaml` with your RDS endpoint:

```yaml
rds:
  host: "your-instance.xxxx.us-east-1.rds.amazonaws.com"
  port: 3306
  database: "hrms_prod"
```

---

## CI/CD — GitHub Actions

The workflow (`.github/workflows/nightly_validation.yml`) runs:

- **On every push** to `main`
- **Nightly** at 02:00 UTC via cron schedule

### Pipeline steps:

1. Spin up MySQL 8.0 service container
2. Install Python dependencies
3. Seed the test database
4. Run `pytest` with HTML report generation
5. Upload the report as a build artifact

### Setting up secrets:

Go to **Settings → Secrets and variables → Actions** and add:
- `DB_USER`
- `DB_PASSWORD`

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Python 3.11 |
| Database | MySQL 8.0 / AWS RDS |
| Test runner | Pytest |
| Data handling | pandas + SQLAlchemy |
| Reporting | pytest-html |
| CI/CD | GitHub Actions |
| Config | PyYAML + python-dotenv |

---

## License

MIT
