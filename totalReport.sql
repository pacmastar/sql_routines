CREATE PROCEDURE dbo.totalReport(@start datetime, @finish datetime)
AS
--SET @start  = dateadd(HOUR,3,@start)
--SET @finish = DATEADD(DAY,1,DATEADD(ss,60*60*3-1,@finish))

BEGIN
select st.card_type, st.card_sub_type, st.sum_payment, st.id_agents 
INTO #temp
FROM Arhiv_SOD..SodTrans st
WHERE st.reg_date_time BETWEEN @start AND @finish 

	SELECT
  ct.title
 ,cntOP = SUM(CASE WHEN st.id_agents = 0 THEN 1 ELSE 0 END)
 ,summOP = SUM(CASE WHEN st.id_agents = 0 THEN CAST(sum_payment AS decimal(20, 0)) * 0.01 ELSE 0 END)
 ,cntMetro = SUM(CASE WHEN st.id_agents = 1 THEN 1  ELSE 0 END)
 ,sumMetro = SUM(CASE WHEN st.id_agents = 1 THEN CAST(sum_payment AS decimal(20, 0)) * 0.01  ELSE 0 END) 
  
FROM #temp st INNER JOIN Sverka..groundCardTitle ct
  ON ct.card_type = st.card_type 
  AND ct.card_sub_type = st.card_sub_type
  AND st.card_type IN (249,231,232,233,234,235,236,252,150) --OR st.card_sub_type IN (0,1,2,3,4,5,6,7,8,9)
  --  AND st.card_type > 149 AND st.card_type < 5207
  GROUP BY 
  ct.title
    ,ct.sorting_order
  ORDER BY ct.sorting_order
END
GO
