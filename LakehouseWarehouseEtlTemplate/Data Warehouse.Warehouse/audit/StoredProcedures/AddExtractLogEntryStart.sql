CREATE PROCEDURE [audit].[AddExtractLogEntryStart]
  @TableName VARCHAR(100),
  @StartTime DATETIME2(6)
AS

  DECLARE @LogCount INT

  SET @LogCount = (SELECT COUNT(*) FROM audit.ExtractLog WHERE TableName = @TableName)

  IF @LogCount = 1
  BEGIN

    UPDATE audit.ExtractLog
    SET
      ExtractStartUTC = @StartTime,
      ExtractEndUTC = NULL,
      Outcome = NULL

    WHERE
      TableName = @TableName

  END
  ELSE
  BEGIN

    INSERT INTO audit.ExtractLog (TableName, ExtractStartUTC)
    VALUES(@TableName, @StartTime)
    
  END