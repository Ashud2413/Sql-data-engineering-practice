CREATE TABLE Employee (
EmpID int NOT NULL,
EmpName Varchar,
Gender Char,
Salary int,
City Char(20) );

INSERT INTO Employee
VALUES (1, 'Arjun', 'M', 75000, 'Pune'),
(2, 'Ekadanta', 'M', 125000, 'Bangalore'),
(3, 'Lalita', 'F', 150000 , 'Mathura'),
(4, 'Madhav', 'M', 250000 , 'Delhi'),
(5, 'Visakha', 'F', 120000 , 'Mathura');

CREATE TABLE EmployeeDetail (
EmpID int NOT NULL,
Project Varchar,
EmpPosition Char(20),
DOJ date );
VALUES (1, 'P1', 'Executive', '26-01-2019'),
(2, 'P2', 'Executive', '04-05-2020'),
(3, 'P1', 'Lead', '21-10-2021'),
(4, 'P3', 'Manager', '29-11-2019'),
(5, 'P2', 'Manager', '01-08-2020');

select EmpName ,salary from employee 
where Salary >200000 and salary <300000;

select Empname ,salary from employee where salary between 200000 and 300000;

select e1.empid , e1.empname,e1.city from employee e1 ,employee e2
where e1.city =e2.city and e1.empid != e2.empid;

select * from employee where Empid is NULL;

select empname ,salary,sum(salary) over (order by empid) as cummulativesal 
from employee;

select (count(*)filter(where gender ="M")* 100.0/count(*)) as maleratio,
(count(*)filter(where gender="F")*100.0/count(*)) as femaleratio
from employee;

SELECT * FROM Employee
WHERE EmpID <= (SELECT COUNT(EmpID)/2 from Employee);

select * From (select * , row_number() over(order by empid) as rownumber from employee) as emp
where emp.rownumber <= (select count(empid)/2 from employee);

-- select salary , concat(SUBSTRING(salary::text,1,Length(salary::text)-2),"XX") as  masked_number
-- from employee;

-- SELECT Salary, CONCAT(LEFT(CAST(Salary AS text), LENGTH(CAST(Salary AS text))-2), 'XX')
-- AS masked_number
-- FROM Employee;

select * from (select *, row_number() over(order by empid) as rownumber from employee) as emp
where emp.rownumber%2=0;

select * from (select *, row_number() over(order by empid) as rownumber from employee) as emp
where emp.rownumber%2=1;

select e1.salary from employee e1
where n-1 =(
select count(distinct(e2.salary))
from employee e2
where e2.salary > e1.salary);

select empname,salary,
case
when salary> 200000 then "high"
when salary >= 100000 and salary <=200000 then "medium"
else "low"
end as salarystatus
from employee


