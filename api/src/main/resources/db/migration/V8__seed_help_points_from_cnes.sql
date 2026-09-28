-- Initial load of help points: the public health units of Cascavel-PR from CNES
-- (Cadastro Nacional de Estabelecimentos de Saúde, apidadosabertos.saude.gov.br, snapshot of
-- 2026-09-27): basic units (UBS/USF), CAPS, UPAs and the "Consultório na Rua" team. Units that
-- are disabled or not open to the public (CENSE, prisons) were left out. After this, help points
-- are only registered by admins in the app. CNES only reports the shift, not the exact hours, so
-- only the 24h units get structured opening hours; the others carry the shift as a note.

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'CAPS AD Centro de Atenção Psicossocial Álcool e Drogas', 'Centro de Atenção Psicossocial (SUS) para pessoas com problemas relacionados ao uso de álcool e outras drogas: acolhimento e tratamento.', 'PUBLIC_HEALTH', 'Rua Santa Catarina', '107', 'Centro', 'Cascavel', 'PR', '85801040', -24.9607058, -53.4502755, '4539021898', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '3240045')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('PSYCHOLOGICAL'), ('RECEPTION')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'CAPS AD III', 'Centro de Atenção Psicossocial (SUS) para pessoas com problemas relacionados ao uso de álcool e outras drogas: acolhimento e tratamento.', 'PUBLIC_HEALTH', 'Rua Poente do Sol', '788', 'Brasmadeira', 'Cascavel', 'PR', '85814160', -24.921974813843892, -53.43891620635986, '4533246530', 'simpr@cisop.com.br', 'Atendimento contínuo 24 horas, inclusive sábados, domingos e feriados.', 'CNES', '7407475')
    RETURNING id
)
, services AS (
    INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('PSYCHOLOGICAL'), ('RECEPTION')) AS v(s)
)
INSERT INTO help_point_opening_hours (help_point_id, day_of_week, opens_at, closes_at)
SELECT id, d, TIME '00:00', TIME '00:00' FROM point, unnest(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']) AS d;

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'CAPS III Centro de Atenção Psicossocial', 'Centro de Atenção Psicossocial (SUS): acolhimento e tratamento em saúde mental.', 'PUBLIC_HEALTH', 'Rua Cuiabá', '4294', 'Ciro Nardi', 'Cascavel', 'PR', '85802030', -24.96528202144178, -53.478513799999995, '4539022660', 'marcial@cascavel.pr.gov.br', 'Atendimento contínuo 24 horas, inclusive sábados, domingos e feriados.', 'CNES', '3950352')
    RETURNING id
)
, services AS (
    INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('PSYCHOLOGICAL'), ('RECEPTION')) AS v(s)
)
INSERT INTO help_point_opening_hours (help_point_id, day_of_week, opens_at, closes_at)
SELECT id, d, TIME '00:00', TIME '00:00' FROM point, unnest(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']) AS d;

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'CAPSI Centro Atenção Psicossocial Infância e Adolescência', 'Centro de Atenção Psicossocial (SUS) para pessoas com problemas relacionados ao uso de álcool e outras drogas: acolhimento e tratamento.', 'PUBLIC_HEALTH', 'Rua Manaus', '3806', 'Claudete', 'Cascavel', 'PR', '85811030', -24.942908348497138, -53.4779967288354, '4533926595', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2737035')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('PSYCHOLOGICAL'), ('RECEPTION')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'Consultório na Rua', 'Equipe de saúde do SUS que atende pessoas em situação de rua: consultas, curativos, orientação e encaminhamento para a rede de saúde.', 'PUBLIC_HEALTH', 'Avenida Tancredo Neves', '777', 'Alto Alegre', 'Cascavel', 'PR', '85805000', -24.960137174177476, -53.47635008887317, NULL, NULL, 'Atendimento nos turnos da manhã, tarde e noite (informado pelo CNES).', 'CNES', '7958110')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UPA Brasília', 'Unidade de Pronto Atendimento (SUS) para urgências e emergências, aberta 24 horas.', 'PUBLIC_HEALTH', 'Rua Europa', '2650', 'Brasília', 'Cascavel', 'PR', '85815340', -24.940868000000002, -53.423740569703725, '4533926100', NULL, 'Atendimento contínuo 24 horas, inclusive sábados, domingos e feriados.', 'CNES', '3293262')
    RETURNING id
)
, services AS (
    INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s)
)
INSERT INTO help_point_opening_hours (help_point_id, day_of_week, opens_at, closes_at)
SELECT id, d, TIME '00:00', TIME '00:00' FROM point, unnest(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']) AS d;

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UPA Tancredo Neves', 'Unidade de Pronto Atendimento (SUS) para urgências e emergências, aberta 24 horas.', 'PUBLIC_HEALTH', 'Avenida Tancredo Neves', '2433', 'Pioneiros Catarinenses', 'Cascavel', 'PR', '85805000', -24.970693, -53.487258, '4533926700', NULL, 'Atendimento contínuo 24 horas, inclusive sábados, domingos e feriados.', 'CNES', '7119097')
    RETURNING id
)
, services AS (
    INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s)
)
INSERT INTO help_point_opening_hours (help_point_id, day_of_week, opens_at, closes_at)
SELECT id, d, TIME '00:00', TIME '00:00' FROM point, unnest(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']) AS d;

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UPA Veneza', 'Unidade de Pronto Atendimento (SUS) para urgências e emergências, aberta 24 horas.', 'PUBLIC_HEALTH', 'Rua Café Filho', '1460', 'Jardim Veneza', 'Cascavel', 'PR', '85818130', -24.974381, -53.411717, '4533926200', NULL, 'Atendimento contínuo 24 horas, inclusive sábados, domingos e feriados.', 'CNES', '2738864')
    RETURNING id
)
, services AS (
    INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s)
)
INSERT INTO help_point_opening_hours (help_point_id, day_of_week, opens_at, closes_at)
SELECT id, d, TIME '00:00', TIME '00:00' FROM point, unnest(ARRAY['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']) AS d;

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Aclimação', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Recife', '3606', 'Aclimação', 'Cascavel', 'PR', '85807060', -24.950071254372684, -53.49289298057556, '4539021427', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736667')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Cancelli', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Marechal Cândido Rondon', '3534', 'Cancelli', 'Cascavel', 'PR', '85811080', -24.942876, -53.463176, '4533926460', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736675')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Claudete', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Hélio Richard', '1561', 'Claudete', 'Cascavel', 'PR', '85811220', -24.94117792272517, -53.47459895058233, '4533926532', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736713')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Floresta', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Siriema', '234', 'Floresta', 'Cascavel', 'PR', '85814560', -24.915405657779626, -53.42321740207183, '4533926322', NULL, 'Atendimento nos turnos da manhã, tarde e noite (informado pelo CNES).', 'CNES', '2737019')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Los Angeles', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Vinícius de Moraes', '1463', 'Los Angeles', 'Cascavel', 'PR', '85815250', -24.93022871029118, -53.42396617116404, '4539021875', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736837')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Nova Cidade', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Andrea Galafassi', '386', 'Santa Felicidade', 'Cascavel', 'PR', '85803170', -24.987477585411888, -53.45527829999999, '4533926480', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736799')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Pacaembu', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Corbélia', NULL, 'Pacaembu', 'Cascavel', 'PR', '85816570', -24.958521, -53.423177, '4533926463', 'ubs-pacaembu@cascavel.pr.gov.br', 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736853')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Palmeiras', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Cuiabá', '5423', 'Alto Alegre', 'Cascavel', 'PR', '85805260', -24.960921, -53.489117, '4539021438', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736861')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Parque São Paulo', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Celso Esperança', '355', 'Parque São Paulo', 'Cascavel', 'PR', '85803660', -24.97864543861328, -53.4572347, '4539021884', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736888')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Santa Cruz', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Xavantes', '729', 'Santa Cruz', 'Cascavel', 'PR', '85806020', -24.967468, -53.502819, '4533926616', NULL, 'Atendimento nos turnos da manhã, tarde e noite (informado pelo CNES).', 'CNES', '2736934')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS São Cristóvão', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Castro', NULL, 'São Cristóvão', 'Cascavel', 'PR', '85816060', -24.939688991210147, -53.4291822002573, '4533926672', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736748')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'UBS Vila Tolentino', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Salgado Filho', '253', 'Vila Tolentino', 'Cascavel', 'PR', '85802150', -24.974519, -53.467936, '4539021897', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736993')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Brasmadeira', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Poente do Sol', NULL, 'Brasmadeira', 'Cascavel', 'PR', '85814160', -24.923499, -53.438752, '4539021431', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736810')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Canadá', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Salgado Filho', '4881', 'Jardim Canadá', 'Cascavel', 'PR', '85813740', -24.933277, -53.465386, '4539022704', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7045107')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Cascavel Velho', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Estocolmo', '791', 'Cascavel Velho', 'Cascavel', 'PR', '85818290', -24.976502, -53.426949, '4539021777', NULL, 'Atendimento nos turnos da manhã, tarde e noite (informado pelo CNES).', 'CNES', '2736683')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Cataratas', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Carlos Cavalcante', '260', 'Cataratas', 'Cascavel', 'PR', '85818670', -24.962128, -53.402216, '4539021429', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736691')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Cidade Verde', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Itaúba', '231', 'Cidade Verde', 'Cascavel', 'PR', '85807675', -24.93676994833072, -53.489575, '4539021135', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7860889')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Colmeia', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Horácio Ribeiro dos Reis', NULL, 'Colmeia', 'Cascavel', 'PR', '85817600', -24.952977, -53.409008, '4539021436', 'sesau@cascavel.pr.gov.br', 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736721')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Espigão Azul', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Distrito de Espigão Azul', NULL, 'Zona Rural', 'Cascavel', 'PR', '85820971', -24.898497194486747, -53.46836213559534, '4530366931', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '6696775')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Guarujá', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua das Flores', '1472', 'Guarujá', 'Cascavel', 'PR', '85804380', -24.984339437566877, -53.49898095767082, '4539021878', NULL, 'Atendimento nos turnos da manhã, tarde e noite (informado pelo CNES).', 'CNES', '2736802')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Interlagos', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Avenida Interlagos', '615', 'Interlagos', 'Cascavel', 'PR', '85814260', -24.914891, -53.438158, '4539021424', 'sesau@cascavel.pr.gov.br', 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '6256988')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Jardim Ipanema', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Ásia', '266', 'Periollo', 'Cascavel', 'PR', '85817280', -24.937914169621724, -53.41391390207129, '4539022688', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7833504')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Jardim Presidente', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Saldanha Marinho', NULL, 'Jardim Presidente', 'Cascavel', 'PR', '85818160', -24.9684286, -53.407958, '4539022490', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '9361030')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Juvinópolis', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Três Meninas', NULL, 'Distrito Juvinópolis', 'Cascavel', 'PR', '85821000', -25.278489, -53.346561, '4532391170', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736829')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Lago Azul', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Lagoa Marapende', '1449', 'Lago Azul', 'Cascavel', 'PR', '85817647', -24.922383483931686, -53.39510101349444, '4539022583', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7569572')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Maria Luiza', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua da Lapa', '680', 'Maria Luiza', 'Cascavel', 'PR', '85819740', -24.969126, -53.443152, '4539021292', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7986017')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Morumbi', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua São Roque', '1119', 'Morumbi', 'Cascavel', 'PR', '85817270', -24.936216, -53.403792, '4539092609', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736845')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Navegantes', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rural', NULL, 'Navegantes', 'Cascavel', 'PR', '85819000', -25.93233962580041, -53.45791854564335, '4532206723', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2737345')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Parque Verde', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Acácia', NULL, 'Parque Verde', 'Cascavel', 'PR', '85807760', -24.94051402616044, -53.48936207108446, '4533926493', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736896')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Periollo', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Leblon', '400', 'Periollo', 'Cascavel', 'PR', '85817050', -24.9454983595428, -53.41631915767081, '4539022641', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736918')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Pioneiros Catarinense', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Orlando Vasconcelos', '284', 'Pioneiros Catarinenses', 'Cascavel', 'PR', '85805540', -24.969922, -53.480615, '4539022496', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '9361049')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Rio do Salto', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua das Flores', NULL, 'Distrito Rio do Salto', 'Cascavel', 'PR', '85824000', -25.13587990599262, -53.33444196207816, '4533521022', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736926')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Riviera', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Fernando de Noronha', '2612', 'Jardim Riviera', 'Cascavel', 'PR', '85814804', -24.911221987894095, -53.41068732883518, '4539021492', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '9356649')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Sanga Funda', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Affonso José Martins', '429', 'Interlagos', 'Cascavel', 'PR', '85814486', -24.91160019218959, -53.42545380316964, '4539021896', 'sanga.funda@cascavel.pr.gov.br', 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '3429806')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Santa Bárbara', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'BR 277 Km 564', NULL, 'Santa Bárbara', 'Cascavel', 'PR', '85819000', -25.047731072878165, -53.240361907574474, '4530969007', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2737353')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Santa Felicidade', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Sargento José Bernardo Rosa', '113', 'Santa Felicidade', 'Cascavel', 'PR', '85803320', -24.995177910025024, -53.458418499999986, '4533926490', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736942')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Santo Inácio FAG', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Aníbal Curi', '376', 'FAG', 'Cascavel', 'PR', '85806097', -24.949689819015177, -53.5056136711648, '4539022655', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '3521230')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Santo Onofre', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Avenida Tito Muffato', '712', 'Santo Onofre', 'Cascavel', 'PR', '85806080', -24.974672988447093, -53.504007671164594, '4539022702', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '7045085')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Santos Dumont', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Padre Donizetti', '119', 'Santos Dumont', 'Cascavel', 'PR', '85804760', -24.984175537082617, -53.50974752883541, '4539021143', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736950')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF São Francisco de Assis', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'BR 369 Km 511', NULL, 'Área Rural', 'Cascavel', 'PR', '85803490', -24.846093, -53.319924, '4530366927', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736969')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF São João', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Avenida das Palmeiras', NULL, 'Distrito de São João', 'Cascavel', 'PR', '85823000', -24.961722, -53.245245, '4533461002', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736977')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF São Salvador', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Principal', NULL, 'Distrito de São Salvador', 'Cascavel', 'PR', '85820970', -25.05826124491215, -53.3774518108293, '4533243031', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2737361')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Sede Alvorada', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Antônio José Scherer', NULL, 'Distrito Sede Alvorada', 'Cascavel', 'PR', '85822000', -24.825974, -53.647342, '4530366903', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2736985')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Tarumã', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Adolfo Garcia', NULL, 'Interlagos', 'Cascavel', 'PR', '85814400', -24.914542, -53.430164, NULL, NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '9590560')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Tio Zaca', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Cassia', '840', 'Esmeralda', 'Cascavel', 'PR', '85806135', -24.96063008448721, -53.508144, NULL, NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '930520')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF Universitário', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua João Merlin', NULL, 'Universitário', 'Cascavel', 'PR', '85819040', -24.97953775047325, -53.441179178861695, '4539021484', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '4171853')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);

WITH point AS (
    INSERT INTO help_points (id, deleted, created_at, updated_at, name, description, organization_type,
                             street, number, neighborhood, city, state, zip_code, latitude, longitude,
                             phone, email, schedule_note, source, external_id)
    VALUES (nextval('help_points_seq'), false, now(), now(), 'USF XIV de Novembro', 'Unidade de saúde do SUS: consultas, vacinas, curativos, retirada de medicamentos e acompanhamento de saúde.', 'PUBLIC_HEALTH', 'Rua Francisco Guaraná Menezes', '564', 'XIV de Novembro', 'Cascavel', 'PR', '85804050', -24.98624368707461, -53.47923877116459, '4539022626', NULL, 'Atendimento nos turnos da manhã e da tarde (informado pelo CNES).', 'CNES', '2737000')
    RETURNING id
)
INSERT INTO help_point_services (help_point_id, service) SELECT id, s FROM point, (VALUES ('MEDICAL')) AS v(s);
