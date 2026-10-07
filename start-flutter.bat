@echo off
setlocal
if not exist "%SystemDrive%\tmp" mkdir "%SystemDrive%\tmp"
set "JAVA_OPTS=%JAVA_OPTS% -Djdk.net.unixdomain.tmpdir=%SystemDrive%\tmp -Djava.io.tmpdir=%SystemDrive%\tmp"
cd /d "%~dp0flutter-app"
flutter run
