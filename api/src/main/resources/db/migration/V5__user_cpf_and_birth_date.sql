-- CPF is stored as its 11 digits (no mask) and must be unique among active users;
-- birth date never had a time part.
ALTER TABLE users ALTER COLUMN cpf TYPE VARCHAR(11);
ALTER TABLE users ALTER COLUMN birth_date TYPE DATE USING birth_date::date;

CREATE UNIQUE INDEX uk_users_cpf_active ON users (cpf) WHERE deleted = false;
