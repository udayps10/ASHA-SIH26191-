@echo off
setlocal
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
if not exist "%SystemDrive%\tmp" mkdir "%SystemDrive%\tmp"
set "JAVA_OPTS=%JAVA_OPTS% -Djdk.net.unixdomain.tmpdir=%SystemDrive%\tmp -Djava.io.tmpdir=%SystemDrive%\tmp"
set "N8N_WEBHOOK_URL=https://n8n.udaycodes.site/webhook/aasha-whatsapp"
cd /d "%~dp0spring-boot-backend"
call gradlew.bat bootRun
pause
