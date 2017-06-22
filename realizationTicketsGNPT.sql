CREATE PROCEDURE dbo.realizationTicketsGNPT (@start datetime, @finish datetime)
AS
SET @start  = dateadd(HOUR,3,@start)
SET @finish = DATEADD(DAY,1,DATEADD(ss,60*60*3-1,@finish))

BEGIN
    SELECT
   
      ct.title,
      sub.ticketPrice,
      sub.ticketQtyInOrg,
      sub.sumPerCardTypeInOrg,
      sub.ticketQtyInMetro,
      sub.sumPerCardTypeInMetro,
      (sub.ticketQtyInOrg + sub.ticketQtyInMetro) AS qtyOrgAndMetro,
      (sub.sumPerCardTypeInOrg + sub.sumPerCardTypeInMetro) AS sumOrgAndMetro
  FROM (SELECT
    cardSubType = (st.card_sub_type),
    ticketPrice = CAST(sum_payment AS decimal(20, 0)) * 0.01,
    sumPerCardTypeInOrg = SUM(CASE
      WHEN st.id_agents = 0 THEN CAST(sum_payment AS decimal(20, 0)) * 0.01
      ELSE 0
    END),
    ticketQtyInOrg = SUM(CASE
      WHEN st.id_agents = 0 THEN 1
      ELSE 0
    END),
    sumPerCardTypeInMetro = SUM(CASE
      WHEN st.id_agents = 1 THEN CAST(sum_payment AS decimal(20, 0)) * 0.01
      ELSE 0
    END),
    ticketQtyInMetro = SUM(CASE
      WHEN st.id_agents = 1 THEN 1
      ELSE 0
    END)


  FROM Arhiv_SOD..SodTrans st
  WHERE st.card_type = 150
 -- AND NOT (st.begin_date_time < CAST(st.reg_date_time AS date)) --старая проверка на восстановление
 AND st.sum_payment > 0 --новая проверка на восстановление
 AND (st.kassier_kode NOT IN (1500,500) or st.id_agents>1 ) --исключить Щербину, Черных
  AND st.reg_date_time BETWEEN @start AND @finish
  GROUP BY st.card_sub_type,
  st.sum_payment) AS sub

    INNER JOIN Sverka..groundCardTitle ct
      ON sub.cardSubType = ct.card_sub_type

    ORDER BY ct.sorting_order,
      sub.ticketPrice

   
END
GO
