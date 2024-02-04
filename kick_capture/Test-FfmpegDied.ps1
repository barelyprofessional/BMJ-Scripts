$FfmpegWindow = [DateTime]::Now.AddMinutes(-5)
# PowerShell is so retarded
# The -Include parameter doesn't do shit unless you include -Recurse
# Of course it doesn't warn you.
$MostRecentLog = Get-ChildItem -Recurse -Include "*.log" | Where-Object {$_.LastWriteTime -gt $FfmpegWindow} | Sort-Object LastWriteTime -Descending
if ($null -eq $MostRecentLog)
{
    Write-Output "No log found since $FfmpegWindow, exiting"
    Exit 0
}

# Generally the error is in the last 50 lines so this should be safe
# We don't really want to look at the whole log in case there was an error much earlier that was recovered from
# We're looking for this line "Failed to reload playlist 0"
$Content = Get-Content -Path $MostRecentLog.FullName -Tail 100
if ($Content -match "Failed to reload playlist 0")
{
    Write-Output "ffmpeg shit the bed, returning 1 so the script will restart"
    Exit 1
}

Write-Output "No error found in the log"