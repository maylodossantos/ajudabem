-- NGO validation requests. A user submits their organization with the required documents;
-- an admin approves it (the owner becomes USER_ONG) or rejects it with a reason. After a
-- rejection the same row is resubmitted, so each user has at most one active organization.

CREATE TABLE organizations (
    id                   BIGINT NOT NULL,
    deleted              BOOLEAN,
    created_at           TIMESTAMP(6),
    updated_at           TIMESTAMP(6),
    deleted_at           TIMESTAMP(6),
    owner_user_id        BIGINT NOT NULL,
    corporate_name       VARCHAR(150),
    trade_name           VARCHAR(150),
    cnpj                 VARCHAR(14),
    activity_area        VARCHAR(100),
    street               VARCHAR(255),
    number               VARCHAR(20),
    neighborhood         VARCHAR(100),
    city                 VARCHAR(100),
    state                VARCHAR(2),
    zip_code             VARCHAR(8),
    website              VARCHAR(255),
    instagram            VARCHAR(100),
    status               VARCHAR(20) NOT NULL CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    submitted_at         TIMESTAMP(6),
    reviewed_at          TIMESTAMP(6),
    reviewed_by_user_id  BIGINT,
    rejection_reason     VARCHAR(40),
    rejection_note       VARCHAR(1000),
    CONSTRAINT pk_organizations PRIMARY KEY (id),
    CONSTRAINT fk_organizations_owner FOREIGN KEY (owner_user_id) REFERENCES users (id),
    CONSTRAINT fk_organizations_reviewer FOREIGN KEY (reviewed_by_user_id) REFERENCES users (id)
);

CREATE SEQUENCE organizations_seq START WITH 1 INCREMENT BY 50;

CREATE UNIQUE INDEX uk_organizations_owner_active ON organizations (owner_user_id) WHERE deleted = false;
CREATE UNIQUE INDEX uk_organizations_cnpj_active ON organizations (cnpj) WHERE deleted = false;

-- What was sent for each required document (listed with the organization)...
CREATE TABLE organization_documents (
    organization_id  BIGINT NOT NULL,
    type             VARCHAR(40) NOT NULL,
    file_name        VARCHAR(255) NOT NULL,
    content_type     VARCHAR(100) NOT NULL,
    size_bytes       BIGINT NOT NULL,
    sent_at          TIMESTAMP(6),
    CONSTRAINT pk_organization_documents PRIMARY KEY (organization_id, type),
    CONSTRAINT fk_organization_documents_organization FOREIGN KEY (organization_id) REFERENCES organizations (id)
);

-- ...and the PDF itself, kept apart so listing organizations never loads file contents.
-- These are confidential (bylaws, the responsible person's ID): they are only served through
-- the API to admins and the owner, never through a public URL.
CREATE TABLE organization_document_files (
    organization_id  BIGINT NOT NULL,
    type             VARCHAR(40) NOT NULL,
    content          BYTEA NOT NULL,
    CONSTRAINT pk_organization_document_files PRIMARY KEY (organization_id, type),
    CONSTRAINT fk_organization_document_files_organization FOREIGN KEY (organization_id) REFERENCES organizations (id)
);
