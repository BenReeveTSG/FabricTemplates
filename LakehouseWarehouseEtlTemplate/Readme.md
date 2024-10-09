
# MS Fabric Lakehouse Warehouse ETL Template

This template is based upon using a single Lakehouse to extract data to from source systems and a warehouse to transform and hold the transformed data. The Warehouse is linked to the Lakehouse via T-SQL views. The ETL process is managed by an excel file which holds the list of tables to import and the run order of procs in the warehouse for data transformation.

This repo will create the following items within your workspace:
1. Empty Lakehouse
1. A Warehouse containing:
  - Schemas:
    - audit
    - bridging
    - generic
    - transform
  - Tables:
    - audit.ExtractLog, audit.ProcExecutionLog, dbo.Dim_Calendar
  - Views:
    - generic.CalendarDates
  - Stored Prodedures:
    - audit.AddExtractLogEntryEnd
    - audit.AddExtractLogEntryStart
    - audit.AddProcExecutionLogEnd
    - audit.AddProcExecutionLogStart
    - audit.EndpointSyncCheck
    - transform.CreateDimCalendar
3. Notebooks:
  - Create Sync Check Table
  - Drop Sync Check Tables
  - Generate Lakehouse Date Tables
  - Lakehouse Maintenance
4. Data Pipelines:
  - Master Pipelines
  - Load Extract Config
  - System1 Data Extract
  - System2 Data Extract
  - Warehouse Refresh
  - Refresh Semantic Models 




## Getting Started
Link an empty Fabric Workspace to this GitHub repo and folder. Once linked, the Workspace will automatically sync with GitHub and copy all items into the workspace.

Once all items have been imported into the workspace, **unlink the GitHub repo from the workspace.**


Decide if you want a calendar table in your warehouse. Note that at the time of development (8th October 2024), recursive CTEs are not supported in the Warehouse, so notebooks have been used to generate a list of dates. If you want the calendar table then:
- Open the Notebook Generate Lakehouse Date Table and run all cells
- Once the Notebook has completed, go into the Warehouse and perform the following steps:
  - Edit view generic.CalendarDates to remove the line "SELECT 1 AS A" and remove the nested comment start and end. Then commit these changes.
  - Edit proc transform.CreateDimCalendar. Remove the nested comment start and end from line 4 and line 217. Commit the changes.
  - Optionally you can edit this proc further to suit your needs. Currently it produces a date table which goes back to the start of the year 3 years ago and ends 6 months in the future. The @StartDate and @EndDate variables can be altered to change this. Additionally, the date table is based on a financial year that runs from April to March. @CurrentFinancialYearStart and @CurrentFinancialYearEnd can be edited to change this logic.
  - You can choose to run the proc now (EXEC transform.CreateDimCalendar in a new query window) or leave it for the Warehouse Refresh Pipeline.
- If you don't want the calendar, then you can remove these items from your workspace:
  - Generate Lakehouse Date Table (Notebook)
  - generic.CalendarDates (T-SQL view in Warehouse)
  - transform.CreateDimCalendar (T-SQL Proc in Warehouse)

Now connect the following Notebooks to a default Lakehouse
- Create Sync Check Table
- Drop Sync Check Tables
- Lakehouse Maintenance

In the Lakehouse, create a new folder under files called Config (note the capital C). In this new folder you should upload the Data Extract Config.xlsx file after editing it with the correct information for your deployment. The default configuration expects the file to contain a sheet for every system you are linking into the ETL process. Add, remove and rename as necessary, but do not rename the Warehouse Build sheet.

### Pipelines

The provided pipelines provide a structure for the ETL process, but need configuring before they will run as references to other Fabric objects will be broken. This is due to the way Fabric allocates GUIDs to objects and those IDs do not carry over to a new workspace.


**Config extract**
- This should be fine and need no changes

**System1 (and 2) Data Extract**
- Foreach - If - Log start needs the warehouse connection set. Not the proc name as it may be cleared out when setting the new connection
- Foreach - If - Log Success needs the warehouse connection set. Not the proc name as it may be cleared out when setting the new connection
- Foreach - If - Log failure needs the warehouse connection set. Not the proc name as it may be cleared out when setting the new connection
- Foreach - If - Copy data from System1 needs the data source set. If the query value clears itself, then set it to @item().SQLSelect

**Warehouse Refresh**
- Foreach - All 4 run proc activities needs their connection setting to the warehouse

**Refresh Semantic Model**
- Currently this only contains a single disabled semantic model refresh task, so no action needed for now. Later on you can build this pipeline yourself by adding in refresh activities for the semantic models you develop.

**Master pipline**
- Pipeline activities will all need their connection, workspace and pipeline set. Pick the pipeline name that matches the activity name.
- Stored Procedure activity Cheack SQL Endpoint Sync needs its connection set.

Once this has all been configured, then you should be able to run the pipeline.


## Additional Notes
**Maintenance Notebook**

The lakehouse maintenance Notebook isn't attached to any pipelines. I would recommend that this Notebook be scheduled using the notebook schedule to run at a time or day of the week when nothing else is running.

**Renaming Items**
Once all has been configured then you can rename items as required without having to go back and fix pipelines. If you rename the Lakehouse then the calendar dates view in the Warehouse will need updating with the new Lakhouse name.

