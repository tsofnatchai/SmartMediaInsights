# Ensure we're in the correct directory
Set-Location $PSScriptRoot

# 1. Create analyze_image.zip from handler.py only
$analyzeZipPath = "..\infra\modules\lambda\analyze_image.zip"
if (Test-Path $analyzeZipPath) { Remove-Item $analyzeZipPath }
Compress-Archive -Path .\analyze_image\handler.py -DestinationPath $analyzeZipPath

# 2. Prepare process_stream package with pymysql
$packageDir = ".\process_stream\package"
if (Test-Path $packageDir) { Remove-Item $packageDir -Recurse -Force }
New-Item -ItemType Directory -Path $packageDir | Out-Null

# Install pymysql
pip install pymysql -t $packageDir

# Copy handler.py
Copy-Item .\process_stream\handler.py -Destination $packageDir

# Create process_stream.zip
$processZipPath = "..\infra\modules\lambda\process_stream.zip"
if (Test-Path $processZipPath) { Remove-Item $processZipPath }
Compress-Archive -Path "$packageDir\*" -DestinationPath $processZipPath

Write-Host "Lambda zip packages created successfully."
