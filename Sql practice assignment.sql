#Q1 Employees who earn more than their own manager
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    manager_id INT,
    salary INT,
    join_date DATE
);
INSERT INTO employees
    (emp_id, emp_name, dept_id, manager_id, salary, join_date)
VALUES
    (1, 'Ravi', 10, NULL, 150000, '2015-03-15'),
    (2, 'Anita', 10, 1, 90000, '2018-07-02'),
    (3, 'Vikram', 20, 1, 120000, '2016-11-21'),
    (4, 'Sneha', 20, 3, 95000, '2019-01-10'),
    (5, 'Karthik', 20, 3, 130000, '2020-05-05'),
    (6, 'Pooja', 30, 1, 70000, '2021-09-13'),
    (7, 'Rahul', 30, 6, 85000, '2022-02-28'),
    (8, 'Meena', 10, 1, 95000, '2023-06-18'),
    (9, 'Arun', 20, 3, 60000, '2024-03-01'),
    (10, 'Divya', NULL, 1, 78000, '2024-08-15');
    
    
    #Q2Employees earning more than the average salary of their department
SELECT
    e.emp_name AS emp_name,
    e.salary AS emp_salary,
    m.emp_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.emp_id;
    
    
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary,
    ROUND(dept_avg_salary, 2) AS dept_avg_salary
FROM (
    SELECT
        emp_id,
        emp_name,
        dept_id,
        salary,
        AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg_salary
    FROM employees
    WHERE dept_id IS NOT NULL
) e
WHERE salary > dept_avg_salary;

#Q3Third highest salary in each department
SELECT
    dept_id,
    emp_name,
    salary,
    rnk
FROM (
    SELECT
        dept_id,
        emp_name,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY dept_id
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
    WHERE dept_id IS NOT NULL
) e
WHERE rnk = 3;

#Q4 Departments with no employees, and employees with no department

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (10, 'Finance', 'Pune'),
    (20, 'Engineering', 'Bangalore'),
    (30, 'Sales', 'Mumbai'),
    (40, 'Legal', 'Delhi');
    
    SELECT
    d.dept_id,
    d.dept_name
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;

SELECT
    emp_id,
    emp_name
FROM employees
WHERE dept_id IS NULL;

SELECT
    dept_id,
    dept_name
FROM departments
WHERE dept_id NOT IN (
    SELECT dept_id
    FROM employees
);

#find records with no matching record


#Q5 Employee list with manager name, including the employee who has no manager

SELECT
    e.emp_id,
    e.emp_name,
    COALESCE(m.emp_name, 'No Manager') AS manager_name,
    TIMESTAMPDIFF(
        YEAR,
        e.join_date,
        '2024-09-30'
    ) AS years_with_company
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.emp_id;
    
#Q6 Number of direct reportees for every employee, including those with none
SELECT
    e.emp_id,
    e.emp_name,
    COUNT(m.emp_id) AS direct_reportees
FROM employees e
LEFT JOIN employees m
    ON e.emp_id = m.manager_id
GROUP BY
    e.emp_id,
    e.emp_name
ORDER BY
    direct_reportees DESC;

#Q7 Customers who bought Laptop but never bought Mouse
CREATE TABLE sales_order (
    order_id INT PRIMARY KEY,
    cust_id INT,
    cust_name VARCHAR(50),
    product VARCHAR(50),
    order_date DATE,
    amount INT
);

INSERT INTO sales_order
    (order_id, cust_id, cust_name, product, order_date, amount)
VALUES
    (1, 101, 'Amit', 'Laptop', '2024-01-10', 55000),
    (2, 101, 'Amit', 'Mouse', '2024-01-15', 800),
    (3, 102, 'Neha', 'Laptop', '2024-02-05', 62000),
    (4, 102, 'Neha', 'Keyboard', '2024-02-20', 1500),
    (5, 103, 'Raj', 'Mouse', '2024-03-01', 700),
    (6, 104, 'Simran', 'Laptop', '2024-03-12', 58000),
    (7, 104, 'Simran', 'Laptop', '2024-04-02', 61000),
    (8, 105, 'Kavya', 'Keyboard', '2024-04-18', 1200);
    
    
    SELECT DISTINCT
    s.cust_id,
    s.cust_name
FROM sales_order s
WHERE s.product = 'Laptop'
  AND NOT EXISTS (
      SELECT 1
      FROM sales_order m
      WHERE m.cust_id = s.cust_id
        AND m.product = 'Mouse'
  );
  
  SELECT
    cust_id,
    cust_name
FROM sales_order
GROUP BY
    cust_id,
    cust_name
HAVING
    SUM(CASE WHEN product = 'Laptop' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN product = 'Mouse' THEN 1 ELSE 0 END) = 0;
    
#Q8 Customers who ordered in both 2023 and 2024
    
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    cust_id INT,
    order_date DATE,
    amount INT
);

INSERT INTO orders
    (order_id, cust_id, order_date, amount)
VALUES
    (1, 101, '2023-04-11', 5000),
    (2, 101, '2024-02-19', 7000),
    (3, 102, '2023-06-05', 3000),
    (4, 102, '2023-11-23', 4500),
    (5, 103, '2024-01-08', 8000),
    (6, 103, '2024-05-30', 2500),
    (7, 104, '2023-02-14', 6000),
    (8, 104, '2024-08-09', 9000),
    (9, 104, '2024-09-01', 1000);
    
SELECT
    cust_id,
    SUM(CASE
        WHEN YEAR(order_date) = 2023 THEN 1
        ELSE 0
    END) AS orders_2023,

    SUM(CASE
        WHEN YEAR(order_date) = 2023 THEN amount
        ELSE 0
    END) AS amount_2023,

    SUM(CASE
        WHEN YEAR(order_date) = 2024 THEN 1
        ELSE 0
    END) AS orders_2024,

    SUM(CASE
        WHEN YEAR(order_date) = 2024 THEN amount
        ELSE 0
    END) AS amount_2024

FROM orders
GROUP BY cust_id
HAVING
    SUM(CASE WHEN YEAR(order_date) = 2023 THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN YEAR(order_date) = 2024 THEN 1 ELSE 0 END) > 0;
    
    
#Customers who ordered in ONLY ONE year    
-- HAVING
--     (
--         SUM(CASE WHEN YEAR(order_date) = 2023 THEN 1 ELSE 0 END) > 0
--         AND
--         SUM(CASE WHEN YEAR(order_date) = 2024 THEN 1 ELSE 0 END) = 0
--     )
--     OR
--     (
--         SUM(CASE WHEN YEAR(order_date) = 2023 THEN 1 ELSE 0 END) = 0
--         AND
--         SUM(CASE WHEN YEAR(order_date) = 2024 THEN 1 ELSE 0 END) > 0
--     );

#Q9 Classify employees into salary bands and count each band
SELECT
    emp_id,
    emp_name,
    salary,
    CASE
        WHEN salary <= 75000 THEN 'LOW'
        WHEN salary BETWEEN 75001 AND 100000 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS salary_band
FROM employees
ORDER BY
    CASE
        WHEN salary <= 75000 THEN 1
        WHEN salary BETWEEN 75001 AND 100000 THEN 2
        ELSE 3
    END;

SELECT
    salary_band,
    COUNT(*) AS emp_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM (
    SELECT
        salary,
        CASE
            WHEN salary <= 75000 THEN 'LOW'
            WHEN salary BETWEEN 75001 AND 100000 THEN 'MEDIUM'
            ELSE 'HIGH'
        END AS salary_band
    FROM employees
) e
GROUP BY salary_band
ORDER BY
    CASE
        WHEN salary_band = 'LOW' THEN 1
        WHEN salary_band = 'MEDIUM' THEN 2
        WHEN salary_band = 'HIGH' THEN 3
    END;
    
#Q10 Attendance summary - present, absent and leave days per employee
CREATE TABLE attendance (
    emp_id INT,
    emp_name VARCHAR(50),
    att_date DATE,
    status VARCHAR(1)
);
INSERT INTO attendance
    (emp_id, emp_name, att_date, status)
VALUES
    (1, 'Amit', '2024-07-01', 'P'),
    (1, 'Amit', '2024-07-02', 'P'),
    (1, 'Amit', '2024-07-03', 'A'),
    (1, 'Amit', '2024-07-04', 'P'),
    (1, 'Amit', '2024-07-05', 'L'),

    (2, 'Neha', '2024-07-01', 'P'),
    (2, 'Neha', '2024-07-02', 'A'),
    (2, 'Neha', '2024-07-03', 'A'),
    (2, 'Neha', '2024-07-04', 'P'),
    (2, 'Neha', '2024-07-05', 'P'),

    (3, 'Raj', '2024-07-01', 'P'),
    (3, 'Raj', '2024-07-02', 'P'),
    (3, 'Raj', '2024-07-03', 'P'),
    (3, 'Raj', '2024-07-04', 'P'),
    (3, 'Raj', '2024-07-05', 'P');
    
    SELECT
    emp_id,
    emp_name,

    SUM(CASE WHEN status = 'P' THEN 1 ELSE 0 END) AS present_days,

    SUM(CASE WHEN status = 'A' THEN 1 ELSE 0 END) AS absent_days,

    SUM(CASE WHEN status = 'L' THEN 1 ELSE 0 END) AS leave_days,

    ROUND(
        SUM(CASE WHEN status = 'P' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS attendance_pct

FROM attendance
GROUP BY
    emp_id,
    emp_name
HAVING
    (
        SUM(CASE WHEN status = 'P' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
    ) < 80;
    
    #Q11 Year-wise and month-wise sales summary
    CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    region VARCHAR(20),
    amount INT
);

INSERT INTO sales
    (sale_id, sale_date, region, amount)
VALUES
    (1, '2023-11-05', 'East', 12000),
    (2, '2023-11-22', 'West', 8000),
    (3, '2023-12-14', 'East', 15000),
    (4, '2024-01-09', 'North', 9000),
    (5, '2024-01-27', 'East', 11000),
    (6, '2024-02-03', 'West', 7000),
    (7, '2024-02-18', 'North', 13000),
    (8, '2024-02-28', 'East', 6000),
    (9, '2024-03-15', 'South', 10000);
    
    SELECT
    YEAR(sale_date) AS sale_year,
    MONTH(sale_date) AS sale_month_no,
    DATE_FORMAT(sale_date, '%b') AS sale_month,
    SUM(amount) AS total_amount,
    COUNT(*) AS txn_count,
    MAX(amount) AS max_sale
FROM sales
GROUP BY
    YEAR(sale_date),
    MONTH(sale_date),
    DATE_FORMAT(sale_date, '%b')
ORDER BY
    sale_year,
    sale_month_no;
    
   # Q12 Combine online and store sales - UNION, UNION ALL and items sold in both channels
   CREATE TABLE online_sales (
    item VARCHAR(50),
    qty INT
);
INSERT INTO online_sales (item, qty)
VALUES
    ('Shirt', 10),
    ('Jeans', 5),
    ('Shoes', 7),
    ('Watch', 3);
    
    CREATE TABLE store_sales (
    item VARCHAR(50),
    qty INT
);

INSERT INTO store_sales (item, qty)
VALUES
    ('Shirt', 8),
    ('Shoes', 2),
    ('Belt', 6),
    ('Cap', 4);
    
SELECT item
FROM online_sales

UNION

SELECT item
FROM store_sales;
    
#There are 6 rows because UNION removes duplicates.

SELECT item
FROM online_sales

UNION ALL

SELECT item
FROM store_sales;

SELECT
    o.item,
    o.qty AS online_qty,
    s.qty AS store_qty,
    o.qty + s.qty AS total_qty
FROM online_sales o
INNER JOIN store_sales s
    ON o.item = s.item;
    
SELECT
    o.item,
    o.qty AS online_qty,
    0 AS store_qty,
    o.qty AS total_qty
FROM online_sales o
LEFT JOIN store_sales s
    ON o.item = s.item
WHERE s.item IS NULL;

#Q13 Handle NULL commission while calculating total pay

CREATE TABLE emp_pay (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary INT,
    commission INT
);

INSERT INTO emp_pay (emp_id, emp_name, salary, commission)
VALUES
    (1, 'Amit', 50000, 5000),
    (2, 'Neha', 60000, NULL),
    (3, 'Raj', 45000, 3000),
    (4, 'Simran', 70000, NULL),
    (5, 'Kavya', 55000, 2000);
    
    SELECT
    emp_id,
    emp_name,
    salary,
    commission,
    salary + COALESCE(commission, 0) AS total_pay
FROM emp_pay;

SELECT
    COUNT(*) - COUNT(commission) AS no_commission_count,
    AVG(commission) AS avg_commission
FROM emp_pay;

#Q14 Fetch alternate rows (odd and even) from a table

CREATE TABLE student (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    marks INT
);
INSERT INTO student (student_id, student_name, marks)
VALUES
    (1, 'Amit', 78),
    (2, 'Neha', 85),
    (4, 'Raj', 66),
    (5, 'Simran', 91),
    (7, 'Kavya', 73),
    (8, 'Mohit', 88),
    (10, 'Pooja', 69),
    (11, 'Arjun', 95);
    
    SELECT
    student_id,
    student_name,
    marks,
    ROW_NUMBER() OVER (ORDER BY student_id) AS row_no
FROM student
WHERE MOD(student_id, 2) = 1;

SELECT
    student_id,
    student_name,
    marks,
    ROW_NUMBER() OVER (ORDER BY student_id) AS row_no
FROM student
WHERE MOD(student_id, 2) = 0;

SELECT
    student_id,
    student_name,
    marks,
    row_no
FROM (
    SELECT
        student_id,
        student_name,
        marks,
        ROW_NUMBER() OVER (ORDER BY student_id) AS row_no
    FROM student
) s
WHERE MOD(row_no, 2) = 1;

#Q15 Delete duplicate rows and keep only one copy
CREATE TABLE emp_dup (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept VARCHAR(50),
    salary INT
);
INSERT INTO emp_dup (emp_id, emp_name, dept, salary)
VALUES
    (1, 'Amit', 'IT', 50000),
    (2, 'Neha', 'HR', 60000),
    (3, 'Amit', 'IT', 50000),
    (4, 'Raj', 'Finance', 70000),
    (5, 'Neha', 'HR', 60000),
    (6, 'Amit', 'IT', 50000),
    (7, 'Simran', 'IT', 65000);
    
    SELECT
    emp_name ,
    dept,
    salary,
    COUNT(*) AS cnt
FROM emp_dup 
GROUP BY
    emp_name,
    dept,
    salary
HAVING COUNT(*) > 1;

DELETE e1
FROM emp_dup AS e1
JOIN emp_dup AS e2
    ON e1.emp_name = e2.emp_name
    AND e1.dept = e2.dept
    AND e1.salary = e2.salary
    AND e1.emp_id > e2.emp_id;
    
    SELECT *
FROM emp_dup
ORDER BY emp_id;

#Q16 Update salaries with CASE and swap two values in a column
CREATE TABLE emp_master (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept VARCHAR(50),
    gender CHAR(1),
    salary INT
);

INSERT INTO emp_master (emp_id, emp_name, dept, gender, salary)
VALUES
    (1, 'Amit', 'IT', 'M', 50000),
    (2, 'Neha', 'HR', 'F', 60000),
    (3, 'Raj', 'IT', 'M', 55000),
    (4, 'Simran', 'Finance', 'F', 70000),
    (5, 'Kavya', 'HR', 'F', 45000),
    (6, 'Mohit', 'Finance', 'M', 65000);
    
UPDATE emp_master
SET salary = CASE
    WHEN dept = 'IT' THEN salary * 1.10
    WHEN dept = 'HR' THEN salary * 1.05
    WHEN dept = 'Finance' THEN salary
END;

UPDATE emp_master
SET gender = CASE
    WHEN gender = 'M' THEN 'F'
    WHEN gender = 'F' THEN 'M'
END;

SELECT
    emp_id,
    emp_name,
    dept,
    gender,
    salary
FROM emp_master
ORDER BY emp_id;


#Q17 Show all employee names of a department in one single row

SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS emp_count,
    COALESCE(
        GROUP_CONCAT(e.emp_name ORDER BY e.emp_name SEPARATOR ', '),
        ''
    ) AS employee_list
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY d.dept_id;


#Q18 Date based filtering - recent joiners, weekend joiners and tenure
SELECT
    emp_id,
    emp_name,
    join_date
FROM employees
WHERE join_date >= DATE_SUB('2024-09-30', INTERVAL 6 MONTH)
  AND join_date <= '2024-09-30';
  
  SELECT
    emp_id,
    emp_name,
    join_date,
    DAYNAME(join_date) AS day_name
FROM employees
WHERE DAYOFWEEK(join_date) IN (1, 7);


SELECT
    emp_id,
    emp_name,
    join_date,
    DAYNAME(join_date) AS day_name,
    TIMESTAMPDIFF(YEAR, join_date, '2024-09-30') AS years_served,
    TIMESTAMPDIFF(MONTH, join_date, '2024-09-30') % 12 AS months_served
FROM employees
ORDER BY emp_id;


#Q19 Department with the highest number of employees

SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS emp_count
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(e.emp_id) = (
    SELECT MAX(emp_count)
    FROM (
        SELECT COUNT(e2.emp_id) AS emp_count
        FROM departments d2
        LEFT JOIN employees e2
            ON d2.dept_id = e2.dept_id
        GROUP BY d2.dept_id
    ) AS dept_counts
);

SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS emp_count
FROM departments d
LEFT JOIN employees e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY emp_count DESC
LIMIT 1;

#"Give me every department whose employee count equals the maximum employee count."


#Q20 Split a full name and mask email and mobile number
CREATE TABLE customer_contact (
    cust_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    mobile VARCHAR(15)
);

INSERT INTO customer_contact (cust_id, full_name, email, mobile)
VALUES
(1, 'Amit Kumar', 'amit.kumar@gmail.com', '9876543210'),
(2, 'Neha Sharma', 'neha_s@yahoo.co.in', '9812345678'),
(3, 'Raj Verma', 'raj.verma@outlook.com', '9765432109'),
(4, 'Simran Kaur', 'simran.k@gmail.com', '9898989898');

SELECT
    cust_id,

    -- First and last name
    SUBSTRING_INDEX(full_name, ' ', 1) AS first_name,
    SUBSTRING_INDEX(full_name, ' ', -1) AS last_name,

    -- Email: first 2 characters + **** + domain
    CONCAT(
        LEFT(email, 2),
        '****',
        SUBSTRING(email, LOCATE('@', email))
    ) AS masked_email,

    -- Mobile: hide everything except last 4 digits
    CONCAT(
        REPEAT('X', LENGTH(mobile) - 4),
        RIGHT(mobile, 4)
    ) AS masked_mobile,

    -- Email domain
    SUBSTRING_INDEX(email, '@', -1) AS email_domain

FROM customer_contact;