/*retrive all current leased offices with approaching lease end date*/

SELECT    DISTINCT L.LeaseID, L.LeasedOfficeID, LeaseEndDate
FROM      Leased_Office AS L, Lease_Holder AS LH
WHERE     LeaseEndDate >= CURRENT_DATE
AND       LeaseEndDate <= CURRENT_DATE + 90
AND       L.LeaseID = LH.LeaseID
ORDER BY  LeaseEndDate, L.LeasedOfficeID;