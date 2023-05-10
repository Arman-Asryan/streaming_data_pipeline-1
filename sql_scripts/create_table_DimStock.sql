-- script to create DimStock table
CREATE TABLE IF NOT EXISTS {project_id}.{dataset_id}.{table_name} (
    stock_id STRING NOT NULL,
    stock_code STRING,
    PRIMARY KEY (stock_id) NOT ENFORCED
);
