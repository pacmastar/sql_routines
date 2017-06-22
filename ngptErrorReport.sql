/*
  запрос следует оптимизировать
  
  */

CREATE PROCEDURE dbo.ngptErrorReport(@stringDate varchar(8),@subtype int, @start datetime, @end datetime)

AS 

  SELECT
    TOP(1)
    @stringDate AS OPER_DATE,
    sn.card_type AS pd_type,
    sn.card_sub_type AS pd_subtype,
    COUNT(*) AS cnt_omp,
    SUM(sn.sum_payment) / 100 AS cash_pmp,
    (SELECT
      COUNT(*)
    FROM Arhiv_SOD..SodTrans st
    WHERE st.card_sub_type = @subtype
    AND st.id_agents = 1
    AND st.reg_date_time BETWEEN @start AND @end)
    AS cnt_op,
    (SELECT
      SUM(st.sum_payment) / 100
    FROM Arhiv_SOD..SodTrans st
    WHERE st.card_sub_type = @subtype
    AND st.id_agents = 1
    AND st.reg_date_time BETWEEN @start AND @end)
    AS cash_op
  FROM SverkaNGPT sn
  WHERE sn.card_sub_type = @subtype
  GROUP BY sn.card_type,
           sn.card_sub_type,
           sn.sum_payment
  ORDER BY SUM(sn.sum_payment) / 100 desc
GO
