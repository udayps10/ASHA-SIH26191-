CREATE TABLE IF NOT EXISTS saved_searches (
    id VARCHAR(36) PRIMARY KEY,
    user_phone VARCHAR(20) NOT NULL,
    search_name VARCHAR(255) NOT NULL,
    search_age INT,
    search_location VARCHAR(255),
    search_additional_details TEXT,
    record_type VARCHAR(20) DEFAULT 'BOTH',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_ss_active (active),
    INDEX idx_ss_name (search_name),
    INDEX idx_ss_phone (user_phone)
);

ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;
