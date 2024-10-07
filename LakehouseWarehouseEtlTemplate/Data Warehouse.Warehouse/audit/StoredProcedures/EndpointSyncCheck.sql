CREATE PROCEDURE audit.EndpointSyncCheck
AS
    DECLARE @Attempt INT = 1

    WHILE OBJECT_ID('Raw_Data_Lakehouse.dbo.sync_check') is null AND @Attempt <=180 --Allow about 30 minutes of waiting
    BEGIN
        Print 'Waiting for Lakehouse Table to appear'
        SET @Attempt += 1
        WAITFOR DELAY '00:00:10'
    END

    IF @Attempt = 181
    BEGIN
        RAISERROR('SQL Endpoint did not sync within 30 minutes', 15, 1)
    END