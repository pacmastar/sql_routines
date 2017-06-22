CREATE PROCEDURE dbo.sellReportGroundBSK (@start DATETIME, @end DATETIME)
AS
  SET NOCOUNT ON
  SET ANSI_WARNINGS OFF

  SELECT
    st.card_sub_type
   ,MONTH(st.begin_date_time) AS mnth
   ,st.sum_payment
   ,st.id_agents
   ,st.begin_date_time
   ,st.end_date_time
   ,COUNT(*) AS qtyTickets INTO #vrem
  FROM Arhiv_SOD..SodTrans st

  WHERE st.reg_date_time
  BETWEEN @start AND @end
  -- AND NOT (st.begin_date_time < CAST(st.reg_date_time AS date)) старая проверка на восстановление 
  AND st.sum_payment <> 0 -- новая проверка на восстановление
  AND st.card_type = 150
  GROUP BY st.card_sub_type
          ,st.sum_payment
          ,st.begin_date_time
          ,st.end_date_time
          ,st.id_agents



  SELECT
    a.card_sub_type
   ,a.sum_payment
   ,MONTH(a.begin_date_time) AS m
   ,YEAR(a.begin_date_time) AS y
   ,a.id_agents
   ,SUM(CAST(a.sum_payment AS DECIMAL(10, 0)) * a.qtyTickets) AS summ
   ,SUM(CAST(a.qtyTickets AS DECIMAL(10, 0)) * a.sum_payment * dbo.daysInMonth(a.begin_date_time) / CAST(DAY(DATEADD(dd, -DAY(DATEADD(mm, 1, a.begin_date_time)), DATEADD(mm, 1, a.begin_date_time))) AS DECIMAL(3, 0))) AS total INTO #temp
  FROM #vrem a
  GROUP BY
  --    ct.title,
  --ct.card_sub_type,
  a.card_sub_type
 ,a.sum_payment
 ,MONTH(a.begin_date_time)
 ,YEAR(a.begin_date_time)
 ,a.id_agents
  ORDER BY a.id_agents, a.card_sub_type, MONTH(a.begin_date_time)


  --select * FROM #temp t
  SELECT
    CASE
      WHEN ss.id_agents = 0 THEN 'ОП'
      ELSE 'Метро'
    END
   ,CASE card_sub_type

      WHEN 1 THEN 'Автобус'
      WHEN 2 THEN 'Трамвай'
      WHEN 3 THEN 'Троллейбус'
      WHEN 4 THEN 'Трамвай-Автобус'
      WHEN 5 THEN 'Троллейбус-Автобус'
      WHEN 6 THEN 'Трамвай-Троллейбус'
      WHEN 7 THEN 'Трамвай-Троллейбус-Автобус'
      WHEN 8 THEN 'Ученический'
      WHEN 9 THEN 'Студенческий НГПТ'

    -- ELSE
    END
   ,CAST(M AS VARCHAR(2)) + '.' + CAST(Y AS VARCHAR(4))
   ,st * 0.01
   ,summ = SUM(sum1)
  FROM (SELECT
      id_agents
     ,card_sub_type
     ,Y
     ,M
     ,st = sum_payment
     ,sum1 = SUM(total) * 0.01
    FROM #temp t
    GROUP BY id_agents
            ,card_sub_type
            ,Y
            ,M
            ,sum_payment
    UNION
    SELECT
      id_agents
     ,card_sub_type
     ,y =
         CASE
           WHEN m = 12 THEN y + 1
           ELSE y
         END
     ,m =
         CASE
           WHEN m = 12 THEN 1
           ELSE m + 1
         END
     ,st = sum_payment
     ,sum1 = SUM((CAST(summ AS DECIMAL(13, 2)) - total)) * 0.01
    FROM #temp t
    GROUP BY id_agents
            ,card_sub_type
            ,CASE
               WHEN m = 12 THEN y + 1
               ELSE y
             END
            ,CASE
               WHEN m = 12 THEN 1
               ELSE m + 1
             END
            ,sum_payment) ss
  GROUP BY CASE
             WHEN ss.id_agents = 0 THEN 'ОП'
             ELSE 'Метро'
           END
          ,card_sub_type
          ,st
          ,CAST(M AS VARCHAR(2)) + '.' + CAST(Y AS VARCHAR(4))

  ORDER BY CASE
    WHEN ss.id_agents = 0 THEN 'ОП'
    ELSE 'Метро'
  END, card_sub_type, st, CAST(M AS VARCHAR(2)) + '.' + CAST(Y AS VARCHAR(4))

GO
