/*HR use this query to retrive staff information every week*/

SELECT EmployeeID, "Employee Name",
 "Operating Manager",
"Responsible Partner",WorkOfficeID, WorkForce
FROM 
(SELECT * FROM HR_Report) AS A
RIGHT OUTER JOIN
(SELECT OwnedOfficeID, WorkForce FROM Owned_Office_Detail) AS B
ON WorkOfficeID = OwnedOfficeID
-- if we want to have offices with larger workforce first, use ORDER BY WorkForce DESC;
ORDER BY WorkForce;