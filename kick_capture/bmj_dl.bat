SET RESTARTS=0
SET YTDLP_RESTARTS=0
SET UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0"
if NOT "%1"=="" SET RESTARTS=%1
if NOT "%2"=="" SET YTDLP_RESTARTS=%2
cd C:\BMJ\
TIMEOUT 15
START cmd /k %LOCALAPPDATA%\Programs\Python\Python312\python.exe X:\BMJ-Scripts\log_kick_view_count\log_kick_view_count.py -u %UA% -b firefox -c bossmanjack -o Z:\BossmanJack\Kick\Logs -x true
yt-dlp.exe -f "bv*" --write-info-json -R 10 --wait-for-video 15-60 --cookies-from-browser firefox --user-agent %UA% --external-downloader-args "-seg_max_retry 10 -reconnect_on_network_error 1 -reconnect_streamed 1 -reconnect_on_http_error 5xx -report" https://kick.com/bossmanjack
SET YTDLP_EXITCODE=%ERRORLEVEL%
ECHO "EXIT CODE = %YTDLP_EXITCODE%"
if %YTDLP_EXITCODE% EQU 1 SET /A YTDLP_RESTARTS=YTDLP_RESTARTS+1
if %YTDLP_RESTARTS% GTR 10 PAUSE
if %YTDLP_EXITCODE% EQU 1 TIMEOUT 10
if %YTDLP_EXITCODE% EQU 1 .\bmj_dl.bat %RESTARTS% %YTDLP_RESTARTS%
powershell.exe -File "Test-FfmpegDied.ps1"
SET PSEXITCODE=%ERRORLEVEL%
if %RESTARTS% GTR 0 TIMEOUT 10
SET /A RESTARTS=RESTARTS+1
if %PSEXITCODE% NEQ 0 .\bmj_dl.bat %RESTARTS% %YTDLP_RESTARTS%
pause