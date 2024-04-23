import requests
import json
import argparse
import logging
import os
from pathvalidate import sanitize_filepath

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

parser = argparse.ArgumentParser(prog='rapfame_dl', description="Download everything from a real nigga's Rap Fame page")

parser.add_argument('user_id', type=int, help="User ID obtainable from meta tags on the page")
parser.add_argument('-o', '--output', required=True, type=str, help="Output directory")
parser.add_argument('-l', '--limit', required=False, type=int, help="Number of tracks to get", default=1000)

args = parser.parse_args()

logger.info(f"Starting. Fetching from {args.user_id} with limit {args.limit} and outputting to {args.output}")

http_headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0',
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.5',
}

url = f"https://www.api-battleme.com/battleme/tracks/promos?userId={args.user_id}&count={args.limit}"
logger.info(f"Retrieving {url}")

r = requests.get(url, headers=http_headers)
r.raise_for_status()
tracks = r.json()
logger.info(f"Fetched {len(tracks["result"])} tracks")

for track in tracks["result"]:
    logger.info(f"Downloading {track['name']} from {track['url']}")
    mp4 = requests.get(track["url"], headers=http_headers, stream=True)
    path_prefix = sanitize_filepath(os.path.join(args.output, f"{track['trackId']}-{track['user']['userName']}-{track['name']}"))
    if os.path.exists(f"{path_prefix}.mp4"):
        logger.info(f"Skipping {track['name']} as it has already been downloaded")
        continue

    with open(f"{path_prefix}.mp4", "wb") as f:
        for chunk in mp4.iter_content(chunk_size=4096):
            f.write(chunk)
    logger.info(f"Downloaded MP4 to {path_prefix}.mp4")

    thumb = requests.get(track["imgUrl"], headers=http_headers, stream=True)
    with open(f"{path_prefix}.jpg", "wb") as f:
        for chunk in thumb.iter_content(chunk_size=4096):
            f.write(chunk)
    logger.info(f"Downloaded image to {path_prefix}.jpg")

    with open(f"{path_prefix}.json", "w") as f:
        f.write(json.dumps(track, indent=4))
    logger.info(f"Saved metadata to {path_prefix}.json")

    logger.info(f"Setting file time to track creation time")
    track_time = track['createdAt'] / 1000
    os.utime(f"{path_prefix}.mp4", (track_time, track_time))
    os.utime(f"{path_prefix}.jpg", (track_time, track_time))
    os.utime(f"{path_prefix}.json", (track_time, track_time))

    logger.info(f"Finished with {track['name']}")

logger.info(f"Finished grabbing tracks")
