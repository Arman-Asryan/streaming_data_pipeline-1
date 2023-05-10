-- script to load data from temp tables to the staging raw table
MERGE {project_id}.{dataset_id}.{dst_table_name} AS dst 
USING {project_id}.{dataset_id}.{src_table_name} AS src
ON dst.Date_Time = src.Date_Time AND dst.stock_code=src.stock_code
  WHEN NOT matched THEN 
    INSERT (Date_Time,
			Open,
			High,
			Low,
			Close,
			Adj_Close,
			Volume,
			ingestion_time,
			ingestion_date,
			stock_code,
			Staging_Raw_ID)
	VALUES (src.Date_Time,
			src.Open,
			src.High,
			src.Low,
			src.Close,
			src.Adj_Close,
			src.Volume,
			src.ingestion_time,
			src.ingestion_date,
			src.stock_code,
			src.Staging_Raw_ID);
  
    