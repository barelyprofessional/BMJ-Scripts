@ECHO OFF
SET YTDLP_CONCURRENCY=20
SET YTDLP_BROWSER=%2
SET UUID=%1
SET UA=%3
SET SLUG=%4
SET VOD_PATH=Z:\BossmanJack\Kick\LiveVODs

IF EXIST "*%UUID%*" (
    ECHO File already exists using UUID
    EXIT
)

IF EXIST "*%SLUG%*" (
    ECHO File already exists using slug in current directory
    EXIT
)

IF EXIST "%VOD_PATH%\*%SLUG%*" (
    ECHO File already exists using slug in VOD path
    EXIT
)

yt-dlp.exe --write-info-json --cookies-from-browser %YTDLP_BROWSER% --user-agent %UA% -N %YTDLP_CONCURRENCY% https://kick.com/video/%UUID%

