# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {}
# META }

# CELL ********************

df = spark.sql("SHOW TABLES")
rowcount = df.count()
currentRow = 1

for row in df.collect()[0:rowcount]:
    tblName = row["tableName"]
    cmdString = f"OPTIMIZE {tblName} VORDER"
    print(f"Optimising table {tblName} started ({currentRow} of {rowcount})")
    (spark.sql(cmdString))
    cmdString = f"VACUUM {tblName}"
    print(f"Vacuum of table {tblName} started ({currentRow} of {rowcount})")
    (spark.sql(cmdString))
    currentRow += 1

print("Table maintenance complete")


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
