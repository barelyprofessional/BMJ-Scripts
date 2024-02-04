[CmdletBinding()]
param (
    [string]$VodSource = "Z:\BossmanJack\Kick\PendingUpload",
    [string]$WavDestination = "Z:\BossmanJack\Kick\WAVs"
)

if (-not (Test-Path $VodSource))
{
    Write-Error "VodSource '$VodSource' does not exist. Exiting"
    Exit 1
}

if (-not (Test-Path $WavDestination))
{
    Write-Error "WavDestination '$WavDestination' does not exist. Exiting"
    Exit 1
}

# The cast to object[] is to ensure it's always an array,
# even if only a single item is returned
[object[]]$Files = Get-ChildItem -Path $VodSource -File -Include "*.mp4" -Recurse
$Count = $Files.Count
Write-Host "Got $Count files to process" -ForegroundColor Cyan
$i = 0

foreach ($File in $Files)
{
    $i++
    Write-Progress -Activity "Extracting audio" -Status "$i of $Count ($($File.BaseName))" -PercentComplete ($i / $Count * 100)
    $NewWavFile = (Join-Path $WavDestination "$($File.BaseName).wav")
    Write-Host "Writing to $NewWavFile ($i of $Count)" -ForegroundColor Cyan
    if ([System.IO.File]::Exists($NewWavFile))
    {
        Write-Host "$NewWavFile already exists. Skipping." -ForegroundColor Green
        continue
    }

    ffmpeg.exe -i "$($File.FullName)" -ar 16000 -ac 1 -c:a pcm_s16le "$NewWavFile"
}

Write-Host "Done" -ForegroundColor Magenta