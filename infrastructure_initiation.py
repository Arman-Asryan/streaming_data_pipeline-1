import configs
import tasks
import os
import logging
from configs import log_folder
from infrastructure_logger import *

logs_folder = os.getcwd() + '\\' + log_folder
if not os.path.exists(logs_folder):
    os.makedirs(logs_folder)

if __name__ == "__main__":
    client = tasks.create_client(
        cred_json=configs.cred_json, project_id=configs.project_id
    )
    logging.info(f"Client object has been created in {configs.project_id}")

    # create the schema
    tasks.create_schema(
        client=client, project_id=configs.project_id, dataset_id=configs.dataset_id
    )
    logging.info(f"Schema {configs.dataset_id} has been created in {configs.project_id}")

    # drop tables if they exist
    tasks.drop_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name=configs.staging_raw_table_name
    )
    logging.info(f"{configs.staging_raw_table_name} table has been dropped")

    tasks.drop_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name="DimStock"
    )
    logging.info("DimStock table has been dropped")

    tasks.drop_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name="FactPrice"
    )
    logging.info("FactPrice table has been dropped")

    # create tables
    tasks.create_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name=configs.staging_raw_table_name
    )
    logging.info(f"{configs.staging_raw_table_name} table has been created")

    tasks.create_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name="DimStock"
    )
    logging.info("DimStock table has been created")

    tasks.create_table(
        client=client,
        project_id=configs.project_id,
        dataset_id=configs.dataset_id,
        table_name="FactPrice"
    )
    logging.info("FactPrice table has been created")