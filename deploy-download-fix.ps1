$ErrorActionPreference = 'Stop'
$jar = Join-Path $PSScriptRoot 'spring-boot-backend/build/libs/aasha-web-1.0.0.jar'
if (!(Test-Path -LiteralPath $jar)) { throw 'The rebuilt application package is missing.' }

Write-Host 'Uploading the updated website and Android app. Enter your Ubuntu SSH password when asked.'
& scp $jar 'uday@udayps10:~/aasha-deploy/app.jar.next'
if ($LASTEXITCODE -ne 0) { throw 'Upload failed. The running application was not changed.' }

Write-Host 'Backing up the current package and restarting Aasha. Enter your SSH and sudo passwords when asked.'
# Copy into the existing file so the Docker file bind mount retains its inode.
& ssh -t uday@udayps10 'set -e; cd ~/aasha-deploy; cp app.jar app.jar.before-download-fix; sudo docker stop aasha-web; cp app.jar.next app.jar; sudo docker start aasha-web; for attempt in $(seq 1 60); do if curl -fsS http://localhost:8083/health; then exit 0; fi; sleep 5; done; sudo docker logs --tail 60 aasha-web; exit 1'
if ($LASTEXITCODE -ne 0) { throw 'Deployment or health check failed. The previous package is saved as ~/aasha-deploy/app.jar.before-download-fix.' }
Write-Host 'Aasha is healthy. Open https://aasha.udaycodes.site/app.html to download the app or scan the QR code.'
