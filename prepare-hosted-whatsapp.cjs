const fs = require('node:fs');
const workflow = JSON.parse(fs.readFileSync('n8n-workflow-aasha.json', 'utf8'));
delete workflow.id;
workflow.name = 'Aasha WhatsApp - corrected hosted workflow';
const build = workflow.nodes.find(n => n.id === 'build-message');
build.parameters.jsCode = build.parameters.jsCode
  .replace('const template = $env.WHATSAPP_TEMPLATE_NAME;', "const template = 'aasha_match_alert'; // Must match an approved Meta template")
  .replace('const language = $env.WHATSAPP_TEMPLATE_LANGUAGE;', "const language = 'en'; // Must match that template's language")
  .replace("if (!$env.WHATSAPP_PHONE_NUMBER_ID || !$env.WHATSAPP_API_VERSION) throw new Error('Configure Meta phone number ID and API version');", '');
const send = workflow.nodes.find(n => n.id === 'send-whatsapp');
// Phone number ID and API version copied from the user's node screenshot; token deliberately excluded.
send.parameters.url = 'https://graph.facebook.com/v25.0/1354713037727629/messages';
delete send.credentials;
fs.writeFileSync('aasha-whatsapp-hosted-import.json', JSON.stringify(workflow, null, 2) + '\n');
const execute = new Function('$input', build.parameters.jsCode);
const assert = require('node:assert/strict');
const payload = execute({first: () => ({json: {body: {userPhone: '+91 99999 99999', name: 'Test person', campName: 'Test camp', officerContact: 'Test contact'}}})})[0].json.payload;
assert.equal(payload.to, '919999999999');
assert.equal(payload.type, 'template');
assert.equal(payload.template.components[0].parameters.length, 3);
assert(!JSON.stringify(workflow).includes('localhost'));
assert(!JSON.stringify(workflow).includes('$env'));
assert(!JSON.stringify(workflow).includes('Bearer'));
console.log('Hosted workflow prepared and checked. No credentials included; no messages sent.');
