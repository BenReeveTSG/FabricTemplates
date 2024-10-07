CREATE PROCEDURE [audit].[AddExtractLogEntryEnd]
  @TableName VARCHAR(100),
  @EndTime DATETIME2(6),
  @Outcome VARCHAR(15)
AS

  UPDATE audit.ExtractLog
  SET
    ExtractEndUTC = @EndTime,
    Outcome = @Outcome

  WHERE
    TableName = @TableName