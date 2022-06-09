/*retrive the full time employee salary information */

SELECT EmployeeID,FirstName || ' ' ||  COALESCE(MiddleInitial,'') || 
CASE WHEN MiddleInitial IS NULL THEN '' ELSE ' ' END ||  LastName AS "EmployeeName", Salary 
FROM Full_Time_Employee
-- sorting options: ORDER BY employeeid; / ORDER BY salary DESC; / ORDER BY salary;
ORDER BY salary DESC; 