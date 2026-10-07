# Step 10B-2 local matching service

The Android emulator uses `http://10.0.2.2:8000`, configured centrally in
`ApiConfig`. Other targets can override it with
`--dart-define=MATCHING_API_BASE_URL=https://...`.

The debug Android manifest enables cleartext traffic only for local FastAPI
development. Production builds must use an HTTPS base URL and production
networking policy.

`HttpMatchApiService` calls `/api/v1/match` and `/api/v1/match/more`, applies a
12-second timeout, maps network/HTTP/malformed-response failures to
`MatchApiException`, and accepts both the camelCase contract and the current
FastAPI snake_case response fields.
