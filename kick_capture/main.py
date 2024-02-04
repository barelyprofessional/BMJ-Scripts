#!/usr/bin/env python

import asyncio
import websockets
import logging
import json
import subprocess

logger = logging.getLogger('websockets')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

new_proc_flags = 0
new_proc_flags |= 0x00000010  # CREATE_NEW_CONSOLE

new_proc_pkwargs = {
    'close_fds': True,
    'creationflags': new_proc_flags
}


async def kick_client():
    uri = "wss://ws-us2.pusher.com/app/eb1d5f283081a78b932c?protocol=7&client=js&version=7.6.0&flash=false"
    initial_payload = '{"event":"pusher:subscribe","data":{"auth":"","channel":"channel.2515504"}}'
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            logger.info(f"Received data from Kick's pusher API: {message}")
            data = json.loads(message)
            if data["event"] == "pusher:connection_established":
                await websocket.send(initial_payload)
                logger.info("Sent initial channel subscription payload")
                continue

            if data["event"] == "pusher_internal:subscription_succeeded":
                logger.info(f"Subscription to {data['channel']} succeeded")
                continue

            if data["event"] == r"App\Events\StreamerIsLive":
                logger.info("Streamer is live?")
                logger.info(message)
                p = subprocess.Popen(['cmd', '/K', r'C:\BMJ\bmj_dl.bat'], **new_proc_pkwargs)
                continue

            logger.info(f"Event {data['event']} wasn't handled")

if __name__ == "__main__":
    asyncio.run(kick_client())