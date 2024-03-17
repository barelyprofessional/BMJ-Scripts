#!/usr/bin/env python

import logging
import requests
from yt_dlp import cookies
import argparse
import subprocess

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

parser = argparse.ArgumentParser(prog='grab_kick_vods', description='Grab Kick VODs for a given channel')

parser.add_argument("-u", "--user-agent", required=True, help="Browser UA must match browser cookies were sourced from")
parser.add_argument("-b", "--browser", required=True, help="Browser to get cookies from (piggybacks yt-dlp)")
parser.add_argument("-c", "--channel", required=True, help="Name of the Kick channel")
parser.add_argument("-s", "--script", required=False, default="grab_kick_vod.bat")
args = parser.parse_args()
logger.info(f"Args parsed. UA: {args.user_agent}, Browser: {args.browser}, Channel: {args.channel}, Script: {args.script}")


def download_vod(vod_uuid: str, vod_slug: str):
    logger.info(f"Downloading {vod_uuid}")
    subprocess.call([args.script, vod_uuid, args.browser, f"{args.user_agent}", vod_slug])


cookies = cookies.extract_cookies_from_browser(args.browser)
logger.info("Got cookies from the browser")
headers = {
    'User-Agent': args.user_agent,
    'Accept': '*/*',
    'Accept-Language': 'en-US,en;q=0.5'
}
r = requests.get(f"https://kick.com/api/v1/channels/{args.channel}", cookies=cookies, headers=headers)
logger.info("Got response from the Kick API")
data = r.json()
for vod in data["previous_livestreams"]:
    logger.info(f"Downloading {vod["slug"]}, UUID is {vod["video"]["uuid"]}")
    download_vod(vod['video']['uuid'], vod['slug'])

logger.info("Done!")
