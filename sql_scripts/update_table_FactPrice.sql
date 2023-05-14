-- script to update FactPrice table
MERGE `{project_id}.{dataset_id}.{dst_table_name}` dst USING (
    SELECT
        src.Date_Time,
        EXTRACT(YEAR FROM src.Date_Time)*10000+EXTRACT(MONTH FROM src.Date_Time)*100+EXTRACT(DAY FROM src.Date_Time) AS date_id_sk,
        ds.stock_id AS stock_id_sk,
        EXTRACT(HOUR FROM src.Date_Time)*10000+EXTRACT(MINUTE FROM src.Date_Time)*100+EXTRACT(SECOND FROM src.Date_Time) AS time_id_sk,
        src.Volume,
        src.ingestion_time,
        src.ingestion_date,
        src.stock_code,
        src.Staging_Raw_ID,
        src.value,
        src.price_type
    FROM `{project_id}.{dataset_id}.{src_table_name}`
    UNPIVOT (value FOR price_type IN (Open, High, Low, Close, Adj_Close)) AS src
    LEFT JOIN `{project_id}.{dataset_id}.DimStock` ds ON src.stock_code = ds.stock_code
) AS src ON dst.stock_code = src.stock_code AND
            dst.price_type = src.price_type AND
            dst.date_time = src.Date_Time
WHEN MATCHED THEN
    UPDATE SET
        volume = src.Volume,
        price = src.value,
        ingestion_time = src.ingestion_time,
        ingestion_date = src.ingestion_date,
        staging_raw_id = src.Staging_Raw_ID
WHEN NOT MATCHED THEN
    INSERT (
        date_id_sk,
        stock_id_sk,
        time_id_sk,
        date_time,
        volume,
        price_type,
        price,
        ingestion_time,
        ingestion_date,
        stock_code,
        staging_raw_id
    )
    VALUES (
        src.date_id_sk,
        src.stock_id_sk,
        src.time_id_sk,
        src.Date_Time,
        src.Volume,
        src.price_type,
        src.value,
        src.ingestion_time,
        src.ingestion_date,
        src.stock_code,
        src.Staging_Raw_ID
    );


