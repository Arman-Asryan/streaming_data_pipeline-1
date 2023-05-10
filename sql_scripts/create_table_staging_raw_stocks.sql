-- script to create the staging raw table
CREATE TABLE IF NOT EXISTS {project_id}.{dataset_id}.{table_name} (
Date_Time TIMESTAMP,
Open FLOAT64,
High FLOAT64,
Low FLOAT64,
Close FLOAT64,
Adj_Close FLOAT64,
Volume INT64,
ingestion_time TIMESTAMP,
ingestion_date STRING,
stock_code STRING,
Staging_Raw_ID STRING);	
