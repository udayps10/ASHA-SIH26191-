param([switch]$RunTests)
$ErrorActionPreference = 'Stop'
$previousJavaHome = $env:JAVA_HOME
$previousJavaOptions = $env:JAVA_OPTS
$previousJavaToolOptions = $env:JAVA_TOOL_OPTIONS
$previousGradleHome = $env:GRADLE_USER_HOME
try {
    $socketDirectory = Join-Path $env:SystemDrive 'tmp'
    New-Item -ItemType Directory -Force $socketDirectory | Out-Null
    $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
    $env:JAVA_OPTS = "$previousJavaOptions -Djdk.net.unixdomain.tmpdir=$socketDirectory -Djava.io.tmpdir=$socketDirectory"
    $env:JAVA_TOOL_OPTIONS = "$previousJavaToolOptions -Djdk.net.unixdomain.tmpdir=$socketDirectory -Djava.io.tmpdir=$socketDirectory"
    if (!$env:GRADLE_USER_HOME) { $env:GRADLE_USER_HOME = Join-Path $env:USERPROFILE '.gradle' }
    Push-Location (Join-Path $PSScriptRoot 'spring-boot-backend')
    try {
        if ($RunTests) { & .\gradlew.bat test bootJar }
        else { & .\gradlew.bat bootJar }
        if ($LASTEXITCODE -ne 0) { throw 'Backend build or tests failed.' }
    } finally { Pop-Location }
} finally {
    $env:JAVA_HOME = $previousJavaHome
    $env:JAVA_OPTS = $previousJavaOptions
    $env:JAVA_TOOL_OPTIONS = $previousJavaToolOptions
    $env:GRADLE_USER_HOME = $previousGradleHome
}
