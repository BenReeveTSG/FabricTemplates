CREATE TABLE [audit].[ExtractLog] (

	[TableName] varchar(100) NOT NULL, 
	[ExtractStartUTC] datetime2(6) NULL, 
	[ExtractEndUTC] datetime2(6) NULL, 
	[Outcome] varchar(30) NULL
);

