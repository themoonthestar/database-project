/*retrive the average commission percentage of sales commission for each office*/

SELECT OfficeID, OfficeAddress, TRUNC(AVG(CommissionPercentage),2) AS "Average Commission Percentage"
FROM Sale_Listing, Listing, Residential_Property, Office_Detail
WHERE Sale_Listing.MLSID = Listing.MLSID
AND Result = 'Sold'
AND EXTRACT(YEAR FROM InactiveDate) = 2021
AND EXTRACT(MONTH FROM InactiveDate) = 12
AND Residential_Property.PropertyID = Listing.PropertyID
AND ListingOfficeID = OfficeID
GROUP BY OfficeID,OfficeAddress
ORDER BY "Average Commission Percentage";