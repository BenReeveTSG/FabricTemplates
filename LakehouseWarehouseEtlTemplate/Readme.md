
# MS Fabric Lakehouse Warehouse ETL Template

This template is based upon using a single Lakehouse to extract data to from source systems and a warehouse to transform and hold the transformed data. The Warehouse is linked to the Lakehouse via T-SQL views

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
  - Create SYnc Check Table
  - Drop Sync Check Tables
  - Generate Lakehouse Date Tables
4. Data Pipelines:
  - Master Pipelines
  - Load Extract Config
  - System1 Data Extract
  - System2 Data Extract
  - Warehouse Refresh
  - Refresh Semantic Models 




## Getting Started
Link an empty Fabric Workspace to this GitHub repo and folder. Once linked, the Workspace will automatically sync with GitHub and copy all items into the workspace.

Once all items have been imported into the workspace, decide if you want a calendar table in your warehouse. If so then:
- Open the Notebook Generate Lakehouse Date Table
- Attach the Lakehouse as a default and then run the Notebook
- Once the Note has completed, go into the Warehouse and perform the following steps:
  - Edit view generic.CalendarDates to remove the line "SELECT 1 AS A" and remove the nested comment start and end. Then commit these changes.
  - Edit proc transform.CreateDimCalendar. Remove the nested comment start and end from line 4 and line 217. Commit the changes.
  - You can choose to run the proc now or leave it for the Warehouse Refresh Pipeline.
- If you don't want the calendar, then you can remove these items from your workspace:
  - Generate Lakehouse Date Table (Notebook)
  - generic.CalendarDates (T-SQL view in Warehouse)
  - transform.CreateDimCalendar (T-SQL Proc in Warehouse)
