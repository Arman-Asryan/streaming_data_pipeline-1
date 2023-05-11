# streaming_data_pipeline
This repository contains scripts to building stock market streaming data pipeline. 

# Abstract
The need for building streaming data pipelines for getting, processing, and analysing data efficiently once it is generated grows in a fast manner. With an increase in demand for fast generation of useful insights, technologies and methods contributing to it develop as well. In the scope of this project, our aim was building a real-time data streaming pipeline while exploring different approaches and the available tools and technologies.

# Content Description

- getting_started.ini: <br>
      contains the configuration data required for the application to produce and consume on Confluent Cloud
- configs.py: <br>
      contains the configuration data required for running the code on Python
- tasks.py: <br>
      contains functions used in the flow 
- sql_scripts (folder): <br>
      contains sql scripts to create, update, delete, and query the tables
- infrastructure_initiation.py: <br>
          - contains the code for the initial creation/deletion of the tables <br>
          - should be run only once at the beginning of the flow <br>
          - running the sql script to create DimTime table is not included in it as the DimTime is a static table, populating which takes really long, thus the table is already created and uploaded to BigQuery (still, the sql script for creating and populating DimTime can be found in sql_scripts folder)     
- producer.py: <br>
 contains the code to: <br>
        - download the data as JSON files <br>
        - upload the JSON fles from local directory to Google Drive <br>
        - delete the files from local directory <br>
        - produce a message and sent it to the consumer as a filename
- consumer.py: <br>
      contains the code to: <br>
        - consume the messages sent by the producer <br>
        - add the data from Google Drive to Cloud as temporary tables <br>
        - update the staging raw table in the Cloud by adding to it the data from the temporary tables <br>
        - delete the temporary tables <br>
        - update dim/fact tables based on the new data from the staging raw table <br>
- data_check.py: <br>
      contains the code to check the availabilty of data generated in the flow by querying the BigQuery tables using Python and printing the tables in Python             console
- Files used for setting up log messages: <br>
      infrastructure_logger.py, consumer_logger.py, producer_logger.py
- Files containing Google Cloud Credentials: 
     * please, download the files from the email message and place the files in the project folder when running the code.
       
      
# Requirements and Flow

Please, perform the following steps to run the project locally:

1) make sure to have Python installed on your machine
2) make sure to have all the files for this project in one directory
3) create a Python virtual environment as follows: <br>
     python -m venv env
4) activate the Python virtual environment created in the previous step as follows: <br>
     env\Scripts\activate
5) to install all the necessary libraries run the following code: <br>
     pip install -r requirements.txt
6) run the infrastructure_initiation.py file only once as follows: <br>
     python infrastructure_initiation.py 
7) run data_check.py (optional) to check that the tables in the cloud have been created 
8) run the consumer file as follows: <br>
      python ./consumer.py getting_started.ini
9) run the producer file as follows: <br>
      python ./producer.py getting_started.ini
10) run data_check.py (optional) to check that the tables in the cloud have been updated 

# Usage
To use this repository, you can clone it to your local machine: git clone https://github.com/kmanukyan7/streaming_data_pipeline.git

# Keywords
Apache Kafka, Python, BigQuery
