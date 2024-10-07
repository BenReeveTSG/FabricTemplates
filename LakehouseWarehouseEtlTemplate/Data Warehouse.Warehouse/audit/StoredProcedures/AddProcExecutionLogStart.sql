CREATE PROCEDURE [audit].[AddProcExecutionLogStart]
    @ProcName VARCHAR(100),
    @StartTime DATETIME2(6)
  AS

    DECLARE @LogCount INT

    SET @LogCount = (SELECT COUNT(*) FROM audit.ProcExecutionLog WHERE ProcName = @ProcName)

    IF @LogCount = 1
    BEGIN

      UPDATE audit.ProcExecutionLog
      SET
        ExecutionStartUTC = @StartTime,
        ExecutionEndUTC = NULL,
        Outcome = NULL

      WHERE
        ProcName = @ProcName

    END
    ELSE
    BEGIN

      INSERT INTO audit.ProcExecutionLog (ProcName, ExecutionStartUTC)
      VALUES(@ProcName, @StartTime)
      
    END