ALTER TABLE users
    ADD COLUMN terms_accepted_at             TIMESTAMP(6),
    ADD COLUMN reset_password_code           VARCHAR(255),
    ADD COLUMN reset_password_code_expires_at TIMESTAMP(6),
    ADD COLUMN reset_password_token          VARCHAR(255),
    ADD COLUMN reset_password_token_expires_at TIMESTAMP(6);
