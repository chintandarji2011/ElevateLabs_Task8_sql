# ElevateLabs_Task8_sql
Author - Darji Chintankumar Dineshchandra

#    Task 8: Stored Procedures and Functions

This task demonstrates how to create and use **stored procedures** and **stored functions** in MySQL to modularize and reuse SQL logic.

#  Tools
MySQL Workbench
(SQLite doesn’t support procedures or functions)



---

##  Table Structure and Sample Data

```sql
CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  salary DECIMAL(10,2),
  dep_id INT
);
```
##  Stored Procedures
###  SP_EX_1: GetEmployeesByDept
> Get employees of a specific department.
```sql
CREATE PROCEDURE GetEmployeesByDept(IN dept_id INT)
BEGIN
  SELECT name, salary
  FROM employees
  WHERE dep_id = dept_id;
END;
```
> Usage:
```sql
CALL GetEmployeesByDept(1);
```

###  SP_EX_2: IncreaseSalary
> Raise an employee’s salary by a given percentage.
```sql
CREATE PROCEDURE IncreaseSalary(IN empID INT, IN percent DECIMAL(5,2))
BEGIN
  UPDATE employees 
  SET salary = salary + (salary * percent / 100)
  WHERE id = empID;
END;
```
> Usage:
```sql
CALL IncreaseSalary(2, 10);
```
### SP_EX_3: GetEmployeeName (with OUT parameter)
> Get employee name using an OUT parameter.
```sql
CREATE PROCEDURE GetEmployeeName(IN empId INT, OUT empName VARCHAR(100))
BEGIN
  SELECT name INTO empName
  FROM employees 
  WHERE id = empId;
END;
```
> Usage:
```sql
SET @name_out = '';
CALL GetEmployeeName(3, @name_out);
SELECT @name_out AS employee_name;
```
### SP_EX_4: CountEmployeeInDept (with OUT parameter)
> Count total employees in a department.
```sql
CREATE PROCEDURE CountEmployeeInDept(IN depID INT, OUT countEmp INT)
BEGIN
  SELECT COUNT(*) INTO countEmp
  FROM employees 
  WHERE dep_id = depID;
END;
```
> Usage:
```sql
SET @totalCount = 0;
CALL CountEmployeeInDept(2, @totalCount);
SELECT @totalCount AS Emp_Count_Per_Dept;
```
### SP_EX_5: RaiseSalaryWithStatus (with OUT status message)
> Increase salary and return success/failure status.
```sql
CREATE PROCEDURE RaiseSalaryWithSatus(
  IN empID INT,
  IN RaisePercent DECIMAL(5,2),
  OUT statusMsg VARCHAR(100)
)
BEGIN
  DECLARE emp_exists INT;

  SELECT COUNT(*) INTO emp_exists
  FROM employees WHERE id = empID;

  IF emp_exists = 1 THEN
    UPDATE employees
    SET salary = salary + (salary * RaisePercent / 100)
    WHERE id = empID;
    SET statusMsg = 'Salary updated successfully.';
  ELSE
    SET statusMsg = 'Employee not found.';
  END IF;
END;
```
> Usage:
```sql
SET @msg = '';
CALL RaiseSalaryWithSatus(3, 10.00, @msg);
SELECT @msg AS Result_message;
```
##  Stored Functions:
### FUN_EX_1: GetAnnualSalary
> Returns annual salary based on monthly salary.
```sql
CREATE FUNCTION GetAnnualSalary(emp_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN 
  DECLARE annual_salary DECIMAL(10,2);
  SELECT salary * 12 INTO annual_salary FROM employees WHERE id = emp_id;
  RETURN annual_salary;
END;
```
> Usage:
```sql
SELECT name, GetAnnualSalary(id) AS annual_salary FROM employees;
```
### FUN_EX_2: CalculateTax
> Calculates tax based on salary brackets.
```sql
CREATE FUNCTION CalculateTax(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE tax DECIMAL(10,2);
  IF salary <= 3000 THEN
    SET tax = salary * 0.05;
  ELSEIF salary <= 6000 THEN 
    SET tax = salary * 0.10;
  ELSE 
    SET tax = salary * 0.15;
  END IF;
  RETURN tax;
END;
```
> Usage:
```sql
SELECT name, salary, CalculateTax(salary) AS tax FROM employees;
```

### FUN_EX_3: FullName
> Concatenates first and last names.
```sql
CREATE FUNCTION FullName(first_name VARCHAR(50), last_name VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  RETURN CONCAT(first_name, ' ', last_name);
END;
```
> Usage:
```sql
SELECT FullName('Chintan', 'Darji') AS Full_name;
```
## Function used in Procedure
### FUN_SP_EX: Function Used Inside Procedure
> Using a function inside a procedure.
- BonusAmount Function:
```sql
CREATE FUNCTION BonusAmount(salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN salary * 0.10;
END;
```
- ShowBonus Procedure:
```sql
CREATE PROCEDURE ShowBonus(IN emp_id INT)
BEGIN
  DECLARE sal DECIMAL(10,2);
  DECLARE bonus DECIMAL(10,2);
  
  SELECT salary INTO sal FROM employees WHERE id = emp_id;
  SET bonus = BonusAmount(sal);
  
  SELECT emp_id AS ID, sal AS Salary, bonus AS Bonus;
END;

```
> Usage:
```sql
CALL ShowBonus(3);
```
## Notes
- All examples use DELIMITER // for MySQL. For SQL Server, remove DELIMITER and change parameter syntax accordingly.

- OUT parameters are used for returning values without using SELECT directly.

- Functions can be used in SELECT queries but not inside stored functions (no side-effect operations allowed).



