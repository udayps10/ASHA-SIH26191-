# Aasha-Web Frontend Documentation

## Pages Overview

| Page | URL | Purpose |
|------|-----|---------|
| Home | `/` | Landing page with stats, how-it-works, camp list |
| Search | `/search` | Search for missing persons (normal records) |
| Critical | `/critical` | Search critical/deceased records (no photos) |
| Camps | `/camps` | List active relief camps |
| About | `/about` | Mission, AI explanation, privacy info |

---

## Page: Home (`/`)

### Navigation Bar
| Item | Link | Active |
|------|------|--------|
| Aasha (brand) | `/` | - |
| Home | `/` | Yes |
| Search | `/search` | - |
| Critical Records | `/critical` | - |
| Camps | `/camps` | - |
| About | `/about` | - |
| Hamburger (mobile) | - | Toggles nav menu |

### Hero Section
- **H1:** "Aasha"
- **Subtitle:** "DisasterConnect AI - Reuniting families when they need each other most."
- **Button:** "Find a Loved One" → `/search`

### Stats Cards (dynamic)
| Card | Value Source |
|------|-------------|
| People Found | `stats.totalNormalRecords` |
| Active Camps | `stats.totalCamps` |
| At Camp | `stats.atCampCount` |
| Critical Records | `stats.totalCriticalRecords` |

### How It Works (3 steps)
| Step | Icon | Title | Description |
|------|------|-------|-------------|
| 1 | `1` | Enter Details | Provide the name, age, and any other details you know about the missing person. |
| 2 | `2` | AI Analysis | Our AI system compares your input with verified records from disaster-response officials. |
| 3 | `3` | Get Connected | If a match is found, contact the camp official directly to confirm and reunite. |

### CTA Card
- **Heading:** "Ready to search?"
- **Text:** "Enter as much information as possible for the best results."
- **Button:** "Start Searching" → `/search`

### Active Relief Camps Section (dynamic)
- Shows when camps list is not empty
- Each camp shows name + location
- **Button:** "View All Camps" → `/camps`

### Footer
- **Text:** "Powered by DisasterConnect AI"
- **Links:** About, Camps

---

## Page: Search (`/search`)

### Navigation Bar
| Item | Link | Active |
|------|------|--------|
| Aasha (brand) | `/` | - |
| Home | `/` | - |
| Search | `/search` | Yes |
| Camps | `/camps` | - |
| About | `/about` | - |

### Page Header
- **H1:** "Find a Missing Person"
- **Subtitle:** "Enter as much information as possible. Our AI will search verified records from disaster-response officials."

### Search Form (`POST /search`, `enctype="multipart/form-data"`)
| # | Label | Type | Name | Placeholder | Required | Validation |
|---|-------|------|------|-------------|----------|------------|
| 1 | Full Name * | `text` | `name` | "Enter person's name" | Yes | - |
| 2 | Age * | `number` | `age` | "Age" | Yes | `min="0" max="130"` |
| 3 | Last Known Location | `text` | `lastKnownLocation` | "City or area" | No | - |
| 4 | Additional Details | `textarea` | `additionalDetails` | "Clothing, tattoos, birthmarks, etc." | No | - |
| 5 | Photo (optional) | `file` | `photoFile` | - | No | `accept="image/*"` |

**Submit Button:** "Find Matches" → `POST /search`

### Results Section (appears after search)

#### Empty State
- **Icon:** 🔍
- **Text:** "No strong matches found in normal records."

#### Results List
- **Heading:** "{count} Possible Match(es) Found"
- Each result card shows:
  - **Photo placeholder:** 👤 (80x80)
  - **Name** (bold, 18px)
  - **Meta:** "Age: {age} · Camp: {campName}" (camp shown if available)
  - **Status badge:** `badge-at-camp` style
  - **Action button:** "Call Official" → `tel:{officerContact}` (shown if contact exists)

#### Check Critical Records Box (appears after results)
- **Background:** `#fff5f5` (light red)
- **Border:** `1px solid #fed7d7`
- **Heading:** "Check Critical Records?"
- **Text:** "Some people may be listed in critical records. Their photographs are never shown here."
- **Hidden form fields:** `name`, `age` (passed from search)
- **Button:** "Search Critical Records" → `POST /critical`

### Footer
- **Text:** "Powered by DisasterConnect AI"

---

## Page: Critical Records (`/critical`)

### Navigation Bar
| Item | Link | Active |
|------|------|--------|
| Aasha (brand) | `/` | - |
| Home | `/` | - |
| Search | `/search` | - |
| Camps | `/camps` | - |
| About | `/about` | - |

### Privacy Notice (warning alert)
- **Background:** `#fffff0` (light yellow)
- **Text:** "Privacy Notice: Photographs of deceased or critical persons are never shown publicly. Only identifying details are displayed."

### Results Section (appears after search)

#### Empty State
- **Text:** "No critical records matching these details were found."

#### Results List
- **Heading:** "{count} Critical Record(s) Found"
- Each result card shows:
  - **Photo placeholder:** ⚠️ (80x80, no actual photos - privacy)
  - **Name** (bold, 18px)
  - **Meta:** "Age: {age} · Found at: {campName}"
  - **Status badge:** `badge-unidentified` style
  - **Last Clothing:** (shown if available)
  - **Additional details:** (shown if available)
  - **Action button:** "Contact Official" → `tel:{officerContact}` (shown if contact exists)

### Need Immediate Help Box
- **Background:** `#fff5f5` (light red)
- **Border:** `1px solid #fed7d7`
- **Heading:** "Need Immediate Help?"
- **Text:** "If you recognize any of these details, please contact the listed official or camp immediately."
- **Button:** "Search Again" → `/search`

### Footer
- **Text:** "Powered by DisasterConnect AI"

---

## Page: Camps (`/camps`)

### Navigation Bar
| Item | Link | Active |
|------|------|--------|
| Aasha (brand) | `/` | - |
| Home | `/` | - |
| Search | `/search` | - |
| Camps | `/camps` | Yes |
| About | `/about` | - |

### Page Header
- **H1:** "Relief Camps"
- **Subtitle:** "Find active disaster relief camps and their contact information."

### Camp Search Form (`GET /camps`)
| # | Label | Type | Name | Placeholder | Required |
|---|-------|------|------|-------------|----------|
| 1 | (no label) | `text` | `q` | "Search camps by name or location..." | No |

**Submit Button:** "Search"

### Camp List (dynamic)

#### Empty State
- **Icon:** 🏘️
- **Text:** "No camps found."

#### Each Camp Card
- **Name** (bold, 18px)
- **Location:** 📍 {locationName} (shown if available)
- **Officer:** 👤 {officerName} (shown if available)
- **Contact:** 📞 {contactNumber} (shown if available)
- **Status badge:**
  - Active: "ACTIVE" (green)
  - Inactive: "INACTIVE" (grey)

### Footer
- **Text:** "Powered by DisasterConnect AI"

---

## Page: About (`/about`)

### Navigation Bar
| Item | Link | Active |
|------|------|--------|
| Aasha (brand) | `/` | - |
| Home | `/` | - |
| Search | `/search` | - |
| Critical Records | `/critical` | - |
| Camps | `/camps` | - |
| About | `/about` | Yes |

### Card: Our Mission
- **Heading:** "Our Mission"
- **Text:** "Aasha (meaning "hope") is a disaster response platform that uses AI-powered matching to reunite families separated during natural disasters. When every minute counts, our system connects people searching for loved ones with verified records maintained by disaster-response officials."

### Card: How the AI Matching Works
- **Heading:** "How the AI Matching Works"
- **Intro:** "When you search for a missing person, our system:"
- **Ordered list:**
  1. "Accepts your input - Name, age, photo (optional), location, and identifying details."
  2. "Compares with verified records - Officials at relief camps enter data about people they have found or are caring for."
  3. "AI scoring - Our matching engine calculates a similarity score based on all available information."
  4. "Returns ranked results - You see the most likely matches first, with explanations of why they matched."
- **Paragraph:** "The system also separates normal records (people who are safe at camps) from critical records (deceased or in critical condition), ensuring sensitive information is handled appropriately."

### Card: Privacy & Safety
- **Heading:** "Privacy & Safety"
- **Bullet list:**
  1. "Photos of critical/deceased persons are never displayed publicly. Only officials can view them."
  2. "Personal data is only used for matching and reunification purposes."
  3. "Official verification - All records in the system are entered by verified disaster-response officials."
  4. "No registration required - Anyone can search without creating an account."

### CTA Section (gradient background)
- **Background:** `linear-gradient(135deg, #667eea, #764ba2)`
- **Heading:** "Start Searching"
- **Text:** "Help us reunite families. Search now or share with someone who needs help."
- **Button 1:** "Search Normal Records" → `/search`
- **Button 2:** "Search Critical Records" → `/critical`

### Stats (dynamic)
| Card | Value Source |
|------|-------------|
| Total Records | `stats.totalNormalRecords` |
| Relief Camps | `stats.totalCamps` |

### Footer
- **Text:** "Powered by DisasterConnect AI"
- **Link:** Home → `/`

---

## Global: All Buttons Summary

| Button | Page | Action | Style |
|--------|------|--------|-------|
| Find a Loved One | Home | → `/search` | White pill on gradient |
| Start Searching | Home | → `/search` | `.btn-primary` |
| View All Camps | Home | → `/camps` | `.btn-outline .btn-sm` |
| Find Matches | Search | `POST /search` | `.btn-primary .btn-block` |
| Search Critical Records | Search | `POST /critical` | `.btn-danger .btn-sm` |
| Call Official | Search results | `tel:{number}` | `.btn-primary .btn-sm` |
| Contact Official | Critical results | `tel:{number}` | `.btn-danger .btn-sm` |
| Search Again | Critical | → `/search` | `.btn-outline .btn-sm` |
| Search | Camps | `GET /camps?q=...` | `.btn-primary` |
| Search Normal Records | About | → `/search` | White on gradient |
| Search Critical Records | About | → `/critical` | Semi-transparent on gradient |
| Hamburger (mobile) | All pages | Toggle nav | `.navbar-toggle` |

---

## Global: All Links Summary

| Link | Source Pages | Destination |
|------|-------------|-------------|
| Aasha (brand) | All | `/` |
| Home | All | `/` |
| Search | All | `/search` |
| Critical Records | Home, About | `/critical` |
| Camps | All | `/camps` |
| About | All | `/about` |
| tel:{contact} | Search, Critical | Phone call |
| About (footer) | Home | `/about` |
| Camps (footer) | Home | `/camps` |
| Home (footer) | About | `/` |

---

## CSS Design System

### Colors
| Variable | Value | Usage |
|----------|-------|-------|
| `--primary` | `#667eea` | Buttons, links, gradients |
| `--primary-dark` | `#5a67d8` | Hover states |
| `--secondary` | `#764ba2` | Gradient accent |
| `--danger` | `#e53e3e` | Critical records, urgent actions |
| `--success` | `#38a169` | Active status, positive |
| `--warning` | `#d69e2e` | Warning alerts |
| `--bg` | `#f7fafc` | Page background |
| `--card` | `#ffffff` | Card background |
| `--text` | `#1a202c` | Primary text |
| `--text-secondary` | `#718096` | Muted text |
| `--border` | `#e2e8f0` | Borders |

### Button Variants
| Class | Style |
|-------|-------|
| `.btn` | Base button (padding 12px 24px, rounded 8px) |
| `.btn-primary` | Gradient purple/indigo, white text |
| `.btn-danger` | Red background, white text |
| `.btn-outline` | Transparent with colored border |
| `.btn-block` | Full width |
| `.btn-sm` | Smaller padding (8px 16px) |

### Status Badges
| Class | Color | Usage |
|-------|-------|-------|
| `.badge-at-camp` | Green on light green bg | Normal record at camp |
| `.badge-released` | Blue on light blue bg | Released to family |
| `.badge-unidentified` | Red on light red bg | Critical/unidentified |
| `.badge-identified` | Green on light green bg | Identified critical |

### Responsive Breakpoint
- **768px:** Navbar collapses to hamburger, form rows stack vertically, result cards stack vertically, stats grid becomes 2-column
