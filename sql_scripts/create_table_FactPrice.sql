-- script to create FactPrice table
CREATE TABLE IF NOT EXISTS {project_id}.{dataset_id}.{table_name} (
	date_id_sk STRING,
	time_id_sk STRING,
	stock_id_sk STRING,
	date_time TIMESTAMP,
	volume INT64,
	price_type STRING,
	price FLOAT64,
	ingestion_time TIMESTAMP,
	ingestion_date STRING,
	stock_code STRING,
	staging_raw_id STRING,
	PRIMARY KEY(date_id_sk, time_id_sk, stock_id_sk) NOT ENFORCED
);

ALTER TABLE `{project_id}.{dataset_id}.{table_name}`
ADD CONSTRAINT fk_date_id_sk
FOREIGN KEY(date_id_sk) REFERENCES `{project_id}.{dataset_id}.DimDate`(date_id) NOT ENFORCED,
ADD CONSTRAINT fk_time_id_sk
FOREIGN KEY(time_id_sk) REFERENCES `{project_id}.{dataset_id}.DimTime`(time_id) NOT ENFORCED,
ADD CONSTRAINT fk_stock_id_sk
FOREIGN KEY(stock_id_sk) REFERENCES `{project_id}.{dataset_id}.DimStock`(stock_id) NOT ENFORCED;
