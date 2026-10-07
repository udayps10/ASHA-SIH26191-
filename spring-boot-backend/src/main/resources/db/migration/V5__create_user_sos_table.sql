CREATE TABLE IF NOT EXISTS user_sos (
    id VARCHAR(128) PRIMARY KEY,
    user_uid VARCHAR(128) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    accuracy DOUBLE NOT NULL,
    message TEXT,
    status VARCHAR(32) NOT NULL DEFAULT 'RECEIVED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_sos_user_uid (user_uid),
    INDEX idx_user_sos_status (status),
    INDEX idx_user_sos_created_at (created_at)
);