CREATE TABLE risk_triage_logs (
    id                  BIGINT NOT NULL,
    deleted             BOOLEAN,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    deleted_at          TIMESTAMP(6),
    assisted_person_id  BIGINT NOT NULL,
    risk_level          VARCHAR(10) NOT NULL,
    justification       VARCHAR(2000),
    model               VARCHAR(100) NOT NULL,
    input               VARCHAR(4000) NOT NULL,
    duration_ms         BIGINT NOT NULL,
    CONSTRAINT pk_risk_triage_logs PRIMARY KEY (id),
    CONSTRAINT fk_risk_triage_logs_assisted_person FOREIGN KEY (assisted_person_id) REFERENCES assisted_people (id)
);

CREATE INDEX idx_risk_triage_logs_person ON risk_triage_logs (assisted_person_id, created_at);

CREATE SEQUENCE risk_triage_logs_seq START WITH 1 INCREMENT BY 50;
