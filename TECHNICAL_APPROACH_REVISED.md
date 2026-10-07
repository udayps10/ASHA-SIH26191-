# Aasha — Technical Approach and Prototype Evidence

## 1. Purpose
Aasha helps families search missing-person records and helps camp officers manage found-person records. Matches are suggestions for human verification, not confirmed identities.

**PASTE PROTOTYPE IMAGE 1 HERE:** Website landing page and Android home screen, side by side. Caption: “Public search and emergency assistance entry points.”

## 2. Architecture
Flutter Android app and Thymeleaf website → Spring Boot API → MySQL.
Spring Boot sends search candidates to the Python AI matching service. Photos use backend storage with a MinIO integration. The app also has a local SQLite cache and a sync queue; offline data is not automatically evidence of server receipt.

**PASTE PROTOTYPE IMAGE 2 HERE:** Architecture diagram showing these components and arrows. Label external integrations separately: NDMA alerts and n8n/Meta WhatsApp.

## 3. Matching logic
Each component produces a similarity between 0 and 1. The fixed weighted score is:

`raw score = 30 × face + 25 × name + 15 × age + 15 × details + 10 × location + 5 × CLIP`

| Category | Weight | Model / logic |
|---|---:|---|
| Face | 30% | InsightFace / ArcFace cosine similarity, when faces can be compared |
| Name | 25% | Token overlap and MiniLM semantic similarity; current implementation selects the stronger similarity |
| Age | 15% | Linear decay: max(0, 1 − absolute age difference / 10); exact = 1, ±5 years = 0.5, ±10 years = 0 |
| Details | 15% | MiniLM cosine similarity for clothing, tattoos and descriptions |
| Location | 10% | MiniLM similarity between last-seen location and found/camp location; not geographic distance |
| CLIP visual | 5% | CLIP image embedding similarity |
| **Total** | **100%** | **Fixed weights; no redistribution for missing evidence** |

Missing or failed comparisons contribute zero. Thus a perfect name-and-age-only comparison scores 40%, not 100%. Scores are capped at 99% for this prototype; this cap is a presentation/product rule, not statistical calibration. A score is weighted evidence similarity, not identification accuracy or probability.

The website must consume all AI result pages so every returned candidate gets its calculated score. If the entire scoring service fails, it must ask for a retry rather than invent a percentage. Visual processing remains limited to the configured shortlist; candidates outside it have no visual contribution.

**PASTE PROTOTYPE IMAGE 3 HERE:** Search form containing name, age, location, details and optional photo. Use fictional demonstration data.

**PASTE PROTOTYPE IMAGE 4 HERE:** Search results after calculation, showing several different match percentages. Include more than three candidates to demonstrate pagination coverage. Caption: “Weighted match scores support officer/family verification.”

## 4. Records and photos
Officers select an active camp and create a normal or critical record. Photo upload is a separate step after record creation. The updated Android form retains the record ID when retrying a failed photo upload. Login failures and server errors should be shown explicitly, not as an empty list.

**PASTE PROTOTYPE IMAGE 5 HERE:** Add-record form with a selected camp and photo preview.

**PASTE PROTOTYPE IMAGE 6 HERE:** Saved normal record with its photo, camp and officer contact. Hide real personal information.

## 5. Emergency map and SOS
Alerts with coordinates appear as map markers. Affected-area circles require a supplied radius; a marker alone does not define a hazard boundary. The current prototype uses concentric 30% and 70% radius bands. These are simplified visual rules, not scientifically verified evacuation boundaries. Missing GPS must not hide the map.

SOS requests contain coordinates, GPS accuracy and a timestamp. Server receipt, officer acknowledgement and resolution are different states. Offline requests stay pending; they must not be described as delivered.

**PASTE PROTOTYPE IMAGE 7 HERE:** Map with alert markers and the “affected boundaries unavailable” explanation. Only show colored circles for a clearly labelled demo radius or an actual supplied radius.

**PASTE PROTOTYPE IMAGE 8 HERE:** SOS confirmation and officer SOS list, side by side, from a controlled demo. Do not claim emergency dispatch integration based only on backend receipt.

## 6. WhatsApp integration
Saved searches can trigger the configured hosted n8n workflow on a new matching record. Meta credentials, an approved template, an active workflow and a permitted recipient are required. This project's end-to-end WhatsApp delivery has not yet been verified.

**PASTE PROTOTYPE IMAGE 9 HERE:** n8n workflow. Add a delivered WhatsApp screenshot only after an actual authorized test succeeds. Never include access tokens.

## 7. Demonstration and verification checklist
Demonstrate a search with more than three results; confirm each has its own score. Demonstrate a name-and-age-only search scoring at most 40%. Demonstrate missing photos without fabricated face similarity. Demonstrate a record upload and opening its photo. Demonstrate map markers without radius data and distinguish missing boundaries from safe areas.

Do not claim measured model accuracy without an evaluation dataset and documented metrics. Keep captions honest about live, simulated, incomplete and planned features.
