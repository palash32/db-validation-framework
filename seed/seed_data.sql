-- ============================================================
-- seed_data.sql
-- Populates the test_hrms database with sample data for
-- payroll, attendance, leave, and integrity validation tests.
-- ============================================================

-- ----------------------------------------
-- Schema setup
-- ----------------------------------------

DROP TABLE IF EXISTS payroll_records;
DROP TABLE IF EXISTS leave_records;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    department    VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL,
    hire_date     DATE         NOT NULL
);

CREATE TABLE payroll_records (
    payroll_id     INT PRIMARY KEY AUTO_INCREMENT,
    employee_id    INT            NOT NULL,
    month          VARCHAR(7)     NOT NULL,   -- e.g. '2024-03'
    gross_amount   DECIMAL(12,2),
    tax_deduction  DECIMAL(12,2),
    net_amount     DECIMAL(12,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE leave_records (
    leave_id      INT PRIMARY KEY AUTO_INCREMENT,
    employee_id   INT          NOT NULL,
    leave_type    VARCHAR(20)  NOT NULL,   -- 'annual', 'sick', 'casual'
    start_date    DATE         NOT NULL,
    end_date      DATE         NOT NULL,
    status        VARCHAR(20)  NOT NULL DEFAULT 'pending',  -- 'pending','approved','rejected'
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE attendance (
    attendance_id  INT PRIMARY KEY AUTO_INCREMENT,
    employee_id    INT          NOT NULL,
    attendance_date DATE        NOT NULL,
    status         VARCHAR(10)  NOT NULL,  -- 'present','absent','half-day'
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- ----------------------------------------
-- Employees  (6 employees across 3 depts)
-- ----------------------------------------

INSERT INTO employees (employee_id, first_name, last_name, department, email, hire_date) VALUES
(101, 'Aarav',   'Sharma',  'Engineering', 'aarav.sharma@company.com',  '2022-01-15'),
(102, 'Priya',   'Patel',   'Engineering', 'priya.patel@company.com',   '2021-06-01'),
(103, 'Rahul',   'Verma',   'Finance',     'rahul.verma@company.com',   '2023-03-10'),
(104, 'Sneha',   'Gupta',   'Finance',     'sneha.gupta@company.com',   '2020-11-20'),
(105, 'Vikram',  'Singh',   'HR',          'vikram.singh@company.com',  '2022-08-05'),
(106, 'Ananya',  'Reddy',   'HR',          'ananya.reddy@company.com',  '2023-09-12');

-- ----------------------------------------
-- Payroll records  (2024-03 — main test month)
-- ----------------------------------------

-- Employee 101: gross 55000, tax 5500 (10%), net 49500
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(101, '2024-03', 55000.00, 5500.00, 49500.00);

-- Employee 102: gross 62000, tax 7440 (12%), net 54560
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(102, '2024-03', 62000.00, 7440.00, 54560.00);

-- Employee 103: gross 48000, tax 4800 (10%), net 43200
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(103, '2024-03', 48000.00, 4800.00, 43200.00);

-- Employee 104: gross 51000, tax 5100 (10%), net 45900
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(104, '2024-03', 51000.00, 5100.00, 45900.00);

-- Employee 105: gross 45000, tax 4500 (10%), net 40500
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(105, '2024-03', 45000.00, 4500.00, 40500.00);

-- Employee 106: gross 43000, tax 4300 (10%), net 38700
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(106, '2024-03', 43000.00, 4300.00, 38700.00);

-- Additional month for employee 101 (2024-02) — not used in main tests
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(101, '2024-02', 55000.00, 5500.00, 49500.00);

-- NOTE: No NULL salary records exist — PAY-03 should return zero rows

-- ----------------------------------------
-- Leave records
-- ----------------------------------------

-- ATT-01 seed: Employee 101 has 3 approved annual leaves
INSERT INTO leave_records (employee_id, leave_type, start_date, end_date, status) VALUES
(101, 'annual',  '2024-03-04', '2024-03-06', 'approved'),   -- 3 days
(101, 'sick',    '2024-03-15', '2024-03-15', 'approved'),   -- 1 day
(102, 'annual',  '2024-03-11', '2024-03-12', 'approved'),   -- 2 days
(103, 'casual',  '2024-03-20', '2024-03-20', 'pending'),    -- 1 day (pending, not counted)
(104, 'annual',  '2024-03-01', '2024-03-03', 'approved'),   -- 3 days
(105, 'sick',    '2024-03-18', '2024-03-19', 'rejected');   -- 2 days (rejected, not counted)

-- ATT-02 seed: NO overlapping leave entries exist for the same employee
-- (if an overlap existed the test would fail, which is the correct behaviour)

-- ----------------------------------------
-- Attendance records  (2024-03, first week)
-- ----------------------------------------

INSERT INTO attendance (employee_id, attendance_date, status) VALUES
(101, '2024-03-01', 'present'),
(101, '2024-03-02', 'present'),
(101, '2024-03-03', 'absent'),
(102, '2024-03-01', 'present'),
(102, '2024-03-02', 'half-day'),
(102, '2024-03-03', 'present'),
(103, '2024-03-01', 'present'),
(103, '2024-03-02', 'present'),
(103, '2024-03-03', 'present'),
(104, '2024-03-01', 'absent'),
(104, '2024-03-02', 'present'),
(104, '2024-03-03', 'present'),
(105, '2024-03-01', 'present'),
(105, '2024-03-02', 'present'),
(106, '2024-03-01', 'present'),
(106, '2024-03-02', 'present'),
(106, '2024-03-03', 'present');

-- ============================================================
-- Integrity edge-case data
-- ============================================================

-- INT-01: Orphaned foreign key test
-- We insert a payroll record referencing employee_id 999 that
-- does NOT exist in the employees table.
-- We must temporarily disable FK checks to seed this bad data.
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(999, '2024-03', 10000.00, 1000.00, 9000.00);
SET FOREIGN_KEY_CHECKS = 1;

-- INT-02: NOT NULL violation test
-- All mandatory columns in employees are NOT NULL, so no NULLs
-- can be inserted there. We test on payroll_records.gross_amount
-- which allows NULL.
INSERT INTO payroll_records (employee_id, month, gross_amount, tax_deduction, net_amount) VALUES
(101, '2024-04', NULL, NULL, NULL);

-- INT-03: Duplicate primary key test
-- We create a separate audit table to demonstrate the check,
-- since InnoDB prevents actual PK duplicates in real tables.
DROP TABLE IF EXISTS audit_log;
CREATE TABLE audit_log (
    log_id     INT,           -- intentionally NOT a PK, to allow dupes
    action     VARCHAR(50),
    created_at DATETIME
);
INSERT INTO audit_log VALUES
(1, 'LOGIN',  '2024-03-01 09:00:00'),
(2, 'LOGOUT', '2024-03-01 17:00:00'),
(2, 'LOGOUT', '2024-03-01 17:00:00'),   -- duplicate log_id
(3, 'LOGIN',  '2024-03-02 09:00:00');
