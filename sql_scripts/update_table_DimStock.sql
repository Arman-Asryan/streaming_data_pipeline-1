-- script to update DimStock table
MERGE `{project_id}.{dataset_id}.{dst_table_name}` AS dst
USING (SELECT DISTINCT stock_code FROM `{project_id}.{dataset_id}.{src_table_name}`) AS src
ON dst.stock_code=src.stock_code
  WHEN NOT matched THEN
    INSERT (stock_id,
			stock_code)
	VALUES (Generate_UUID(),
			src.stock_code);
