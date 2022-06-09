/*retrive the royalty commission information */

SELECT LeasedOfficeID, OfficeAddress,totalcommission*0.1 AS Royalty_Commission 
FROM  Weekly_Total_Commission, Current_Leased_Office
WHERE LeasedOfficeID = OfficeID;