CREATE PROCEDURE dbo.sellByCashier (@start DATETIME,
@end DATETIME,
@kassier_code INT)
AS
  SELECT
    * INTO #temp
  FROM Arhiv_SOD..SodTrans
  WHERE reg_date_time BETWEEN @start AND @end
  AND kass_kode > 0
   AND card_type > 149
   AND card_type <= 5206


  AND sum_payment <> 0
  AND kassier_kode = @kassier_code

  SELECT
    ct.title
   ,SUM(st.sum_payment) * 0.01
   ,COUNT(*)
   ,SUM(CASE
      WHEN dos_flag = 1 THEN st.sum_payment
      ELSE 0
    END) * 0.01
  FROM #temp AS st
  INNER JOIN Sverka..groundCardTitle ct
    ON st.card_sub_type = ct.card_sub_type
    AND st.card_type = ct.card_type
  --WHERE 
  --st.reg_date_time BETWEEN '20161201 00:00:00' AND '20161203 00:00:00' AND 
  -- st.card_type BETWEEN 70 and  300
  --AND st.sum_payment > 0
  GROUP BY st.card_sub_type
          ,ct.title
          ,ct.sorting_order
  ORDER BY ct.sorting_order


GO
