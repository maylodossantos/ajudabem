-- Help points ("Pontos de ajuda"): places where people in need can get shelter, food,
-- clothes or care. Admins register them; V8 seeds the public health units of Cascavel
-- from CNES once (source = 'CNES', external_id = CNES code).

CREATE TABLE help_points (
    id                 BIGINT NOT NULL,
    deleted            BOOLEAN,
    created_at         TIMESTAMP(6),
    updated_at         TIMESTAMP(6),
    deleted_at         TIMESTAMP(6),
    name               VARCHAR(150) NOT NULL,
    description        VARCHAR(1000),
    cover_image        VARCHAR(500),
    organization_type  VARCHAR(30) NOT NULL,
    street             VARCHAR(255),
    number             VARCHAR(20),
    neighborhood       VARCHAR(100),
    city               VARCHAR(100),
    state              VARCHAR(2),
    zip_code           VARCHAR(8),
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    phone              VARCHAR(20),
    whatsapp           VARCHAR(20),
    email              VARCHAR(255),
    responsible        VARCHAR(255),
    schedule_note      VARCHAR(255),
    notes              VARCHAR(1000),
    source             VARCHAR(20) NOT NULL,
    external_id        VARCHAR(50),
    CONSTRAINT pk_help_points PRIMARY KEY (id)
);

CREATE SEQUENCE help_points_seq START WITH 1 INCREMENT BY 50;

CREATE TABLE help_point_services (
    help_point_id  BIGINT NOT NULL,
    service        VARCHAR(30) NOT NULL,
    CONSTRAINT pk_help_point_services PRIMARY KEY (help_point_id, service),
    CONSTRAINT fk_help_point_services_help_point FOREIGN KEY (help_point_id) REFERENCES help_points (id)
);

-- One row per day it opens. closes_at <= opens_at means it closes the next day
-- (e.g. 18:00-07:00); closes_at = opens_at means open the whole day (24h).
CREATE TABLE help_point_opening_hours (
    help_point_id  BIGINT NOT NULL,
    day_of_week    VARCHAR(10) NOT NULL,
    opens_at       TIME NOT NULL,
    closes_at      TIME NOT NULL,
    CONSTRAINT fk_help_point_opening_hours_help_point FOREIGN KEY (help_point_id) REFERENCES help_points (id)
);
