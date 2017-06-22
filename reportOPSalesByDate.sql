--отчет продажи ОП по дням

CREATE PROCEDURE dbo.reportOPSalesByDate (@startOfTheDay datetime)
AS
  DECLARE @endOfTheDay datetime
  SET @endOfTheDay = DATEADD(SECOND, 60 * 60 * 24 - 1, @startOfTheDay)
  BEGIN
    SELECT
      ct.title,
      SUM(st.sum_payment) * 0.01,
      COUNT(*)
    FROM Arhiv_SOD..SodTrans st
    INNER JOIN Sverka..groundCardTitle ct
      ON st.card_sub_type = ct.card_sub_type
    WHERE st.reg_date_time BETWEEN @startOfTheDay AND @endOfTheDay
    AND st.id_agents = 0
    AND st.card_type IN (150, 252)
    GROUP BY st.card_sub_type,
             ct.title,
             ct.sorting_order
    ORDER BY ct.sorting_order
  END

GO
