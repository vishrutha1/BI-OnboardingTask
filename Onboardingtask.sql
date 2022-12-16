--1.a.Display a list of all property names and their property id’s for Owner Id: 1426. 

SELECT P.Id AS PropertyId,P.Name AS PropertyName
FROM Keys.dbo.Property P JOIN keys.dbo.OwnerProperty O ON P.Id = O.PropertyId
WHERE O.OwnerId = '1426'

--1.b.Display the current home value for each property in question a). 


WITH Cte_Chomevalue as 
(
SELECT P.Id,P.Name
FROM Keys.dbo.Property P JOIN keys.dbo.OwnerProperty O ON P.Id = O.PropertyId
WHERE O.OwnerId = '1426'
)
Select C.Id AS PropertyId,C.Name AS PropertyName,PH.Value AS CurrentHomeValue 
FROM keys.dbo.PropertyHomeValue PH JOIN Cte_Chomevalue C ON C.Id =PH.PropertyId 
WHERE PH.isActive='1'

--1.c.i) For each property in question a), return the following:                                                                      
/*Using rental payment amount, rental payment frequency, tenant start date and tenant end date to
write a query that returns the sum of all payments from start date to end date. */

SELECT O.OwnerId,TP.PropertyId AS PropertyId,P.Name AS PropertyName,TP.StartDate AS TenantStartDate,
TP.EndDate AS TenantEndDate,TP.PaymentAmount AS RentalPaymentAmount,PF.Name AS RentalPaymentFrequency,
CASE
WHEN TP.PaymentFrequencyId = '1'  THEN  DATEDIFF(WEEK, TP.StartDate, TP.EndDate)*(TP.PaymentAmount)
WHEN TP.PaymentFrequencyId = '2'  THEN  (DATEDIFF(WEEK, TP.StartDate, TP.EndDate)/2)*(TP.PaymentAmount)
WHEN TP.PaymentFrequencyId = '3'  THEN  DATEDIFF(MONTH, TP.StartDate, TP.EndDate)*(TP.PaymentAmount)
ELSE NULL
END  AS 'SumOfPayments' 
FROM Keys.dbo.TenantProperty TP JOIN keys.dbo.OwnerProperty O ON TP.PropertyId = O.PropertyId
JOIN Keys.dbo.Property P ON TP.PropertyId = P.Id JOIN Keys.dbo.TenantPaymentFrequencies PF ON TP.PaymentFrequencyId = PF.Id
WHERE O.OwnerId = '1426'



-- 1.c.ii) Display the yield. 

WITH Cte_Income AS 
(
SELECT TP.PropertyId,
CASE
WHEN TP.PaymentFrequencyId = '1'  THEN  DATEDIFF(WEEK, TP.StartDate, TP.EndDate)*(TP.PaymentAmount)
WHEN TP.PaymentFrequencyId = '2'  THEN  DATEDIFF(WEEK, TP.StartDate, TP.EndDate)*(TP.PaymentAmount/2)
WHEN TP.PaymentFrequencyId = '3'  THEN  DATEDIFF(MONTH, TP.StartDate, TP.EndDate)*(TP.PaymentAmount)
ELSE NULL
END  AS 'SumOfPayments' 
FROM Keys.dbo.TenantProperty TP JOIN keys.dbo.OwnerProperty O ON TP.PropertyId = O.PropertyId
WHERE O.OwnerId = '1426'
),
Cte_Expenses AS 
(
SELECT DISTINCT SUM(PE.amount) AS Expenses, PE.PropertyId
FROM keys.dbo.PropertyExpense PE JOIN keys.dbo.OwnerProperty O ON PE.PropertyId = O.PropertyId
WHERE O.OwnerId = '1426' 
GROUP BY PE.propertyid
),
Cte_Homevalue AS
(
SELECT P.value,P.PropertyId 
FROM keys.dbo.PropertyHomeValue P JOIN keys.dbo.property PT ON P.PropertyId = PT.id 
JOIN keys.dbo.OwnerProperty O ON P.PropertyId = O.PropertyId
WHERE P.isActive='1' AND O.OwnerId = '1426'
)

SELECT I.PropertyId,I.SumOfPayments,E.Expenses,H.Value AS CurrentHomeValue,((I.SumOfPayments-isnull(E.Expenses,0))/H.Value)*100 AS Yield 
From Cte_Income I JOIN Cte_Expenses E On I.PropertyId = E.PropertyId
JOIN Cte_Homevalue H On I.PropertyId = H.PropertyId

--1.d..Display all the jobs available


SELECT J.JobEndDate,J.* FROM KEYS.DBO.Job J WHERE J.JobStatusId in ('1','2','3')


/*1.e).Display all property names, current tenants first and last names and
rental payments per week/ fortnight/month for the properties in question a */

WITH Cte_Ptr as (
SELECT P.Id,P.Name FROM Keys.dbo.Property P JOIN keys.dbo.OwnerProperty O
ON P.Id = O.PropertyId
Where O.OwnerId = '1426'
)

SELECT CP.Name AS PropertyName,PR.FirstName AS TenantFirstName,PR.LastName AS TenantLastName,PF.Name AS RentalPayment
FROM keys.dbo.TenantProperty T JOIN keys.dbo.TenantPaymentFrequencies PF  ON T.PaymentFrequencyId = PF.id 
JOIN Cte_Ptr CP ON  CP.Id = T.PropertyId
JOIN keys.dbo.tenant TT ON TT.Id = T.TenantId
JOIN keys.dbo.Person PR ON PR.Id = TT.Id
WHERE TT.IsActive='1'
