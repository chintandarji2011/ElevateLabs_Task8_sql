/*Task 8: Stored Procedures and Functions
Objective: Learn reusable SQL blocks

Deliverables: At least one stored procedure and one function*/

----- Create database-------
CREATE DATABASE elevatelabs_Task8;

------Use start database-----
USE elevatelabs_Task8;

-----Create the employee table------
CREATE TABLE employees
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	name VARCHAR(100),
	salary DECIMAL(10,2),
	dep_id INT
);
INSERT INTO employees(name, salary, dep_id) VALUES
('Alice', 5000, 1),
('Bob', 6000, 2),
('Charlie', 7000, 1),
('Daisy', 8000, 2);

SELECT * FROM employees
TRUNCATE TABLE employees

-- SP_Task:1 Create the store procedure 'GetEmployeesByDept' with input parameter

CREATE OR ALTER PROCEDURE GetEmployeesByDept (@dept_id INT)
AS
BEGIN
	SELECT name, salary FROM employees 
	WHERE dep_id = @dept_id;
END;

-- Usage
EXECUTE GetEmployeesByDept 2;

-- SP_Task: 2 Give a salary raise to a specific employee by SP: `IncreaseSalary`

CREATE OR ALTER PROCEDURE IncreaseSalary (@emp_id INT, @percent DECIMAL(10,2))
AS
BEGIN
	UPDATE employees
	SET salary += salary * @percent/100
	WHERE id = @emp_id;
END;

-- Usage
EXEC IncreaseSalary 2, 10;

SELECT * FROM employees;

-- Sp_Task3: Return  EmployeeName in as per Emp_id(Using OUT) sp: `GetEmployeeName`

CREATE OR ALTER PROCEDURE GetEmployeeName (@emp_id INT, @emp_name VARCHAR(100) OUTPUT)
AS
BEGIN
	SELECT @emp_name = ISNULL(name,'') FROM employees	
	WHERE id = @emp_id;
END;

-- Usage
DECLARE  @Name_out VARCHAR(100);
EXEC GetEmployeeName 1, @Name_out OUTPUT;
SELECT @Name_out as EmpName;

-- Sp_Task3: Count Employees in a Department (OUT) sp: `CountEmployeeInDept`

CREATE OR ALTER PROCEDURE CountEmployeeInDept (@Dep_id INT, @CountEmp INT OUTPUT)
AS
BEGIN
	SELECT @CountEmp= COUNT(id) FROM employees
	WHERE dep_id = @Dep_id;
END;

--Usage
DECLARE @NoofEmp INT;
EXEC CountEmployeeInDept 2, @NoofEmp OUTPUT;
SELECT @NoofEmp as CountEmp;

-- Sp_Task4 : OUT + IN/OUT — Salary Raise with Status Flag SP: `RaiseSalaryWithSatus`

CREATE OR ALTER PROCEDURE RaiseSalaryWithStatus
(
	@empID INT,
	@Percent DECIMAL(10,2),
	@Msg VARCHAR(100) OUTPUT
)
AS
BEGIN
	DECLARE @Exist_emp INT;

	SELECT @Exist_emp = COUNT(*) FROM employees
	WHERE id = @empID;

	IF @Exist_emp = 1
			BEGIN
				UPDATE employees
				SET salary = salary + salary * @Percent/100
				WHERE  id = @empID

				SET @Msg = 'Salary Updated Successfully.'
			END
	ELSE
		BEGIN
			SET @Msg = 'Employee Not found.';
		END

END;

--Usage

DECLARE @Meassage VARCHAR(100);
EXEC RaiseSalaryWithStatus 1, 3, @Meassage OUTPUT;
SELECT @Meassage as Notice;

SELECT * FROM employees;

-----
-- FUNCTION EXAMPLES

-- FUN_EX_1: create the store function `GetAnnualSalary`

CREATE OR ALTER FUNCTION GetAnnualSalary(@EmpID INT)
RETURNS DECIMAL (10,2)
AS
BEGIN	
	DECLARE @Anual_Salary DECIMAL(10,2);

	SELECT @Anual_Salary = salary*12 FROM employees
	WHERE id = @EmpID;

	RETURN @Anual_salary;
END;

-- Usage
SELECT name, dbo.GetAnnualSalary(id) FROM employees;

-- FUN_EX:2 : Function: Get Tax Based on Salary (DECIMAL input) func: `CalculateTax`

CREATE OR ALTER FUNCTION CalculateTax (@Salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @TAX DECIMAL(10,2);

	IF @Salary<= 3000
		BEGIN
		SET @TAX = @Salary * 0.05;
		END
	ELSE IF @Salary <= 6000
		BEGIN
		SET @TAX = @Salary * 0.10;
		END
	ELSE
		BEGIN
			SET @TAX = @Salary*0.15;
		END
	RETURN @TAX;
END;


--Usage

SELECT name, salary, dbo.CalculateTax(salary) As Tax FROM employees;

-- Fun_Ex_3 : Function: Concatenate First and Last Name (VARCHAR input) func: `FullName`

CREATE OR ALTER FUNCTION Fullname (@FirstName VARCHAR(50), @LastAnme VARCHAR(50))
RETURNS VARCHAR(100)
AS
BEGIN
	RETURN CONCAT(@FirstName,' ', @LastAnme, '') 
END;

-- usage
SELECT dbo.Fullname ('Chintan', 'Darji') as FullName;

--------- FUNCTION USED IN STORE PROCEDURE 

-- SP_fun_Ex: Reuse a function inside a procedure
-- Create the function 'BonusAmount' 10%

CREATE OR ALTER FUNCTION BonusAmount (@Sal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
	BEGIN
		RETURN @Sal * 0.10;
	END;
-- Create the procedure 'ShowBonus' by using function 'BonusAmount'

CREATE OR ALTER PROCEDURE ShowBonus (@EmpID INT)
AS
	BEGIN
		DECLARE @Sal DECIMAL(10,2);
		DECLARE @Bonus DECIMAL(10,2);

		SELECT @Sal = salary FROM employees WHERE id = @EmpID

		SET @Bonus = DBO.BonusAmount(@Sal)

		SELECT @EmpID as ID, @Sal AS Salary, @Bonus AS Bonus;
	END;

EXEC ShowBonus 1;




	


