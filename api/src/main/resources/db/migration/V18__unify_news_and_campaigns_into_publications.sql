CREATE TABLE publications (
    id               BIGINT NOT NULL,
    kind             VARCHAR(20) NOT NULL,
    deleted          BOOLEAN,
    created_at       TIMESTAMP(6),
    updated_at       TIMESTAMP(6),
    deleted_at       TIMESTAMP(6),
    title            VARCHAR(255),
    subtitle         VARCHAR(300),
    content          VARCHAR(10000),
    cover_image      VARCHAR(500),
    category         VARCHAR(30) NOT NULL,
    author_user_id   BIGINT,
    city             VARCHAR(100),
    state            VARCHAR(2),
    organization_id  BIGINT,
    donation_info    VARCHAR(2000),
    goal_amount      NUMERIC(12, 2),
    deadline         DATE,
    status           VARCHAR(20),
    finished_at      TIMESTAMP(6),
    CONSTRAINT pk_publications PRIMARY KEY (id),
    CONSTRAINT fk_publications_author FOREIGN KEY (author_user_id) REFERENCES users (id),
    CONSTRAINT fk_publications_organization FOREIGN KEY (organization_id) REFERENCES organizations (id),
    CONSTRAINT ck_publications_kind CHECK (
        (kind = 'NEWS' AND author_user_id IS NOT NULL)
        OR (kind = 'CAMPAIGN' AND organization_id IS NOT NULL AND status IS NOT NULL)
    )
);

CREATE INDEX idx_publications_kind_created ON publications (kind, created_at);

INSERT INTO publications (
    id, kind, deleted, created_at, updated_at, deleted_at,
    title, subtitle, content, cover_image, category,
    author_user_id, city, state
)
SELECT
    id, 'NEWS', deleted, created_at, updated_at, deleted_at,
    title, subtitle, content, cover_image, category,
    author_user_id, city, state
FROM news;

CREATE TEMPORARY TABLE campaign_id_offset AS
SELECT COALESCE(MAX(id), 0) AS value FROM news;

INSERT INTO publications (
    id, kind, deleted, created_at, updated_at, deleted_at,
    title, subtitle, content, cover_image, category,
    organization_id, donation_info, goal_amount, deadline, status, finished_at
)
SELECT
    c.id + o.value, 'CAMPAIGN', c.deleted, c.created_at, c.updated_at, c.deleted_at,
    c.title, c.subtitle, c.description, c.cover_image, c.category,
    c.organization_id, c.donation_info, c.goal_amount, c.deadline, c.status, c.finished_at
FROM campaigns c
CROSS JOIN campaign_id_offset o;

UPDATE notifications
SET target_id = target_id + (SELECT value FROM campaign_id_offset)
WHERE type = 'CAMPAIGN_CREATED'
  AND target_id IS NOT NULL;

DO $$
DECLARE
    next_id BIGINT;
BEGIN
    SELECT COALESCE(MAX(id), 0) + 100 INTO next_id FROM publications;
    EXECUTE format('CREATE SEQUENCE publications_seq START WITH %s INCREMENT BY 50', next_id);
END $$;

DROP TABLE campaign_id_offset;

DROP TABLE campaigns;
DROP SEQUENCE campaigns_seq;

DROP TABLE news;
DROP SEQUENCE news_seq;
