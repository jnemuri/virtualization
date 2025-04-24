from pyspark.sql import SparkSession

# Initialize a Spark session
spark = SparkSession.builder.appName("SimplePySparkTest").getOrCreate()

# Create a small DataFrame
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
columns = ["Name", "Age"]
df = spark.createDataFrame(data, columns)

# Show the DataFrame
df.show()

# Stop Spark session
spark.stop()