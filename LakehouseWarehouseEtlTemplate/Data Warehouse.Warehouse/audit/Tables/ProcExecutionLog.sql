CREATE TABLE [audit].[ProcExecutionLog] (

	[ProcName] varchar(100) NOT NULL, 
	[ExecutionStartUTC] datetime2(6) NULL, 
	[ExecutionEndUTC] datetime2(6) NULL, 
	[Outcome] varchar(30) NULL
);

