import requests
import json
import os
import logging
from dotenv import load_dotenv
from datetime import date

load_dotenv()  # Load environment variables from .env file


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("extract_jobs.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

base_url = "https://data.usajobs.gov/api/Search"

headers = {
    "User-Agent": os.getenv("USER_EMAIL"),
    "Authorization-Key": os.getenv("USAJOBS_API_KEY")
}

results_per_page = 500

date_posted = 1

OUTPUT_DIR = f"../analytics/data/bronze/daily/{date.today()}"
os.makedirs(OUTPUT_DIR, exist_ok=True)

logger.info(f"Fetching job postings from {base_url} with date_posted={date_posted}")

all_jobs = []
page = 1

while True:
    params = {
        "ResultsPerPage": results_per_page,
        "Page": page,
        "DatePosted": date_posted
    }

    try:
        logger.info(f"Fetching jobs on page {page} with params: {params}")
        response = requests.get(base_url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()

        results = data["SearchResult"]["SearchResultItems"]
        total = data["SearchResult"]["SearchResultCountAll"]        
        num_pages = int(data["SearchResult"]["SearchResultCountAll"]) // results_per_page + 1
        all_jobs.extend(results)
        logger.info(f"Page {page}/{num_pages} — got {len(results)} jobs (total available: {total})")

        if page>= num_pages:
            logger.info("All pages fetched.")
            break

        page += 1
    except requests.exceptions.RequestException as e:
        logger.error(f"Error occurred while fetching jobs on page {page}: {e}")
        break

output_file = os.path.join(OUTPUT_DIR, f"job_postings.json")

with open(output_file, "w") as f:
    json.dump(all_jobs, f, indent=2)
logger.info(f"Successfully fetched and saved {len(all_jobs)} job postings to {output_file}")