CREATE PROCEDURE dbo.sellCashierByDate( 
  @start DATETIME, 
  @end DATETIME,
  @kassier_code INT
  )
AS 
SELECT *
 into #temp
 FROM Arhiv_SOD..SodTrans 
 WHERE reg_date_time BETWEEN @start and @end
 AND kass_kode > 0
  AND card_type > 149
  AND card_type < 5207
  AND sum_payment <> 0
 AND kassier_kode = @kassier_code
  AND kass_kode > 0

SELECT
  CONVERT(DATE, st.reg_date_time)
 ,ct.title
 ,SUM(st.sum_payment) * 0.01
 ,COUNT(*)
 ,SUM(CASE
    WHEN dos_flag = 1 THEN st.sum_payment
    ELSE 0
  END) * 0.01
FROM #temp st
INNER JOIN Sverka..groundCardTitle ct
  ON st.card_sub_type = ct.card_sub_type
  AND st.card_type = ct.card_type
WHERE st.reg_date_time BETWEEN @start AND @end
GROUP BY CONVERT(DATE, st.reg_date_time)
        ,st.card_sub_type
        ,ct.title
        ,ct.sorting_order
ORDER BY CONVERT(DATE, st.reg_date_time), ct.sorting_order


GO
