-- assisted_person_tags was modeled as a full auditable entity (id, created_at, updated_at,
-- deleted, deleted_at) for what is really just the join table of a many-to-many relationship
-- between assisted_people and tags. Simplify it into a plain join table with a composite key,
-- matching the @ManyToMany mapping on AssistedPerson.

ALTER TABLE assisted_person_tags
    DROP COLUMN id,
    DROP COLUMN created_at,
    DROP COLUMN updated_at,
    DROP COLUMN deleted,
    DROP COLUMN deleted_at,
    ALTER COLUMN assisted_person_id SET NOT NULL,
    ALTER COLUMN tag_id SET NOT NULL,
    ADD CONSTRAINT pk_assisted_person_tags PRIMARY KEY (assisted_person_id, tag_id);

DROP SEQUENCE IF EXISTS assisted_person_tags_seq;
