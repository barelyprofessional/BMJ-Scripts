This script is used to grab all Kick VODs in a channel. It borrows `yt-dlp`'s
cookie grabber to retrieve the necessary cookies to satisfy Cloudflare and then
retrieves the VOD list from the Kick API.

Once the VOD list is retrieved, the script will run a companion script for each
VOD until it reaches the end of the list. An example script `grab_kick_vod.bat`
implements the basic functionality of grabbing VODs not yet retrieved using
`yt-dlp`.

# Usage

* `-u` / `--user-agent` Provide the User-Agent of the browser whose cookies you
are borrowing. It must match exactly or you'll risk encountering 403s. Tip: Use
`about:support` to quickly get your User-Agent in Firefox
* `-b` / `--browser` Pass in the name of the browser to rip cookies from. Same
as the `--cookies-from-browser` option from `yt-dlp`
* `-c` / `--channel` Name of the channel to grab VODs from, e.g. BossmanJack,
INSLIMEWETRUSTLIVE, madattheinternet, etc.
* `-s` / `--script` Script / executable to run for grabbing each VOD. Defaults
to `grab_kick_vod.bat`

# Script

The included `grab_kick_vod.bat` batch file should be sufficient for most
purposes. Special snowflakes (Linux users?) may wish to provide their own.

You can use anything that's executable, and you should expect 3 positional
arguments

1. VOD UUID
2. Browser string passed in `-b` / `--browser`
3. User-Agent string passed in `-u` / `--user-agent` wrapped in double quotes

e.g. `example.sh ac644e94-1cc5-47af-aaaa-9bf4ede84a47 firefox "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:122.0) Gecko/20100101 Firefox/122.0"`