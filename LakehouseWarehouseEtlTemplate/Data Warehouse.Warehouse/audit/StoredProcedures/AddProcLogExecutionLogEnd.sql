CREATE PROCEDURE [audit].[AddProcLogExecutionLogEnd]
  @ProcName VARCHAR(200),
  @EndTime DATETIME2(6),
  @Outcome VARCHAR(15)
AS

  UPDATE audit.ProcExecutionLog
  SET
    ExecutionEndUTC = @EndTime,
    Outcome = @Outcome

  WHERE
    ProcName = @ProcName