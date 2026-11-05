import logging
import os

logging.basicConfig(
    level=os.getenv(key="LOGGING_LEVEL", default="INFO"),
    format="%(asctime)s | %(levelname)s | %(funcName)s | %(message)s",
    datefmt="%d-%b-%y %H:%M:%S",
    handlers=[logging.StreamHandler()],
    encoding="utf-8",
)

LOGGER = logging.getLogger