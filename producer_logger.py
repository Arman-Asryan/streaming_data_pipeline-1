import os
import logging
from configs import log_folder, producer_log_file

logfolder = os.getcwd() + '\\' + log_folder

logging.basicConfig(
    level=logging.INFO,
    filename=os.path.join(logfolder, producer_log_file),
    format="%(asctime)s - %(levelname)s - %(message)s",
)