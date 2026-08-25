# scripts/backfill_historical.py
import boto3, requests, json, os, time, logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("backfill_historical.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

s3 = boto3.client("s3")
BUCKET = "usajobs-pipeline-dk"
BASE_URL = "https://data.usajobs.gov/api/historicjoa"
base = "https://data.usajobs.gov"

CHECKPOINT_DIR = "checkpoints"
os.makedirs(CHECKPOINT_DIR, exist_ok=True)

YEAR_RANGES = [
    ("01-01-2018", "12-31-2018"),
    ("01-01-2019", "12-31-2019"),
    ("01-01-2020", "12-31-2020"),
    ("01-01-2021", "12-31-2021"),
    ("01-01-2022", "12-31-2022"),
    ("01-01-2023", "12-31-2023"),
    ("01-01-2024", "12-31-2024"),
    ("01-01-2025", "12-31-2025"),
]

def load_checkpoint(year):
    """Load last successful batch and continuation token for a year."""
    checkpoint_file = f"{CHECKPOINT_DIR}/{year}.json"
    if os.path.exists(checkpoint_file):
        with open(checkpoint_file) as f:
            return json.load(f)
    return None

def save_checkpoint(year, batch, next, total_records):
    """Save progress so we can resume."""
    checkpoint_file = f"{CHECKPOINT_DIR}/{year}.json"
    with open(checkpoint_file, "w") as f:
        json.dump({
            "batch": batch,
            "next": next,
            "total_records": total_records
        }, f)

for start_date, end_date in YEAR_RANGES:
    year = start_date.split("-")[-1]
    logger.info(f"=== Starting extraction for {year} ===")

    checkpoint = load_checkpoint(year)
    batch = 1
    total_records = 0
    retries = 0
    continuation_token = None
    next = None

    if checkpoint:
        batch = checkpoint["batch"]+1
        next = checkpoint["next"]
        total_records = checkpoint["total_records"]
        logger.info(
            f"{year} — resuming from batch {batch} "
            f"({total_records} records already saved)"
        )
        if next is None:
            logger.info(f"{year} — already complete, skipping")
            continue

    
    while True:
        params = {
            "startpositionopendate": start_date,
            "endpositionopendate": end_date,
        }
        

        try:
            logger.info(f"{year} — fetching batch {batch}...")
            response=None
            if batch==1:
                response = requests.get(BASE_URL, params=params)
            else:
                response = requests.get(base+next)
            response.raise_for_status()
            result = response.json()

            records = result.get("data", [])
            if not records:
                logger.info(f"{year} — no more records")
                save_checkpoint(year, batch, None, total_records)
                break

            paging = result.get("paging", {}).get("metadata", {})

            total_count = paging.get("totalCount", "unknown")
            
            # upload batch to S3
            key = f"bronze/historical/{year}/batch_{batch:04d}.json"
            s3.put_object(
                Bucket=BUCKET,
                Key=key,
                Body=json.dumps(records),
                ContentType="application/json",
            )

            total_records += len(records)
            retries = 0  # reset after successful request
            
            logger.info(
                f"{year} — batch {batch} saved ({len(records)} records, "
                f"{total_records} total out of {total_count})"
            )

            # check for next page
            next = result.get("paging",{}).get("next",None)
            save_checkpoint(year, batch, next, total_records)
            if not next:
                logger.info("All pages fetched for year - {year}")
                break

            batch += 1
            time.sleep(1)

        except requests.exceptions.RequestException as e:
            retries += 1
            logger.error(f"{year} — API error on batch {batch}: {e}")

            if retries > 5:
                logger.error(f"{year} — too many retries, skipping to next year")
                break

            wait_time = 30 * retries
            logger.info(f"Retry {retries}/5 — waiting {wait_time}s...")
            time.sleep(wait_time)
            continue

        except Exception as e:
            logger.error(f"{year} — unexpected error on batch {batch}: {e}")
            break

    logger.info(f"=== {year} complete: {total_records} records ===\n")

logger.info("Historical backfill complete")