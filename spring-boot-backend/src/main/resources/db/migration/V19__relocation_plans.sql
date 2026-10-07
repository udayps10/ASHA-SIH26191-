CREATE TABLE IF NOT EXISTS relocation_plans (
 id VARCHAR(36) PRIMARY KEY, owner_uid VARCHAR(128) NOT NULL,
 title VARCHAR(160) NOT NULL, demo BOOLEAN NOT NULL,
 status VARCHAR(20) NOT NULL, input_json LONGTEXT NOT NULL, result_json LONGTEXT NOT NULL,
 review_note VARCHAR(1000), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 reviewed_at TIMESTAMP NULL, INDEX idx_relocation_owner(owner_uid)
);
