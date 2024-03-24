from yt_dlp import cookies
import requests
import logging
import argparse
import time
import csv
import datetime
import os


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

parser = argparse.ArgumentParser(prog='log_kick_view_count', description='Log viewer count for Kick livestreams')

parser.add_argument("-u", "--user-agent", required=True, help="Browser UA must match browser cookies were sourced from")
parser.add_argument("-b", "--browser", required=True, help="Browser to get cookies from (piggybacks yt-dlp)")
parser.add_argument("-c", "--channel", required=True, help="Name of the Kick channel")
parser.add_argument("-o", "--output-path", required=True, help="CSV output file path. File will be named based on date")
parser.add_argument("-i", "--interval", default=60, help="Log interval in seconds")
parser.add_argument("-x", "--exit-on-offline", type=bool, default=False,
                    help="Whether the script should exit when livestream goes offline")
args = parser.parse_args()
logger.info(f"Args parsed. UA: {args.user_agent}, Browser: {args.browser}, Channel: {args.channel}, Output Path: "
            f"{args.output_path}, Interval: {args.interval}, Exit On Offline: {args.exit_on_offline}")
csv_name = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%d_%H-%M.csv")
full_path = os.path.join(args.output_path, csv_name)
logger.info(f"Full path for CSV is {full_path}")

while True:
    cookie_jar = cookies.extract_cookies_from_browser(args.browser)
    logger.info("Got cookies from the browser")
    headers = {
        'User-Agent': args.user_agent,
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.5'
    }
    try:
        r = requests.get(f"https://kick.com/api/v2/channels/{args.channel}/livestream", cookies=cookie_jar, headers=headers)
        data = r.json()
    except Exception as e:
        logger.error(f"Caught exception while retrieving livestream endpoint: {e}")
        logger.error("Sleeping for 15 seconds then will try again")
        time.sleep(15)
        continue
    logger.info("Request succeeded")

    if data["data"] is not None:
        logger.info("Channel is live")
        fields = [datetime.datetime.now(datetime.UTC).isoformat(), args.channel, data['data']['viewers']]
        logger.info(f"Fields: {fields}")
        if not os.path.exists(full_path):
            logger.info("CSV doesn't exist, creating")
            preamble = f"""# Stream-ID: {data["data"]["id"]}
# Stream-Slug: {data["data"]["slug"]}
# Stream-Session-Title: {data["data"]["session_title"]}
# Stream-Created-At: {data["data"]["created_at"]}
Time,Channel,Viewers
"""
            with open(full_path, "w", encoding='utf-8') as f:
                f.write(preamble)
            logger.info("Wrote preamble to CSV")

        with open(full_path, 'a', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(fields)
            logger.info("Wrote row to CSV")

    if data["data"] is None and args.exit_on_offline:
        logger.info("No longer live and script is set to exit on offline")
        exit(0)

    logger.info(f"Sleeping for {args.interval} seconds")
    time.sleep(args.interval)
