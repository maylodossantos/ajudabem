CREATE TABLE campaigns (
    id               BIGINT NOT NULL,
    deleted          BOOLEAN,
    created_at       TIMESTAMP(6),
    updated_at       TIMESTAMP(6),
    deleted_at       TIMESTAMP(6),
    organization_id  BIGINT NOT NULL,
    title            VARCHAR(150) NOT NULL,
    donation_info    VARCHAR(2000),
    subtitle         VARCHAR(300),
    description      VARCHAR(5000) NOT NULL,
    category         VARCHAR(30) NOT NULL,
    goal_amount      NUMERIC(12, 2),
    deadline         DATE,
    cover_image      VARCHAR(500),
    status           VARCHAR(20) NOT NULL,
    finished_at      TIMESTAMP(6),
    CONSTRAINT pk_campaigns PRIMARY KEY (id),
    CONSTRAINT fk_campaigns_organization FOREIGN KEY (organization_id) REFERENCES organizations (id)
);

CREATE SEQUENCE campaigns_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE volunteer_actions (
    id                 BIGINT NOT NULL,
    deleted            BOOLEAN,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    deleted_at         TIMESTAMP(6),
    organization_id    BIGINT NOT NULL,
    title              VARCHAR(150) NOT NULL,
    action_date        DATE NOT NULL,
    start_time         TIME NOT NULL,
    end_time           TIME NOT NULL,
    volunteers_needed  INTEGER NOT NULL,
    street             VARCHAR(255) NOT NULL,
    number             VARCHAR(20),
    city               VARCHAR(100) NOT NULL,
    state              VARCHAR(2) NOT NULL,
    zip_code           VARCHAR(8),
    description        VARCHAR(2000) NOT NULL,
    tasks              VARCHAR(2000),
    requirements       VARCHAR(2000),
    notes              VARCHAR(2000),
    status             VARCHAR(20) NOT NULL,
    finished_at        TIMESTAMP(6),
    CONSTRAINT pk_volunteer_actions PRIMARY KEY (id),
    CONSTRAINT fk_volunteer_actions_organization FOREIGN KEY (organization_id) REFERENCES organizations (id)
);

CREATE SEQUENCE volunteer_actions_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE volunteer_applications (
    id                 BIGINT NOT NULL,
    deleted            BOOLEAN,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    deleted_at         TIMESTAMP(6),
    action_id          BIGINT NOT NULL,
    volunteer_user_id  BIGINT NOT NULL,
    status             VARCHAR(20) NOT NULL,
    CONSTRAINT pk_volunteer_applications PRIMARY KEY (id),
    CONSTRAINT fk_volunteer_applications_action FOREIGN KEY (action_id) REFERENCES volunteer_actions (id),
    CONSTRAINT fk_volunteer_applications_volunteer FOREIGN KEY (volunteer_user_id) REFERENCES users (id)
);

CREATE SEQUENCE volunteer_applications_seq START WITH 1 INCREMENT BY 50;
