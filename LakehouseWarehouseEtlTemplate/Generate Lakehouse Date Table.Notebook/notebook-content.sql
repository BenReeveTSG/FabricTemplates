-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "synapse_pyspark"
-- META   },
-- META   "dependencies": {
-- META     "lakehouse": {
-- META       "default_lakehouse": "b6029f84-84ce-4786-943d-0dc72b3c8c55",
-- META       "default_lakehouse_name": "Raw_Data_Lakehouse",
-- META       "default_lakehouse_workspace_id": "51061a03-089b-4baa-8771-0604308c1bd5",
-- META       "known_lakehouses": [
-- META         {
-- META           "id": "b6029f84-84ce-4786-943d-0dc72b3c8c55"
-- META         }
-- META       ]
-- META     }
-- META   }
-- META }

-- MARKDOWN ********************

-- # Notes
-- 
-- ###### Notebook is not scheduled as it will always create the same set of dates unless altered. Run manually if needed.
-- ###### Calendar dates are generated here rather than in the Warehouse with T-SQL because at the date of development (14th August 2024) recursive CTEs are not supported.

-- CELL ********************

CREATE OR REPLACE TABLE generic_CalendarDates
(
    CalendarDate DATE
)


-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

INSERT INTO generic_CalendarDates (CalendarDate)

SELECT explode(sequence(to_date('2000-01-01'), to_date('2050-12-31'), interval 1 day))

-- METADATA ********************

-- META {
-- META   "language": "sparksql",
-- META   "language_group": "synapse_pyspark"
-- META }
