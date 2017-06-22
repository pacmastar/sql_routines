CREATE PROCEDURE dbo.totalSellReportByPoint (@start DATETIME,
@end DATETIME)

AS

    SELECT
    * INTO #temp
  FROM Arhiv_SOD..SodTrans
  WHERE reg_date_time BETWEEN @start AND @end
  AND kass_kode > 0
  AND card_type BETWEEN 149 AND 5207
  AND sum_payment > 0



  SELECT
  st.kassier_kode
 ,ct.title
 ,COUNT(*) AS sellCnt
 ,SUM(st.sum_payment) * 0.01 AS sumTotal
 ,SUM(CASE
    WHEN st.dos_flag = 1 THEN 1
    ELSE 0
  END) AS cntCashless
 ,SUM(CASE
    WHEN st.dos_flag = 1 THEN st.sum_payment
    ELSE 0
  END) * 0.01 AS sumCashless
FROM #temp st
INNER JOIN Sverka..groundCardTitle ct
  ON st.card_sub_type = ct.card_sub_type
    AND st.card_type = ct.card_type
GROUP BY st.kassier_kode
        ,st.card_sub_type
        ,ct.title
        ,ct.sorting_order
ORDER BY st.kassier_kode
,  ct.sorting_order

GO
