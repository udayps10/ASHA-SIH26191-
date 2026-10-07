const assert = require('node:assert/strict');
const workflow = require('./n8n-workflow-aasha.json');
const build = workflow.nodes.find(n => n.id === 'build-message');
const execute = new Function('$input', '$env', build.parameters.jsCode);
const env = {WHATSAPP_TEMPLATE_NAME: 'aasha_match_alert', WHATSAPP_TEMPLATE_LANGUAGE: 'en', WHATSAPP_PHONE_NUMBER_ID: 'test-id', WHATSAPP_API_VERSION: 'test-version'};
const input = body => ({first: () => ({json: {body}})});
const record = {userPhone: '+91 99999 99999', name: 'Example Person', campName: 'Example Camp', officerContact: 'Example contact'};
const result = execute(input(record), env)[0].json.payload;
assert.equal(result.to, '919999999999');
assert.equal(result.type, 'template');
assert.equal(result.template.components[0].parameters[0].text, record.name);
assert.throws(() => execute(input({...record, userPhone: 'invalid'}), env), /country code/);
assert.throws(() => execute(input(record), {}), /approved WhatsApp template/);
assert.throws(() => execute(input(undefined), env), /Missing webhook body/);
assert.equal(workflow.nodes.find(n => n.id === 'webhook-trigger').parameters.responseMode, 'lastNode');
for (const connections of Object.values(workflow.connections)) {
  for (const branch of connections.main) for (const edge of branch) assert(workflow.nodes.some(n => n.name === edge.node));
}
console.log('WhatsApp workflow checks passed: payload, phone validation, missing configuration, webhook response, connections. No messages sent.');
