 
CREATE PROCEDURE dbo.ORG_METRO(@start datetime,
@finish datetime)
AS
  BEGIN 
SELECT
  st.id_sod_trans,
  st.card_number,
  st.reg_date_time,
  st.sum_payment,
  st.sum_purse,
 -- w.id_kass_metro
  st.validator_id
FROM Arhiv_SOD.dbo.SodTrans st
--INNER JOIN baseSOD.dbo.Workplaces w
--  ON st.kass_kode = w.Kass_N
LEFT JOIN Sverka.dbo.MetroCompare mc
  ON st.card_type = 252
  AND mc.card_number = st.card_number
  AND mc.sum_payment = st.sum_payment
  AND mc.sum_purse = st.sum_purse
LEFT JOIN Sverka.dbo.MetroTestCards ts
  ON st.card_number = ts.card_number
WHERE st.card_type = 252
AND st.reg_date_time BETWEEN @start AND @finish
AND mc.card_number IS NULL
AND ts.card_number IS NULL
ORDER BY st.reg_date_time

SELECT @start, @finish
  END
GO
