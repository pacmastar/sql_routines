CREATE FUNCTION dbo.moneyInMonth (@begin datetime,
@end datetime,
@sumPayment int)
-- WITH ENCRYPTION, SCHEMABINDING, EXECUTE AS CALLER|SELF|OWNER|USER
RETURNS int
AS
BEGIN
  RETURN
  dbo.daysInMonth(@begin)
  *
  (@sumPayment / (DATEDIFF(DAY, @begin, @end) + 1))
END
GO
