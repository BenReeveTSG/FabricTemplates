# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse_name": "",
# META       "default_lakehouse_workspace_id": ""
# META     }
# META   }
# META }

# MARKDOWN ********************

# # Notes
# 
# ###### Notebook is not scheduled as it will always create the same set of dates unless altered. Run manually if needed.
# ###### Calendar dates are generated here rather than in the Warehouse with T-SQL because at the date of development (14th August 2024) recursive CTEs are not supported.
# 
# ###### No need to attach a default lakehouse


# MARKDOWN ********************

# ##### Get workspace id and lakehouse id

# CELL ********************

import sempy.fabric as fabric
import pandas as pd
from pyspark.sql import functions as f

df = spark.createDataFrame(pd.concat([fabric.list_items(workspace=ws) for ws in fabric.list_workspaces().query('`Is On Dedicated Capacity` == True').Id], ignore_index=True))

workspace_id = fabric.resolve_workspace_id()
workspace_id
df = df.filter((f.col("`Workspace Id`") == workspace_id) & (df.Type == "Lakehouse") & ~(f.col("`Display Name`").like('%Staging%')))
lakehouse_id = df.collect()[0]['Id']
print("Workspace Id = " + workspace_id)
print("Lakehouse Id = " + lakehouse_id)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ##### Build a table of dates. Store using the workspace id and lakehouse id from the previous step

# CELL ********************

df = (
    spark
    .createDataFrame([{'date':1}])
    .select(
        f.explode(f.sequence(
            f.to_date(f.lit('2000-01-01')), # start
            f.to_date(f.lit('2050-12-31')), # stop
            f.expr("INTERVAL 1 DAY")     # step
        )).alias('CalendarDate')
    )
)
#display(df)

df.write.format("delta").mode("overwrite").save(f"abfss://{workspace_id}@onelake.dfs.fabric.microsoft.com/{lakehouse_id}/Tables/generic_calendardates")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
