# Function to check the rate limit on GitHub API
function Test-GitHubAPILimit {
  $rateInfo = Invoke-RestMethod -Uri "https://api.github.com/rate_limit" -Method Get | Select-Object -ExpandProperty rate
  $requests = $rateInfo.remaining
  $limit = $rateInfo.limit
  $resetReadable = ([datetime]'1/1/1970').AddSeconds($rateInfo.reset)
  if ($rateInfo.remaining -eq 0) {
    Write-Host "Rate limit reached. You need to wait until $resetReadable before you can make more requests."
    Return $false
  } else {
    Write-Host "$requests requests remaining out of $limit. Reset time is $resetReadable"
    Return $true
  }
}

# Function to test for path and creation folder if it doesn't exist
function New-FolderSafely($path) {
  if (!(Test-Path $path)) {
      New-Item -ItemType Directory -Force -Path $path
  }
}

# Function to get latest msix from github api repo url
function Get-LatestMsix($uri) {
  $get = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction stop
  $data = ($get | where-object {(-Not $_.Prerelease) -or (-Not $_.Preinstall)} | Select-Object -first 1).Assets | Where-Object name -Match 'msixbundle'
  Return $data.browser_download_url
}

# Test for GitHub API rate limit and continue if possible
if (Test-GitHubAPILimit) {
  # Check for and create temp folder if needed
  New-FolderSafely('C:\Temp')

  # Set location to temp folder
  Set-Location 'C:\Temp'

  # Get latest msix from github api repo url and download files for winget
  $wingetUrl = Get-LatestMsix("https://api.github.com/repos/microsoft/winget-cli/releases/latest")
  Invoke-WebRequest -Uri $wingetUrl -OutFile 'winget.msixbundle'

  # Get dependencies for winget
  Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx' 
  

  # Install winget and terminal msix files
  Add-AppxPackage 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
  Add-AppxPackage 'winget.msixbundle'

  # Install tools using winget package manager
  winget install Microsoft.WindowsTerminal --accept-package-agreements --accept-source-agreements
  winget install RProject.R -v 4.0.4 --accept-package-agreements --accept-source-agreements
  winget install Anaconda.Anaconda3 --accept-package-agreements --accept-source-agreements --override "/InstallationType=AllUsers /AddToPath=1 /S /RegisterPython=1"
  winget install Microsoft.VisualStudioCode  --accept-package-agreements --accept-source-agreements --scope machine
  winget install Microsoft.PowerShell --accept-package-agreements --accept-source-agreements --scope machine
  winget install RStudio.RStudio.OpenSource --accept-package-agreements --accept-source-agreements --scope machine
  winget install ChristianSchenk.MiKTeX --accept-package-agreements --accept-source-agreements --scope machine
  winget install TeXstudio.TeXstudio --accept-package-agreements --accept-source-agreements --scope machine
  winget install TUG.TeXworks --accept-package-agreements --accept-source-agreements --scope machine
  winget install Git.Git --accept-package-agreements --accept-source-agreements --scope machine
}
