--  Task 8: Stored Procedures and Functions 

-- create table of `employees`
CREATE TABLE employees
(
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  salary DECIMAL(10,2),
  dep_id INT
);

--  Insert Into employees

INSERT INTO employees(name, salary,dep_id)
VALUES
('Alice', 5000, 1),
('Bob', 6000, 2),
('Charlie', 7000, 1),
('Daisy', 8000, 2);

SELECT * FROM employees;

-- SP_EX_1: create the store procedure `GetEmployeesByDept`

DELIMITER //                                            -- SQL server no use DELIMITER //
CREATE PROCEDURE GetEmployeesByDept(IN dept_id INT)     -- FOR SQL SERVER USE  (@dept_id AS INT) AS
BEGIN
  SELECT name, salary
  FROM employees
  WHERE dep_id = dept_id;                               -- sql server WHERE dep_id = @dept_id;
END;
//
DELIMITER ;

-- Usage

CALL GetEmployeesByDept(1); -- for SQL SERVER ->  EXEC GetEmployeesByDept 2;
  
-- SP_EX_2:  Give a salary raise to a specific employee by SP: `IncreaseSalary`

DELIMITER //
CREATE PROCEDURE IncreaseSalary (IN empID INT, IN percent DECIMAL(5,2))
BEGIN
  UPDATE employees 
  SET salary = salary + (salary * percent/100)
  WHERE id = empID;
END;
//
DELIMITER ;

-- call procedure `IncreaseSalary`
CALL IncreaseSalary (2,10);

SELECT * FROM employees;

-- SP_EX_3: Return Total Employees in a Department (Using OUT) sp: `GetEmployeeName`

DELIMITER //
CREATE PROCEDURE GetEmployeeName (IN empId INT, OUT empName VARCHAR(100))    -- FOR SQL SERVER USE: (@empId AS INT, @empName AS VARCHAR(100) OUTPUT) AS
BEGIN
  SELECT name INTO empName
  FROM employees 
  WHERE id = empId;                 -- FOR SQL SERVER USE: SELECT @empName = name FROM employees WHERE id = @empId;    
END;
//
DELIMITER ;

-- calling procedure `GetEmployeeName`

-- decalre a variable to store output
SET @name_out = '';

-- call procedure `GetEmployeeName`

CALL GetEmployeeName(3, @name_out);

-- check the result from variable @name_out
SELECT @name_out AS employee_name;

-- SP_EX_4: Count Employees in a Department (OUT) sp: `CountEmployeeInDept`
DELIMITER //
CREATE PROCEDURE CountEmployeeInDept (IN depID INT, OUT countEmp INT)    -- FOR SQL SERVER USE: (@depID AS INT, @countEmp AS INT OUTPUT) AS
BEGIN
  SELECT COUNT(*) INTO countEmp
  FROM employees 
  WHERE dep_id = depID;          -- FOR SQL SERVER USE: SELECT @countEmp = COUNT(*) FROM employees WHERE dep_id = @depID;      
END;
//
DELIMITER ;

-- CALLING PROCEDURE

SET @totalCount = 0;

CALL CountEmployeeInDept(2,@totalCount);

SELECT @totalCount AS Emp_Count_Per_Dept;

-- SP_EX_5: OUT + INOUT — Salary Raise with Status Flag SP: `RaiseSalaryWithSatus`

DELIMITER //

CREATE PROCEDURE RaiseSalaryWithSatus
(
IN empID INT,
IN RaisePercent DECIMAL(5,2),
OUT statusMsg VARCHAR(100)
)

BEGIN
  DECLARE emp_exists INT;
  
  SELECT COUNT(*) INTO emp_exists
  FROM employees 
  WHERE id = empID;
  
  IF emp_exists = 1 THEN
    UPDATE employees
    SET salary = salary + (salary * RaisePercent / 100)
    WHERE id = empID;
    
    SET statusMsg = 'Salary updated succesfully.';
  ELSE 
    SET statusMsg = 'Employee not found.';
  END IF;
END;
  
//
DELIMITER ;

-- CALLING PROCEDURE `RaiseSalaryWithSatus`

SET @msg = '';
CALL RaiseSalaryWithSatus(3,10.00,@msg);
SELECT @msg AS Result_message;

SELECT * FROM employees;
  

-- FUNCTION EXAMPLES

-- FUN_EX_1: create the store function `GetAnnualSalary`
DELIMITER //
CREATE FUNCTION GetAnnualSalary(emp_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN 
  DECLARE annual_salary DECIMAL(10,2);
  
  SELECT salary*12 INTO annual_salary
  FROM employees
  WHERE id= emp_id;
  
  RETURN annual_salary;
END;
//
DELIMITER ;

-- Usage of store function

SELECT name, GetAnnualSalary(id) AS annual_salary
FROM employees;


-- FUN_EX:2 : Function: Get Tax Based on Salary (DECIMAL input) func: `CalculateTax`

DELIMITER //

CREATE FUNCTION CalculateTax (salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE tax DECIMAL(10,2);
  
  IF Salary <= 3000 THEN
    SET tax = salary * 0.05;
  ELSEIF salary <=6000 THEN 
    SET tax = salary * 0.10;
  ELSE 
    SET tax = salary * 0.15;
  END IF;
  
  RETURN tax;
END;

//
DELIMITER ;

-- call function `CalculateTax`

SELECT name, salary, CalculateTax(salary) AS tax FROM employees;

-- Fun_Ex_3 : Function: Concatenate First and Last Name (VARCHAR input) func: `FullName`

DELIMITER //

CREATE FUNCTION FullName (first_name VARCHAR(50), last_name VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
  RETURN CONCAT (first_name,' ',last_name);
END;

//
DELIMITER ;

-- call Function 'FullName'

SELECT FullName('Chintan','Darji') AS Full_name;

-- FUNCTION USED IN STORE PROCEDURE 

-- SP_fun_Ex: Reuse a function inside a procedure

-- create function `BonusAmount`
DELIMITER //

CREATE FUNCTION BonusAmount (salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)

DETERMINISTIC

BEGIN
  return salary * 0.10;
END;
//
DELIMITER ;

-- create procedure `ShowBonus` that uses function `BonusAmount`

DELIMITER //

CREATE PROCEDURE ShowBonus (IN emp_id INT)
BEGIN
  DECLARE sal DECIMAL(10,2);
  DECLARE bonus DECIMAL(10,2);
  
  SELECT salary INTO sal FROM employees WHERE id = emp_id;
  SET bonus = BonusAmount(sal);
  
  SELECT emp_id AS ID, Sal AS salary, bonus AS Bonus;
END;

//
DELIMITER ;

-- CALL STORE PROCEDURE `ShowBonus`

CALL ShowBonus(3);




  

