-- script to update FactPrice table
MERGE `{project_id}.{dataset_id}.{dst_table_name}` dst USING (
    SELECT
        src.Date_Time,
        ds.stock_id AS stock_id_sk,
        dd.date_id AS date_id_sk,
        dt.time_id AS time_id_sk,
        src.Volume,
        src.ingestion_time,
        src.ingestion_date,
        src.stock_code,
        src.Staging_Raw_ID,
        src.value,
        src.price_type
    FROM
        `{project_id}.{dataset_id}.{src_table_name}`
    UNPIVOT (
        value FOR price_type IN (Open, High, Low, Close, Adj_Close)
    ) AS src
    LEFT JOIN `{project_id}.{dataset_id}.DimDate` dd ON CAST(src.Date_Time AS DATE) = dd.full_date
    LEFT JOIN `{project_id}.{dataset_id}.DimStock` ds ON src.stock_code = ds.stock_code
    LEFT JOIN `{project_id}.{dataset_id}.DimTime` dt ON CAST(src.Date_Time AS TIME) = dt.full_time
) AS src ON dst.date_id_sk = src.date_id_sk AND
            dst.stock_id_sk = src.stock_id_sk AND
            dst.time_id_sk = src.time_id_sk AND
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


