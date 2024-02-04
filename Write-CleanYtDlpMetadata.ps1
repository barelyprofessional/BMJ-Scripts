[CmdletBinding()]
param (
    [string]$JsonPath = "Z:\BossmanJack\Kick\PendingUpload"
)

# -ErrorAction because if a JSON file isn't read or parsed correctly, there's a
# chance you'll mess up other manifests in the folder as $Json is reused
$ErrorActionPreference = "Stop"

# -Recurse is unnecessary as there's only one level but it's to ensure -Include
# works properly as PowerShell is actually more retarded than me (shocking)
Get-ChildItem -Path $JsonPath -File -Include "*.json" -Recurse | Foreach-Object {
    Write-Host "Processing $($_.FullName)" -ForegroundColor Cyan
    # -LiteralPath as otherwise it'll try to parse wildcards etc. in the path
    # -Raw as otherwise GCI behaves weirdly if there's a BOM in the file
    $Json = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction Stop
    # The depth should be increased if you haven't cleaned JSON files before
    # I chose not to do this as I want the schema to be consistent
    $Data = ConvertFrom-Json $Json
    # manifest_url can reveal your IP in its metadata, though usually it has
    # expired by the time it's uploaded somewhere. Still better safe than sorry
    # url appears to shadow manifest_url
    # Should be self-evident why you would want to strip cookies if present
    $Data.formats | Foreach-Object { $_.url = $null; $_.manifest_url = $null; if ($_.cookies){ $_.cookies = $null } }
    $Data.url = $null; $Data.manifest_url = $null; if ($Data.cookies) { $Data.cookies = $null }
    # This will emit an indented JSON which is actually very nice compared to
    # yt-dlp's condensed unreadable mess
    $NewJson = $Data | ConvertTo-Json
    # This method avoids writing a BOM to the file, which would look weird when
    # viewed in some browsers, and causes issues with parsing the JSON in some
    # languages, like Python. It's also more reliable with oddball file names
    [System.IO.File]::WriteAllText($_.FullName, $NewJson)
}