# DisasterConnect Step 10A matching contract

The Flutter app will call a protected backend rather than query matching data
or `critical_records` directly. The conceptual endpoints are:

- `POST /api/v1/match`: validates a `MatchRequest` and returns up to three
  ranked results.
- `POST /api/v1/match/more`: accepts the original `requestId` and
  `nextPageToken`, continuing the same ranked result set.

The future backend pipeline is validation, photo processing, candidate
retrieval from an approved server-side data source, multi-signal comparison,
ranking, pagination, and response sanitization. Signals may include facial,
age, name, location, clothing, and other supplied details; no weights or
confidence calculation are defined in Step 10A.

Normal results may expose a person photo URL, status, and contact details.
Critical results expose only safe identifying/contact fields and never expose
person photos, clothing photos, raw critical documents, or internal image URLs.
The backend must use trusted server-side credentials. No privileged credentials
belong in Flutter.
