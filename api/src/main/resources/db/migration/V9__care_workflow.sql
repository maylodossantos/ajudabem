ALTER TABLE assisted_people
    ADD COLUMN care_status      VARCHAR(20) NOT NULL DEFAULT 'NOMINATED',
    ADD COLUMN organization_id  BIGINT,
    ADD COLUMN care_started_at  TIMESTAMP(6),
    ADD COLUMN care_updated_at  TIMESTAMP(6),
    ADD COLUMN finish_reason    VARCHAR(40),
    ADD COLUMN latitude         DOUBLE PRECISION,
    ADD COLUMN longitude        DOUBLE PRECISION,
    ADD CONSTRAINT fk_assisted_people_organization FOREIGN KEY (organization_id) REFERENCES organizations (id);

ALTER TABLE organizations
    ADD COLUMN latitude   DOUBLE PRECISION,
    ADD COLUMN longitude  DOUBLE PRECISION;

CREATE TABLE care_records (
    id                  BIGINT NOT NULL,
    deleted             BOOLEAN,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    deleted_at          TIMESTAMP(6),
    assisted_person_id  BIGINT NOT NULL,
    author_user_id      BIGINT NOT NULL,
    number              INTEGER NOT NULL,
    status              VARCHAR(20) NOT NULL,
    occurred_at         TIMESTAMP(6) NOT NULL,
    situation           VARCHAR(2000),
    action_taken        VARCHAR(2000),
    referral            VARCHAR(2000),
    next_step           VARCHAR(2000),
    summary             VARCHAR(2000),
    note                VARCHAR(2000),
    finish_reason       VARCHAR(40),
    CONSTRAINT pk_care_records PRIMARY KEY (id),
    CONSTRAINT fk_care_records_assisted_person FOREIGN KEY (assisted_person_id) REFERENCES assisted_people (id),
    CONSTRAINT fk_care_records_author FOREIGN KEY (author_user_id) REFERENCES users (id)
);

CREATE SEQUENCE care_records_seq START WITH 1 INCREMENT BY 50;

INSERT INTO tags (id, name) VALUES (6, 'Roupas');
SELECT setval('tags_seq', 101);
