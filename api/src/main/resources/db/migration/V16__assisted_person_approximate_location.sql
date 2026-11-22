ALTER TABLE assisted_people
    ADD COLUMN location_description VARCHAR(500),
    ADD COLUMN location_pending     BOOLEAN NOT NULL DEFAULT FALSE;
