# WhatsApp notification setup

The saved-search confirmation is not proof of WhatsApp delivery.

1. Run `start-whatsapp.ps1` in PowerShell. Open http://localhost:5678 and finish the local owner setup.
2. Import `n8n-workflow-aasha.json`.
3. In Meta, obtain the WhatsApp Phone Number ID and a valid messaging access token. In n8n create a Header Auth credential named `WhatsApp API Token`: header name `Authorization`, value `Bearer YOUR_TOKEN`. Select that credential on the Send WhatsApp Message node. Never commit the token.
4. Create and obtain approval for the `aasha_match_alert` template in Meta, with three positional body parameters: person name, camp name, and officer contact. Example: `A possible match for your saved Aasha search was found: {{1}}. Camp: {{2}}. Contact: {{3}}. Please contact the camp to verify.` Match the template language code to the environment setting.
5. Set WHATSAPP_PHONE_NUMBER_ID, WHATSAPP_API_VERSION (a supported version shown in Meta), WHATSAPP_TEMPLATE_NAME, and WHATSAPP_TEMPLATE_LANGUAGE before starting n8n. The launcher deliberately does not invent these account values.
6. Publish/activate the imported workflow. The backend uses http://localhost:5678/webhook/aasha-whatsapp by default.
7. With permission, test using a recipient allowed by your Meta test-number setup. Meta accepting a request is not proof of delivery; check its message status and the recipient phone.

The workflow reads the webhook body, validates an international phone number, sends a template, and returns Meta's response. Failures remain visible in n8n executions and return to the backend rather than calling nonexistent status endpoints. Existing saved searches are checked when a new record is created; this does not backfill previous records or retry failed messages automatically.
