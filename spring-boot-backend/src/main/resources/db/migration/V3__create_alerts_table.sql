CREATE TABLE IF NOT EXISTS alerts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    type VARCHAR(255) NOT NULL,
    severity VARCHAR(255),
    district VARCHAR(255),
    state VARCHAR(255),
    latitude DOUBLE,
    longitude DOUBLE,
    radius_km DOUBLE,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_alerts_active (active),
    INDEX idx_alerts_district (district),
    INDEX idx_alerts_state (state)
);
