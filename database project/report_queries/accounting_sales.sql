/*retrive all the sale commission information or top/bottom 3 */

SELECT * 
FROM Office_Sales_Weekly  
-- if we want bottom 3 sales commissions, use ORDER BY Sales_Commission LIMIT 3; 
-- if we want top 3 sales commissions, use ORDER BY Sales_Commission DESC LIMIT 3; 
ORDER BY Sales_Commission; 
