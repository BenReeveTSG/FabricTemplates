# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "b6029f84-84ce-4786-943d-0dc72b3c8c55",
# META       "default_lakehouse_name": "Raw_Data_Lakehouse",
# META       "default_lakehouse_workspace_id": "51061a03-089b-4baa-8771-0604308c1bd5"
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
