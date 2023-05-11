import sys
from random import choice
from argparse import ArgumentParser, FileType
from configparser import ConfigParser
from confluent_kafka import Producer
import os
import time
from datetime import datetime, timedelta
import pandas as pd
import configs
import tasks
import json
import logging
from configs import log_folder, downloaded_data_folder
from producer_logger import *
import utils

downloaded_data = os.getcwd() + '\\' + downloaded_data_folder
if not os.path.exists(downloaded_data):
    os.makedirs(downloaded_data)

logfolder = os.getcwd() + '\\' + log_folder
if not os.path.exists(logfolder):
    os.makedirs(logfolder)

def exec(stock_code, producer):
    current_date = datetime.now()
    start_date = utils.find_start_date(current_date)
    start_date = datetime.strftime(start_date, '%Y-%m-%d')

    # download stock data
    filepath = os.getcwd() + downloaded_data_folder
    filename = stock_code + '_' + current_date.strftime('%Y%m%d%H%M%S') + '.json'
    logging.info('Trying to download data for {stock_code} since {date}'.format(date=start_date,
                                                                                stock_code=stock_code))
    download_status = tasks.download_from_yfinance(ticker=stock_code, start_date=start_date,
                                                   current_date=current_date,
                                                   filename=filepath + '\\' + filename)
    logging.info("Data has been downloaded")

    if download_status['stop'] == False:

        tasks.upload_from_local_to_drive(gauth_cred=configs.gauth_cred,
                                         client_config_file=configs.client_config_file,
                                         folder_id=configs.folder_id,
                                         filename=filepath + '\\' + filename, file_name=filename)
        logging.info(f"{filename} has been uploaded to drive")

        # delete the file from local folder
        os.remove(filepath + '\\' + filename)
        logging.info(f"{filename} has been deleted from local folder")

        producer.produce(topic, key=stock_code, value=filename, callback=delivery_callback)
        producer.poll()
        logging.info(f"{filename} has been sent to consumer")
    else:
        print(download_status['message'])

if __name__ == '__main__':
    #Parse the command line.
    parser = ArgumentParser()
    parser.add_argument('config_file', type=FileType('r'))
    args = parser.parse_args()

    # Parse the configuration.
    # See https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md
    config_parser = ConfigParser()
    config_parser.read_file(args.config_file)
    config = dict(config_parser['default'])

    # Create Producer instance
    producer = Producer(config)

    # Optional per-message delivery callback (triggered by poll() or flush())
    # when a message has been successfully delivered or permanently
    # failed delivery (after retries).
    def delivery_callback(err, msg):
        if err:
            print('ERROR: Message failed delivery: {}'.format(err))
        else:
            print("Produced event to topic {topic}: key = {key:12} value = {value:12}".format(
                topic=msg.topic(), key=msg.key().decode('utf-8'), value=msg.value().decode('utf-8')))


    # Produce data by downloading it from Yahoo Finance
    topic = "purchases"

    while True:
        exec(configs.stock_code_apple, producer)
        time.sleep(90)

        exec(configs.stock_code_tesla, producer)
        time.sleep(90)

        exec(configs.stock_code_amazon, producer)
        time.sleep(90)



