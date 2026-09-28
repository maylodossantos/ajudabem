CREATE TABLE notifications (
    id                 BIGINT NOT NULL,
    deleted            BOOLEAN,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    deleted_at         TIMESTAMP(6),
    recipient_user_id  BIGINT NOT NULL,
    type               VARCHAR(40) NOT NULL,
    title              VARCHAR(150) NOT NULL,
    message            VARCHAR(500) NOT NULL,
    target_id          BIGINT,
    read_at            TIMESTAMP(6),
    CONSTRAINT pk_notifications PRIMARY KEY (id),
    CONSTRAINT fk_notifications_recipient FOREIGN KEY (recipient_user_id) REFERENCES users (id)
);

CREATE INDEX idx_notifications_recipient ON notifications (recipient_user_id, created_at);

CREATE SEQUENCE notifications_seq START WITH 1 INCREMENT BY 50;
