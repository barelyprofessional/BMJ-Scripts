SET YTDLP_CONCURRENCY=20
SET YTDLP_BROWSER=%2
SET UUID=%1
SET UA=%3

IF EXIST "*%UUID%*" (
    ECHO File already exists
    EXIT
)

yt-dlp.exe --write-info-json --cookies-from-browser %YTDLP_BROWSER% --user-agent %UA% -N %YTDLP_CONCURRENCY% https://kick.com/video/%UUID%

