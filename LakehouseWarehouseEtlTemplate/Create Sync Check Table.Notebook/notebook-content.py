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

# # Welcome to your new notebook
# # Type here in the cell editor to add code!


# CELL ********************

df = spark.sql("SELECT LoadedUTCDateTime FROM Raw_Data_Lakehouse.config_System1ExtractControl LIMIT 1")

df.write.format("delta").saveAsTable("sync_check")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
