# AASHA - COMPLETE FEATURE LIST FOR UI/UX PLANNING

**App Name:** Aasha (meaning "Hope")
**Tagline:** "Reuniting families when they need each other most."
**Purpose:** Disaster response platform for finding missing persons using AI-powered matching

---

## TWO APPS

1. **Flutter Mobile App** - Two roles: Normal User (search for missing people) + Official (enter/manage records at relief camps)
2. **Spring Boot Web App** - Public-facing website for searching (no login required) + REST API backend

---

## 1. AUTHENTICATION & USER MANAGEMENT (12 features)

| # | Feature | Description |
|---|---------|-------------|
| 1.1 | Splash Screen & Auto-Route | App startup, reads auth state, auto-redirects based on user status |
| 1.2 | Welcome Screen | Landing page with "Login as Normal User" and "Login as Official" buttons |
| 1.3 | Normal User Login | Email + password form, links to Forgot Password and Register |
| 1.4 | Official Login | Email + password form, notice that official accounts are pre-authorized |
| 1.5 | Registration | Full Name + Email + Password + Confirm Password form with validation |
| 1.6 | Email Verification | Shown to new users, "I've Verified" button, "Resend Email" button |
| 1.7 | Official Pending Approval | Shown to officials awaiting approval, "Refresh Status" button |
| 1.8 | Profile Error Screen | Shown when profile not found, "Try Again" and "Logout" buttons |
| 1.9 | Forgot Password | Email input, sends reset link, shows success confirmation |
| 1.10 | Profile Screen | Shows avatar, name, email, role chip (USER/OFFICIAL), Logout button |
| 1.11 | Role-Based Auth Routing | Auto-redirects based on auth status (unauthenticated, unverified, verified user, approved official, pending official) |
| 1.12 | Auth State Listener | Real-time auth state stream, loads profile on login, clears on logout |

---

## 2. NORMAL USER FEATURES (4 features)

| # | Feature | Description |
|---|---------|-------------|
| 2.1 | User Home Screen | Welcome dashboard with "Find Your Loved One" header, "Start Search" button, 3-step "How it works" explanation |
| 2.2 | Search Form | Find missing person: Name (required), Age (required), Location (optional), Details (optional), Photo upload (optional via camera/gallery) |
| 2.3 | Normal Match Results | AI-powered results with: photo, name, age, match confidence %, match label (Strong/Possible/Weak), AI explanation, camp, status, "Call Official" button, pagination with "View More Matches" |
| 2.4 | Critical Match Results | Same as normal but **NO photos shown** (privacy), shows clothing description, red-themed, "Contact Official" button |

---

## 3. OFFICIAL (ADMIN) FEATURES (13 features)

| # | Feature | Description |
|---|---------|-------------|
| 3.1 | Official Dashboard | Status header (online/offline/sync), record count, 8-card Quick Actions grid |
| 3.2 | Add Normal Person | Form: Photo, Name, Age, Camp (dropdown), Date/Time Found, Details. Saves locally, queues for sync |
| 3.3 | Add Critical Record | Form: Person Photo + Clothing Photo, Name, Age, Last Clothing, Camp, GPS Location, Found Location, Details. Privacy warning shown |
| 3.4 | Manage Camps | List all camps with name, location, officer, active/inactive badge. FAB to add new |
| 3.5 | Add/Edit Camp | Form: Name, Location, Address, GPS coordinates, Contact, Officer, Active toggle. GPS fetch with confirmation UI |
| 3.6 | Camp Details | Read-only detail: status, name, location, address, officer, contact, coordinates. Edit button |
| 3.7 | Normal Records List | Filterable list: search by name, age, status chips (All/FOUND/AT_CAMP/IDENTIFIED/UNITED), camp dropdown |
| 3.8 | Normal Record Details | Full detail with photo, status badge, personal info, rescue details, officer info. Status update with ChoiceChips + confirmation dialog |
| 3.9 | Critical Records List | Red-themed filterable list: search, status chips (All/CRITICAL/IDENTIFIED/CONFIRMED_DECEASED/RELEASED_TO_FAMILY), camp dropdown |
| 3.10 | Critical Record Details | "CONFIDENTIAL RECORD" banner, photos (official only), status, clothing, location, GPS, officer info. Status update with special warning for CONFIRMED_DECEASED |
| 3.11 | Search Records (Unified) | Search across both normal AND critical records. Bottom sheet modal with full details and "Update Status" button |
| 3.12 | Recent Records | Chronological list of latest records from both types, sorted by creation date |
| 3.13 | Pending Sync | Sync queue status: online/offline, pending/syncing/failed counts, last sync time, "Sync Now" button, "Retry failed" link |

---

## 4. MATCHING & AI SEARCH (7 features)

| # | Feature | Description |
|---|---------|-------------|
| 4.1 | MatchRequest | Input model: name, age, photo reference, location, details. Has validation |
| 4.2 | NormalMatchResult | Result: photo, name, age, camp, officer, confidence score, label (Strong/Possible/Weak), explanation, status |
| 4.3 | CriticalMatchResult | Same but NO photos (privacy), adds lastKnownClothing |
| 4.4 | Match API Service | HTTP client calling backend AI matching endpoint |
| 4.5 | Match Repository | Wraps API, provides findMatches() and getMoreMatches() for pagination |
| 4.6 | Image Upload for Matching | Uploads user photos for AI analysis, returns storage reference |
| 4.7 | Pagination | "View More Matches" with nextPageToken for loading additional results |

---

## 5. DATA MODELS

### Camp
- id, name, locationName, address, latitude, longitude, contactNumber, officerName, officerUid, active, locationAccuracy, createdAt

### NormalRecord
- id, name, age, photoUrl, campId, campName, officerUid, officerName, officerContact
- Status: FOUND | AT_CAMP | IDENTIFIED | UNITED_WITH_FAMILY
- additionalDetails, foundAt, createdAt, updatedAt

### CriticalRecord
- id, name, age, photoUrl, clothingPhotoUrl, lastKnownClothing
- campId, campName, officerUid, officerName, officerContact
- foundLocation, foundLatitude, foundLongitude, locationAccuracy
- Status: CRITICAL | IDENTIFIED | CONFIRMED_DECEASED | RELEASED_TO_FAMILY
- additionalDetails, foundAt, createdAt

### AppUser
- uid, name, email, role (user/official), approved, organization

---

## 6. SYNC & OFFLINE (6 features)

| # | Feature | Description |
|---|---------|-------------|
| 6.1 | SyncService Singleton | Global state: online status, sync phase, errors, timestamps |
| 6.2 | Session Management | Starts sync session on official login, stops on logout |
| 6.3 | Offline-First Records | Records saved to local DB first, synced when online. Snackbar: "Saved locally. Will sync when connection returns." |
| 6.4 | Sync Queue | Pending/syncing/failed items with manual "Sync Now" and "Retry failed" |
| 6.5 | Online/Offline Indicator | Dashboard shows wifi icon with state, snackbars on sync events |
| 6.6 | Bulk Sync API | POST /api/sync/{collection} accepts lists of entities for batch upsert |

---

## 7. WEB APP (6 pages)

| # | Page | URL | Description |
|---|------|-----|-------------|
| 7.1 | Home | `/` | Hero "Find a Loved One", live stats (4 cards), "How It Works" 3 steps, CTA, active camps list |
| 7.2 | Search | `/search` | Form: Name, Age, Location, Details, Photo. Results with photo, name, age, camp, status, "Call Official". "Check Critical Records?" box at bottom |
| 7.3 | Critical | `/critical` | Privacy notice. No photos shown. Shows name, age, clothing, camp, "Contact Official". "Search Again" link |
| 7.4 | Camps | `/camps` | Searchable camp directory. Each card: name, location, officer, contact, active/inactive badge |
| 7.5 | About | `/about` | Mission, AI explanation (4 steps), Privacy & Safety, CTA with 2 search buttons, live stats |
| 7.6 | Health | `/health` | JSON health check endpoint |

---

## 8. REST API ENDPOINTS (25 total)

### Auth (4)
- POST /api/auth/register
- POST /api/auth/login
- GET /api/auth/profile

### Camps (5)
- GET /api/camps/list
- GET /api/camps/list/active
- POST /api/camps
- PUT /api/camps/{id}
- DELETE /api/camps/{id}

### Normal Records (6)
- GET /api/normal-records/list
- GET /api/normal-records/{id}
- POST /api/normal-records
- PUT /api/normal-records/{id}
- PATCH /api/normal-records/{id}/status
- DELETE /api/normal-records/{id}

### Critical Records (6)
- GET /api/critical-records/list
- GET /api/critical-records/{id}
- POST /api/critical-records
- PUT /api/critical-records/{id}
- PATCH /api/critical-records/{id}/status
- DELETE /api/critical-records/{id}

### Bulk Sync (3)
- POST /api/sync/camps
- POST /api/sync/normal-records
- POST /api/sync/critical-records

### Misc (1)
- GET /api/health

---

## TOTAL: 52 features across 8 categories

### Key Design Principles
1. **Privacy First** - Critical/deceased photos NEVER shown to public users
2. **Offline-First** - Officials can create records offline, syncs when connected
3. **AI-Powered Matching** - Users search once, get ranked results with confidence scores
4. **Role-Based Access** - Normal users search, officials manage records
5. **Two Platforms** - Mobile app for officials + web for public search
6. **WhatsApp Integration** - Share search results and camp info via WhatsApp
