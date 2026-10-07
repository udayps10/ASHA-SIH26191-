$ErrorActionPreference = 'Stop'
# Keep Java socket paths short and free of Windows 8.3 aliases.
$socketDirectory = Join-Path $env:SystemDrive 'tmp'
New-Item -ItemType Directory -Force $socketDirectory | Out-Null
$previousJavaOptions = $env:JAVA_TOOL_OPTIONS
try {
    $env:JAVA_TOOL_OPTIONS = "$previousJavaOptions `"-Djdk.net.unixdomain.tmpdir=$socketDirectory`""
    Push-Location (Join-Path $PSScriptRoot 'flutter-app')
    try {
        & C:/flutter/bin/flutter.bat build apk --release --no-pub --dart-define=API_BASE_URL=https://aasha.udaycodes.site
        if ($LASTEXITCODE -ne 0) { throw 'APK build failed; existing download was not changed.' }
    } finally { Pop-Location }
    $apk = Join-Path $PSScriptRoot 'flutter-app/build/app/outputs/flutter-apk/app-release.apk'
    foreach ($relativeDirectory in @('spring-boot-backend/src/main/resources/static/downloads', 'spring-boot-backend/build/resources/main/static/downloads')) {
        $destination = Join-Path $PSScriptRoot $relativeDirectory
        New-Item -ItemType Directory -Force $destination | Out-Null
        $download = Join-Path $destination 'aasha.apk'
        $stagedDownload = Join-Path $destination 'aasha.apk.next'
        Copy-Item -LiteralPath $apk -Destination $stagedDownload -Force
        # Replace the file instead of truncating it while Windows has it mapped.
        if (Test-Path -LiteralPath $download) {
            [System.IO.File]::Replace($stagedDownload, $download, [System.Management.Automation.Language.NullString]::Value)
        } else {
            Move-Item -LiteralPath $stagedDownload -Destination $download
        }
    }
} finally { $env:JAVA_TOOL_OPTIONS = $previousJavaOptions }
