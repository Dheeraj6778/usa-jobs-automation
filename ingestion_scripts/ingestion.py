import requests
import json
import os
import logging


logging.basicConfig(

    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("codelist_ingestion.log"),
        logging.StreamHandler() #used for logging to console
    ]
)

logger = logging.getLogger(__name__)

base_url = "https://data.usajobs.gov/api/codelist/"

CODELISTS = [
    "agencysubelements",
    "occupationalseries",
    "payplans",
    "securityclearances",
    "hiringpaths",
    "positionscheduletypes",
    "positionofferingtypes",
    "travelpercentages",
    "countries",
    "countrysubdivisions",
]

output_dir = "../analytics/data/bronze/codelists/"

for codelist in CODELISTS:
    try:

        url = f"{base_url}{codelist}"
        logger.info(f"Fetching {codelist} from {url}")
        response = requests.get(url)
        data = response.json()
        output_file = f"{output_dir}{codelist}.json"
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        logger.info(f"Writing {codelist} to {output_file}")
        with open(output_file, "w") as f:
            json.dump(data, f, indent=2)
        logger.info(f"Successfully fetched and saved {codelist} to {output_file}")
    except Exception as e:
        logger.error(f"Error occurred while fetching {codelist}: {e}")

logger.info("All codelists have been processed.")