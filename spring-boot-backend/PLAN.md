# Aasha-Web - User-Side Web App Plan (MySQL)

## Architecture Overview

```
User Browser → Spring Boot (port 8080) → MySQL Database
                         ↓
                   FastAPI Backend (port 8000) → MySQL Database
```

Both the Spring Boot web app and the FastAPI matching backend share the same MySQL database. The Flutter app would also sync to this MySQL database (future work).

## MySQL Schema

### `camps` table
```sql
CREATE TABLE camps (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location_name VARCHAR(255),
    address TEXT,
    latitude DOUBLE,
    longitude DOUBLE,
    location_accuracy DOUBLE,
    contact_number VARCHAR(50),
    officer_name VARCHAR(255),
    officer_uid VARCHAR(255),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### `normal_records` table
```sql
CREATE TABLE normal_records (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT,
    photo_url TEXT,
    camp_id VARCHAR(36),
    camp_name VARCHAR(255),
    officer_uid VARCHAR(255),
    officer_name VARCHAR(255),
    officer_contact VARCHAR(255),
    status VARCHAR(50) DEFAULT 'AT_CAMP',
    additional_details TEXT,
    found_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (camp_id) REFERENCES camps(id)
);
```

### `critical_records` table
```sql
CREATE TABLE critical_records (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT,
    photo_url TEXT,
    clothing_photo_url TEXT,
    last_known_clothing VARCHAR(500),
    camp_id VARCHAR(36),
    camp_name VARCHAR(255),
    officer_uid VARCHAR(255),
    officer_name VARCHAR(255),
    officer_contact VARCHAR(255),
    found_location VARCHAR(500),
    found_latitude DOUBLE,
    found_longitude DOUBLE,
    additional_details TEXT,
    status VARCHAR(50) DEFAULT 'UNIDENTIFIED',
    found_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (camp_id) REFERENCES camps(id)
);
```

## Changes Required

### 1. Update `build.gradle.kts`
- Add `spring-boot-starter-data-jpa`
- Add `com.mysql:mysql-connector-j`
- Add `org.flywaydb:flyway-core` + `flyway-mysql` for schema migration

### 2. Update `application.properties`
- Add MySQL datasource config
- Add JPA/Hibernate settings
- Add Flyway config

### 3. Create Flyway migration
**New file: `V1__create_tables.sql`**
- Create all 3 tables with indexes

### 4. Create JPA entities
**New files:**
- `Camp.java` - JPA entity for camps table
- `NormalRecord.java` - JPA entity for normal_records table
- `CriticalRecord.java` - JPA entity for critical_records table

### 5. Create JPA repositories
**New files:**
- `CampRepository.java` - `findByActiveTrue()`, search by name
- `NormalRecordRepository.java` - search by name/age/camp, find by id
- `CriticalRecordRepository.java` - search by name/age/camp, find by id

### 6. Create service layer
**New file: `RecordService.java`**
- `searchNormal(name, age, location)` - Search normal records
- `searchCritical(name, age)` - Search critical records
- `getActiveCamps()` - List active camps
- `getStats()` - Record counts
- `getRecentRecords(limit)` - Recent records

### 7. Update `SearchController.java`
- Inject `RecordService`
- Add routes: `/`, `/search`, `/critical`, `/camps`, `/about`
- Handle form submissions with MySQL queries

### 8. Create HTML templates
- `home.html` - Landing page with mission + how it works + search CTA
- `search.html` - Improved with Normal/Critical toggle, loading spinner
- `critical.html` - Critical records (no photos, privacy-first)
- `camps.html` - Active camp listing with WhatsApp share
- `about.html` - Mission, AI explanation, privacy info

### 9. WhatsApp share integration
- Generate `https://wa.me/?text=...` links
- Pre-filled messages with person details

### 10. UX improvements
- CSS loading spinner
- Form validation
- Responsive design
- ARIA accessibility labels

## File Changes Summary

| Action | File |
|--------|------|
| Edit | `build.gradle.kts` |
| Edit | `application.properties` |
| Edit | `SearchController.java` |
| Edit | `BackendService.java` |
| Edit | `search.html` |
| New | `V1__create_tables.sql` (Flyway migration) |
| New | `Camp.java` (JPA entity) |
| New | `NormalRecord.java` (JPA entity) |
| New | `CriticalRecord.java` (JPA entity) |
| New | `CampRepository.java` |
| New | `NormalRecordRepository.java` |
| New | `CriticalRecordRepository.java` |
| New | `RecordService.java` |
| New | `PublicController.java` (REST API for stats/camps) |
| New | `home.html` |
| New | `critical.html` |
| New | `camps.html` |
| New | `about.html` |

**18 files** total (5 edited, 13 new)

## Order of Implementation
1. Gradle dependencies + application.properties
2. Flyway migration SQL
3. JPA entities
4. JPA repositories
5. RecordService
6. Update SearchController + add PublicController
7. home.html (landing page)
8. search.html (improved UX)
9. critical.html
10. camps.html
11. about.html
12. WhatsApp share integration
