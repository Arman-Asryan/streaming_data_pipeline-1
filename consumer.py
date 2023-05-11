from argparse import ArgumentParser, FileType
from configparser import ConfigParser
from confluent_kafka import Consumer, OFFSET_BEGINNING
import tasks
import configs
from consumer_logger import *


if __name__ == '__main__':
    # Parse the command line.
    parser = ArgumentParser()
    parser.add_argument('config_file', type=FileType('r'))
    parser.add_argument('--reset', action='store_true')
    args = parser.parse_args()

    # Parse the configuration.
    # See https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md
    config_parser = ConfigParser()
    config_parser.read_file(args.config_file)
    config = dict(config_parser['default'])
    config.update(config_parser['consumer'])

    # Create Consumer instance
    consumer = Consumer(config)

    # Set up a callback to handle the '--reset' flag.
    def reset_offset(consumer, partitions):
        if args.reset:
            for p in partitions:
                p.offset = OFFSET_BEGINNING
            consumer.assign(partitions)

    # Subscribe to topic
    topic = "purchases"
    consumer.subscribe([topic], on_assign=reset_offset)

    #Poll for new messages from Kafka.
    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                # Initial message consumption may take up to
                # `session.timeout.ms` for the consumer group to
                # rebalance and start consuming
                print("Waiting...")
            elif msg.error():
                print("ERROR: %s".format(msg.error()))
            else:
                # Extract the (optional) key and value, and print.

                print("Consumed event from topic {topic}: key = {key:12} value = {value:12}".format(
                    topic=msg.topic(), key=msg.key().decode('utf-8'), value=msg.value().decode('utf-8')))

                # Add data from drive folder to temporary staging tables
                client = tasks.create_client(configs.cred_json, configs.project_id)
                logging.info('BigQuery client has been created')
                temp_table_name = configs.temp_staging_raw_table_name.format(filename=msg.value().decode('utf-8').split('.')[0])
                tasks.add_data_to_raw_table(gauth_cred=configs.gauth_cred,
                                            cred_json=configs.cred_json,
                                            client_config_file=configs.client_config_file,
                                            folder_id=configs.folder_id,
                                            project_id=configs.project_id, dataset_id=configs.dataset_id,
                                            table_name=temp_table_name, filename=msg.value().decode('utf-8'))
                logging.info(f"Data has been uploaded to cloud as {temp_table_name}")
                logging.info('Downloaded file has been removed')

                # Upload the data from temp table to staging raw table and delete temp table
                tasks.update_staging_raw(client=client, project_id=configs.project_id,
                                         dataset_id=configs.dataset_id,
                                         dst_table_name=configs.staging_raw_table_name,
                                         src_table_name=temp_table_name)
                logging.info(f"{configs.staging_raw_table_name} has been updated and {temp_table_name} deleted successfully")

                # Update dim and fact tables
                tasks.update_dim_stock(client=client, project_id=configs.project_id,
                                       dataset_id=configs.dataset_id,
                                       dst_table_name=configs.dim_tables_to_be_updated['dim_stock'],
                                       src_table_name=configs.staging_raw_table_name)
                logging.info(f"{configs.dim_tables_to_be_updated['dim_stock']} has been updated")

                tasks.update_dim_date(client=client, project_id=configs.project_id,
                                      dataset_id=configs.dataset_id,
                                      date_table_name=configs.dim_tables_to_be_updated['dim_date'])
                logging.info(f"{configs.dim_tables_to_be_updated['dim_date']} has been updated")

                tasks.update_fact_table(client=client, project_id=configs.project_id,
                                        dataset_id=configs.dataset_id, dst_table_name="FactPrice",
                                        src_table_name=configs.staging_raw_table_name)
                logging.info("Fact table has been updated")

    except KeyboardInterrupt:
        pass
    finally:
        # Leave group and commit final offsets
        consumer.close()




