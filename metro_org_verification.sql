CREATE PROCEDURE dbo.METRO_ORG (@start datetime, @finish datetime)
AS
BEGIN
  CREATE TABLE #temp   (
      card_number decimal(24),
    reg_date_time datetime,
    sum_payment int,
    sum_purse int,
    blank int,
    sold_blank int,
    validator_id int,
    oper int
  )

    SET NOCOUNT ON

  INSERT INTO #temp
    SELECT
     mc.card_number,
      mc.reg_date_time,
      mc.sum_payment,
      mc.sum_purse,
      mc.blank,
      mc.sold_blank,
      mc.place,
      mc.oper
    FROM Sverka.dbo.MetroCompare mc
    LEFT JOIN Arhiv_SOD.dbo.SodTrans st
      ON mc.card_number = st.card_number
      AND mc.sum_payment = st.sum_payment
      AND mc.sum_purse = st.sum_purse
      AND st.card_type = 252
      AND st.reg_date_time BETWEEN @start AND @finish
    WHERE st.card_number IS NULL


  SELECT
    t.card_number,
    t.reg_date_time,
    t.sum_payment,
    t.sum_purse,
    t.blank,
    t.sold_blank,
    t.validator_id,
  CASE 
  	WHEN t.validator_id IN(SELECT  w.id_kass_metro  from baseSOD.dbo.Workplaces w) THEN 0 ELSE 1
  END

  FROM #temp t
  LEFT JOIN MetroTestCards mtc
    ON t.card_number = mtc.card_number
  WHERE mtc.card_number IS NULL
  ORDER BY t.reg_date_time
END
GO
