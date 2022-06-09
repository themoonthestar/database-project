/*
We will generate 9 views for reporting purpose including HR_Report view, owned office,all current office details, leased office, associated lessors, office weekly sales information
office weekly rental deal information, office monthly total commission, office weekly total commission
The following code will generate above views in order to produce reports for Realtek Inc.
*/

-- HR_Report view
-- Shows all employees with their employee ID, first name, middle initial and last name, their operating manager’s first name, middle initial and last name, the office ID they currently work in and the first name, middle initial and last name of the responsible partner for that office.
CREATE VIEW HR_Report AS 
SELECT E.EmployeeID, E.FirstName || ' ' ||  COALESCE(E.MiddleInitial,'') || 
CASE WHEN E.MiddleInitial IS NULL THEN '' ELSE ' ' END ||  E.LastName AS "Employee Name",
M.FirstName || ' ' ||  COALESCE(M.MiddleInitial,'') || 
CASE WHEN M.MiddleInitial IS NULL THEN '' ELSE ' ' END ||  M.LastName AS "Operating Manager",
Partner.FirstName || ' ' ||  COALESCE(Partner.MiddleInitial,'') || 
CASE WHEN Partner.MiddleInitial IS NULL THEN '' ELSE ' ' END ||  Partner.LastName AS "Responsible Partner",
E.WorkOfficeID
FROM Full_Time_Employee AS E, Full_Time_Employee AS M, Partner, Owned_Office
WHERE Owned_Office.ManagerID = M.EmployeeID
AND Owned_Office.PartnerID = Partner.PartnerID
AND Owned_Office.OwnedOfficeID = E.WorkOfficeID
;

-- Owned_Office_Detail view
-- Shows all owned offices with their office ID, office Address and workforce.
CREATE VIEW Owned_Office_Detail AS 
SELECT OwnedOfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS OfficeAddress, COUNT(EmployeeID) AS WorkForce
FROM   Owned_Office, Office AS O, Full_Time_Employee
WHERE  OfficeID = OwnedOfficeID
AND    WorkOfficeID = OwnedOfficeID
GROUP BY OwnedOfficeID,OfficeID;

-- Office_Detail view
-- Shows all current leased and owned offices with their office ID, office address, workforce and type discriminator.
CREATE VIEW Office_Detail AS 
SELECT OwnedOfficeID AS OfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS OfficeAddress, COUNT(EmployeeID) AS WorkForce , O.IsOwned
FROM   Owned_Office, Office AS O, Full_Time_Employee
WHERE  OfficeID = OwnedOfficeID
AND    WorkOfficeID = OwnedOfficeID
GROUP BY OwnedOfficeID,OfficeID
UNION
SELECT LeasedOfficeID AS OfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS OfficeAddress, WorkForce , O.IsOwned
FROM   Leased_Office, Office AS O
WHERE  LeaseEndDate > Current_Date
AND    OfficeID = LeasedOfficeID
ORDER BY OfficeID;

-- Current_Leased_Office view
-- Shows all current leased offices their office ID, office address, workforce and corresponded lease ID.
CREATE VIEW Current_Leased_Office AS 
SELECT LeasedOfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS OfficeAddress, WorkForce, LeaseID
FROM   Leased_Office, Office AS O
WHERE  LeaseEndDate > Current_Date
AND    OfficeID = LeasedOfficeID;

-- Current_Lessor view
-- Shows all current leased offices with their office IDs, office addresses, corresponded lease IDs, associated lessors’ affiliate IDs, first names, middle initials and last names.
CREATE VIEW Current_Lessor AS
SELECT A.AffiliateID AS "Lessor AffiliateID", 
FirstName || ' ' ||  COALESCE(MiddleInitial,'') || CASE WHEN MiddleInitial IS NULL THEN '' ELSE ' ' END ||  LastName AS "Lessor Name",
L.LeaseID, L.LeasedOfficeID, OfficeAddress
FROM Affiliate AS A, Lease_Holder AS L, Current_Leased_Office AS C
WHERE A.AffiliateID = L.AffiliateID
AND L.LeaseID in (SELECT LeaseID FROM Current_Leased_Office)
AND L.LeasedOfficeID = C.LeasedOfficeID;

-- Office_Sales_Weekly view
-- Shows all offices that have at least one sale with their office IDs, office addresses, total sales amount and total sales commissions.
CREATE VIEW Office_Sales_Weekly AS 
SELECT O.OfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS Office_Address, SUM(S.SalesPrice) AS Total_Sales, TRUNC(SUM(S.SalesPrice * S.CommissionPercentage/100), 2) AS Sales_Commission 
FROM Office AS O, Residential_Property AS P, Listing AS L, Sale_Listing AS S 
WHERE O.OfficeID=P.ListingOfficeID 
AND P.PropertyID=L.propertyID 
AND L.MLSID = S.MLSID 
AND L.Result = 'Sold' 
-- If run every week use following AND InactiveDate >= Current_Date - 7
AND InactiveDate >= '2021-11-28' 
-- If run every week use following AND InactiveDate < Current_Date
AND InactiveDate < '2021-12-05' 
GROUP BY O.OfficeID; 

-- Office_Rent_Weekly view
-- Shows all offices that have at least one rental with their office IDs, office addresses, total monthly rent and total rental commissions. 
CREATE VIEW Office_Rent_Weekly AS 
SELECT O.OfficeID, O.Street || ',' || O.City || ', ' || O.Province || ', ' || O.PostalCode AS Office_Address, SUM(R.MonthlyRent) AS Total_Rent_Generated_By_Office, SUM(R.CommissionAmount) AS Rent_Commission 
FROM Office AS O, Residential_Property AS P, Listing AS L, Rental_Listing AS R 
WHERE O.OfficeID=P.ListingOfficeID 
AND P.PropertyID=L.propertyID 
AND L.MLSID = R.MLSID 
AND L.Result = 'Rented' 
-- If run every week use following AND InactiveDate >= Current_Date - 7
AND InactiveDate >= '2021-11-28' 
-- If run every week use following AND InactiveDate < Current_Date
AND InactiveDate < '2021-12-05' 
GROUP BY O.OfficeID; 


-- Monthly_Total_Commission view
-- Shows all offices that have a positive commission with their office IDs and total commission amounts (including both sales and rental commission).
CREATE VIEW Monthly_Total_Commission AS
SELECT ListingOfficeID AS OfficeID, SUM(Commission) AS TotalCommission
FROM (
SELECT ListingOfficeID, TRUNC(SUM(S.SalesPrice * S.CommissionPercentage/100), 2) AS Commission 
FROM Residential_Property AS P, Listing AS L, Sale_Listing AS S 
WHERE P.PropertyID=L.propertyID 
AND L.MLSID = S.MLSID 
AND L.Result = 'Sold'
-- change (YEAR FROM InactiveDate) = ****, **** is desired year
AND EXTRACT(YEAR FROM InactiveDate) = 2021
-- change (MONTH FROM InactiveDate) = **, ** is desired month
AND EXTRACT(MONTH FROM InactiveDate) = 12
GROUP BY ListingOfficeID
UNION
SELECT ListingOfficeID,  SUM(R.CommissionAmount) AS Commission 
FROM Residential_Property AS P, Listing AS L, Rental_Listing AS R 
WHERE P.PropertyID=L.propertyID 
AND L.MLSID = R.MLSID 
AND L.Result = 'Rented'
-- change (YEAR FROM InactiveDate) = ****, **** is desired year
AND EXTRACT(YEAR FROM InactiveDate) = 2021
-- change (MONTH FROM InactiveDate) = **, ** is desired month
AND EXTRACT(MONTH FROM InactiveDate) = 12
GROUP BY ListingOfficeID) AS X
GROUP BY OfficeID;

-- Weekly_Total_Commission View
-- Shows all offices that have a positive commission during the week with their office IDs and total commission amounts (including both sales and rental commission). 
CREATE VIEW Weekly_Total_Commission AS
SELECT ListingOfficeID AS OfficeID, SUM(Commission) AS TotalCommission
FROM (
SELECT ListingOfficeID, TRUNC(SUM(S.SalesPrice * S.CommissionPercentage/100), 2) AS Commission 
FROM Residential_Property AS P, Listing AS L, Sale_Listing AS S 
WHERE P.PropertyID=L.propertyID 
AND L.MLSID = S.MLSID 
AND L.Result = 'Sold'
-- If run every week use following AND InactiveDate >= Current_Date - 7
AND InactiveDate >= '2021-11-28' 
-- If run every week use following AND InactiveDate < Current_Date
AND InactiveDate < '2021-12-05' 
GROUP BY ListingOfficeID
UNION
SELECT ListingOfficeID,  SUM(R.CommissionAmount) AS Commission 
FROM Residential_Property AS P, Listing AS L, Rental_Listing AS R 
WHERE P.PropertyID=L.propertyID 
AND L.MLSID = R.MLSID 
AND L.Result = 'Rented'
-- If run every week use following AND InactiveDate >= Current_Date - 7
AND InactiveDate >= '2021-11-28' 
-- If run every week use following AND InactiveDate < Current_Date
AND InactiveDate < '2021-12-05' 
GROUP BY ListingOfficeID) AS X
GROUP BY OfficeID;