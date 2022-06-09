/*retrive all the rent commission information or top/bottom 3 */

SELECT *
FROM Office_Rent_weekly
-- if we want bottom 3 rent commissions, use ORDER BY Rent_Commission LIMIT 3; 
-- if we want top 3 rent commissions, use ORDER BY Rent_Commission DESC LIMIT 3; 
ORDER BY Rent_Commission; 
