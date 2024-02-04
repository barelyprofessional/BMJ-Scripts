[CmdletBinding()]
param (
    [string]$WavSource = "Z:\BossmanJack\Kick\WAVs",
    [string]$TranscriptFolder = "Z:\BossmanJack\Kick\Transcripts",
    [string]$WhisperExe = "C:\temp\whisper\main.exe",
    [string]$ModelPath = "C:\temp\whisper\models\ggml-large-v3-q5_0.bin",
    #[string]$ModelPath = "C:\temp\whisper\models\ggml-base.en-q5_1.bin",
    [string]$TempDir = "C:\temp\"
)

if (-not (Test-Path $WavSource))
{
    Write-Error "WavSource '$WavSource' does not exist. Exiting"
    Exit 1
}

if (-not (Test-Path $TranscriptFolder))
{
    Write-Error "TranscriptFolder '$TranscriptFolder' does not exist. Exiting"
    Exit 1
}

# The cast to object[] is to ensure it's always an array, even if only a single
# item is returned. This is to circumvent magical behaviors PowerShell exhibits
# PowerShell is really touchy about the -Include parameter and it doesn't work
# as expected without -Recurse, even if it's useless in this case.
# When you use "ls *.wav" it's because -Path can accept wildcards, but I prefer
# not to do this way as I want to explicitly say "In this path, give me .wavs"
[object[]]$Files = Get-ChildItem -Path $WavSource -File -Include "*.wav" -Recurse
$Count = $Files.Count
Write-Host "Got $Count files to process" -ForegroundColor Cyan
$i = 0

foreach ($File in $Files)
{
    $i++
    #Write-Progress -Activity "Creating transcription" -Status "$i of $Count ($($File.BaseName))" -PercentComplete ($i / $Count * 100)
    # -of on Whisper expects no extension
    $TranscriptionFile = (Join-Path $TranscriptFolder $File.BaseName)
    Write-Host "Transcribing $($File.FullName) to $TranscriptionFile.csv ($i of $Count)" -ForegroundColor Cyan
    # I usually use Test-Path, but PowerShell cmdlets tend to exhibit weird
    # behavior when dealing with unusual UTF-8 characters. .NET static methods
    # tend to be more reliable
    if ([System.IO.File]::Exists("$TranscriptionFile.csv"))
    {
        Write-Host "$TranscriptionFile.csv already exists. Skipping." -ForegroundColor Green
        continue
    }
    # whispercpp can't handle the weird UTF-8 characters Bossman sometimes uses
    # in stream titles, so a workaround here is to copy the wav file to a temp
    # location, process that with transcription going to a temp location, then
    # move the transcription to its final destination using .NET methods
    $TempWav = Join-Path $TempDir "temp.wav"
    $TempTs = Join-Path $TempDir "temp"
    if (Test-Path $TempWav) { Remove-Item $TempWav }
    if (Test-Path "$TempTs.csv") { Remove-Item "$TempTs.csv" }
    
    [System.IO.File]::Copy($File.FullName, $TempWav)

    # Normally I use the call operator, but I thought Start-Process would help
    # with Whisper choking on weird characters. It didn't work, but I haven't
    # bothered moving back to &
    # The custom -et parameter is my desperate attempt to get Whispercpp to not
    # repeat when encountering music. It's not 100% and setting it too high did
    # not work well either, just tweak it higher or lower if a transcript
    # appears to be repeating for no good reason. I'm not a math wizard so it's
    # just a guess on my part when setting these values.
    Start-Process -FilePath $WhisperExe -ArgumentList ('-m', "`"$ModelPath`"", `
    '-ocsv', '-pp', '-f', "`"$TempWav`"", '-of', "`"$TempTs`"", '-t 8', '-et 3.0') -Wait -NoNewWindow
    # For the same reasons as above, Copy-Item hates the weird characters too
    [System.IO.File]::Copy("$TempTs.csv", "$TranscriptionFile.csv")
}

Write-Host "Done" -ForegroundColor Magenta