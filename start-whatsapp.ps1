$ErrorActionPreference = 'Stop'
$env:N8N_USER_FOLDER = Join-Path $PSScriptRoot '.local/whatsapp-data'
$env:N8N_LISTEN_ADDRESS = '127.0.0.1'
$env:N8N_HOST = 'localhost'
$env:N8N_PORT = '5678'
$env:N8N_DIAGNOSTICS_ENABLED = 'false'
# Local workflow nodes need the four non-secret WhatsApp configuration values.
$env:N8N_BLOCK_ENV_ACCESS_IN_NODE = 'false'
& (Join-Path $PSScriptRoot '.local/whatsapp/node_modules/.bin/n8n.cmd') start
