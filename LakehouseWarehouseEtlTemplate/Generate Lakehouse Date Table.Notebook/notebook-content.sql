-- Fabric notebook source

-- METADATA ********************

-- META {
-- META   "kernel_info": {
-- META     "name": "synapse_pyspark"
-- META   },
-- META   "dependencies": {
-- META     "lakehouse": {
-- META       "default_lakehouse": "0a92f641-fe6a-4293-99ea-ad514e3558f9",
-- META       "default_lakehouse_name": "Raw_Data_Lakehouse",
-- META       "default_lakehouse_workspace_id": "a49cd675-fafc-4137-bc62-156f20a68c8c",
-- META       "known_lakehouses": [
-- META         {
-- META           "id": "0a92f641-fe6a-4293-99ea-ad514e3558f9"
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
-- META   "language": "sql",
-- META   "language_group": "synapse_pyspark"
-- META }

-- CELL ********************

INSERT INTO generic_CalendarDates (CalendarDate)

SELECT explode(sequence(to_date('2000-01-01'), to_date('2050-12-31'), interval 1 day))

-- METADATA ********************

-- META {
-- META   "language": "sql",
-- META   "language_group": "synapse_pyspark"
-- META }
