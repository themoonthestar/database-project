/*retrive the average commission data that count as commssion generate by per employee for each office*/

SELECT O.OfficeID, OfficeAddress, TRUNC(TotalCommission/WorkForce,2) AS "Commissions Generated Per Employee"
FROM Office_Detail AS O,Monthly_Total_Commission AS C
WHERE O.OfficeID = C.OfficeID
ORDER BY "Commissions Generated Per Employee";