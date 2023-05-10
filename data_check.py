import configs
import os
import tasks


if __name__ == "__main__":
    client = tasks.create_client(
        cred_json=configs.cred_json, project_id=configs.project_id
    )

    # check the data in the tables
    tasks.check_table(client=client, project_id=configs.project_id,
                dataset_id=configs.dataset_id, table_name="DimStock")

    tasks.check_table(client=client, project_id=configs.project_id,
                dataset_id=configs.dataset_id, table_name="DimDate")

    tasks.check_table(client=client, project_id=configs.project_id,
                dataset_id=configs.dataset_id, table_name="FactPrice")