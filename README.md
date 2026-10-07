# Aasha — Disaster Reunification Network

> **आशा** (Aasha) means "Hope" in Hindi — an AI-powered platform reuniting families separated by natural disasters across India.

## 🎯 Problem Statement

> *"Student Innovation — Disaster management includes ideas related to risk mitigation, planning and management before, after or during a disaster."*
> — Smart India Hackathon 2026, Problem Statement ID: 26206

When natural disasters strike India — floods, earthquakes, cyclones, landslides — families get separated. Children lose parents. Elderly lose their children. The current system relies on paper records, phone calls, and word of mouth. By the time someone finds their loved one, days have passed.

**Aasha changes that.** Our AI-powered platform matches missing persons reports with relief camp records across India, cutting reunion time from days to hours.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AASHA SYSTEM ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Flutter     │    │  Spring Boot │    │  Python AI   │  │
│  │   Mobile App  │◄──►│   Backend    │◄──►│   Service    │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ SQLite/Drift │    │   MySQL 8    │    │ Face + CLIP  │  │
│  │ (Offline)    │    │   (Server)   │    │ Matching     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                              │
│         │                   │                   │           │
│         ▼                   ▼                   ▼           │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ SyncQueue    │    │   MinIO      │    │  Similarity  │  │
│  │ (Reliability) │    │  (Photos)    │    │  Ranking     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📱 Flutter App (`flutter-app/`)

### Features

| Feature | Description |
|---------|-------------|
| **Search Missing Persons** | High-recall search by name, age, or location |
| **Multi-Modal AI Ranking** | Combines text, metadata, and visual similarity |
| **Emergency Center** | Live alerts, safety status, and nearby camps |
| **SOS System** | Immediate emergency signal with GPS tracking |
| **Critical Records** | Sensitive records for deceased/injured (Private) |
| **Offline-First** | Local SQLite storage with background sync |

### Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart |
| State Management | Provider |
| Local Database | Drift (SQLite) |
| Sync Engine | SyncQueue + connectivity_plus |

---

## ☕ Spring Boot Backend (`spring-boot-backend/`)

### Features

| Feature | Description |
|---------|-------------|
| **REST API** | Secure endpoints for mobile and web |
| **Candidate Retrieval** | High-recall MySQL queries for AI pool |
| **MinIO Integration** | On-premise secure object storage |
| **JWT Security** | Role-based authorization (Official/User) |
| **Emergency Alerts** | Management of live disaster warnings |
| **SOS Handling** | Dashboard for official responders |

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Secure JWT authentication |
| POST | `/api/v1/match` | Multi-modal AI search matching |
| GET | `/api/alerts/active` | Public emergency alerts |
| POST | `/api/sos` | Submit emergency SOS signal |
| POST | `/api/normal-records` | Create missing person record |

---

## 🤖 AI Service (`ai-service/`)

### Features

| Feature | Description |
|---------|-------------|
| **Text Similarity** | Semantic name and detail matching |
| **Visual Similarity** | Face matching and CLIP visual anchors |
| **Renormalized Scoring** | Handles missing data without penalty |
| **Session Bounding** | Memory-safe ranking for many requests |

### Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | FastAPI |
| NLP | Sentence-Transformers |
| Vision | DeepFace, CLIP |
| Image Storage | MinIO/Local abstraction |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.x
- **Java JDK** ≥ 17
- **Python** ≥ 3.11
- **MySQL** ≥ 8.0
- **MinIO** (optional, fallback to local)

### 1. Setup Backend

```bash
cd spring-boot-backend
# Update src/main/resources/application.properties with DB/MinIO info
./gradlew bootRun
```

### 2. Setup AI Service

```bash
cd ai-service
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python -m uvicorn app.main:app --port 8000
```

### 3. Setup Flutter

```bash
cd flutter-app
flutter pub get
# Ensure API_BASE_URL points to your backend
flutter run --dart-define=API_BASE_URL=http://your-ip:8080
```

---

## 🔐 Security & Privacy

- **No Public Photos**: Critical records are never displayed to normal users.
- **On-Premise Storage**: Photos stay in MinIO, not public clouds.
- **JWT Protection**: All sensitive endpoints require signed tokens.
- **Domain Separation**: AI matching is separate from SOS/Emergency systems.

---

## 🙏 Acknowledgments

- **Smart India Hackathon 2026** — Problem Statement 26206
- **NDMA** — National Disaster Management Authority
- **DeepFace & OpenAI CLIP** — For visual similarity models

---

## 🇮🇳 Made with ❤️ for India
