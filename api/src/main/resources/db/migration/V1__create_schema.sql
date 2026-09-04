-- Schema derived from the JPA entity mappings (com.ajudabem.api.domains.*).
-- Sequence increment of 50 matches Hibernate's default SequenceStyleGenerator allocation size.

CREATE TABLE users (
    id              BIGINT NOT NULL,
    deleted         BOOLEAN,
    created_at      TIMESTAMP(6),
    updated_at      TIMESTAMP(6),
    deleted_at      TIMESTAMP(6),
    name            VARCHAR(255),
    email           VARCHAR(255),
    password        VARCHAR(255),
    phone           VARCHAR(255),
    profile_image   VARCHAR(255),
    cpf             VARCHAR(255),
    role            SMALLINT CHECK (role BETWEEN 0 AND 2),
    birth_date      TIMESTAMP(6),
    last_login_at   TIMESTAMP(6),
    CONSTRAINT pk_users PRIMARY KEY (id)
);

CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE tags (
    id      BIGINT NOT NULL,
    name    VARCHAR(255),
    CONSTRAINT pk_tags PRIMARY KEY (id)
);

CREATE SEQUENCE tags_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE news (
    id              BIGINT NOT NULL,
    deleted         BOOLEAN,
    created_at      TIMESTAMP(6),
    updated_at      TIMESTAMP(6),
    deleted_at      TIMESTAMP(6),
    author_user_id  BIGINT NOT NULL,
    title           VARCHAR(255),
    subtitle        VARCHAR(255),
    content         VARCHAR(255),
    cover_image     VARCHAR(255),
    CONSTRAINT pk_news PRIMARY KEY (id),
    CONSTRAINT fk_news_author FOREIGN KEY (author_user_id) REFERENCES users (id)
);

CREATE SEQUENCE news_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE assisted_people (
    id                  BIGINT NOT NULL,
    deleted             BOOLEAN,
    created_at          TIMESTAMP(6),
    updated_at          TIMESTAMP(6),
    deleted_at          TIMESTAMP(6),
    created_user_id     BIGINT NOT NULL,
    full_name           VARCHAR(255),
    age                 INTEGER,
    gender              SMALLINT CHECK (gender BETWEEN 0 AND 2),
    risk_level          SMALLINT CHECK (risk_level BETWEEN 0 AND 2),
    notes               VARCHAR(255),
    street              VARCHAR(255),
    number              VARCHAR(255),
    neighborhood        VARCHAR(255),
    city                VARCHAR(255),
    state               VARCHAR(255),
    zip_code            VARCHAR(255),
    country             VARCHAR(255),
    CONSTRAINT pk_assisted_people PRIMARY KEY (id),
    CONSTRAINT fk_assisted_people_author FOREIGN KEY (created_user_id) REFERENCES users (id)
);

CREATE SEQUENCE assisted_people_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE assisted_person_tags (
    id                      BIGINT NOT NULL,
    deleted                 BOOLEAN,
    created_at              TIMESTAMP(6),
    updated_at              TIMESTAMP(6),
    deleted_at              TIMESTAMP(6),
    assisted_person_id     BIGINT,
    tag_id                  BIGINT,
    CONSTRAINT pk_assisted_person_tags PRIMARY KEY (id),
    CONSTRAINT fk_assisted_person_tags_assisted_person FOREIGN KEY (assisted_person_id) REFERENCES assisted_people (id),
    CONSTRAINT fk_assisted_person_tags_tag FOREIGN KEY (tag_id) REFERENCES tags (id)
);

CREATE SEQUENCE assisted_person_tags_seq START WITH 1 INCREMENT BY 50;
