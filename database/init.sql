-- ============================================================
--  Clínica del Sur — Script de Inicialización
--  PostgreSQL 18
--  Generado: 2026-04-02
-- ============================================================


-- ============================================================
--  DROP (orden inverso a dependencias para ejecución repetible)
-- ============================================================

DROP TABLE IF EXISTS bloqueo_agenda      CASCADE;
DROP TABLE IF EXISTS horario_base        CASCADE;
DROP TABLE IF EXISTS receta_medicamento  CASCADE;
DROP TABLE IF EXISTS receta              CASCADE;
DROP TABLE IF EXISTS medicamento         CASCADE;
DROP TABLE IF EXISTS turno_laboratorio   CASCADE;
DROP TABLE IF EXISTS turno               CASCADE;
DROP TABLE IF EXISTS ticket              CASCADE;
DROP TABLE IF EXISTS personal_licencia   CASCADE;
DROP TABLE IF EXISTS licencia            CASCADE;
DROP TABLE IF EXISTS medico              CASCADE;
DROP TABLE IF EXISTS personal            CASCADE;
DROP TABLE IF EXISTS cargo               CASCADE;
DROP TABLE IF EXISTS departamento        CASCADE;
DROP TABLE IF EXISTS area                CASCADE;
DROP TABLE IF EXISTS estudio_laboratorio CASCADE;
DROP TABLE IF EXISTS tipo_turno          CASCADE;
DROP TABLE IF EXISTS consultorio         CASCADE;
DROP TABLE IF EXISTS paciente            CASCADE;
DROP TABLE IF EXISTS obra_social         CASCADE;


-- ============================================================
--  DDL — Creación de tablas
-- ============================================================

CREATE TABLE area (
    id_area  SERIAL      PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL
);

CREATE TABLE departamento (
    id_departamento SERIAL       PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    id_area         INT          NOT NULL REFERENCES area(id_area)
);

CREATE TABLE cargo (
    id_cargo SERIAL       PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL
);

CREATE TABLE personal (
    id_personal     SERIAL       PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    dni             VARCHAR(15)  NOT NULL UNIQUE,
    telefono        VARCHAR(25),
    email           VARCHAR(150) NOT NULL UNIQUE,
    fecha_ingreso   DATE         NOT NULL,
    id_cargo        INT          NOT NULL REFERENCES cargo(id_cargo),
    id_departamento INT          NOT NULL REFERENCES departamento(id_departamento)
);

CREATE TABLE medico (
    id_medico   SERIAL      PRIMARY KEY,
    id_personal INT         NOT NULL UNIQUE REFERENCES personal(id_personal),
    matricula   VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE consultorio (
    id_consultorio SERIAL      PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL
);

CREATE TABLE obra_social (
    id_obra_social       SERIAL       PRIMARY KEY,
    nombre               VARCHAR(100) NOT NULL,
    plan                 VARCHAR(100) NOT NULL,
    porcentaje_cobertura DECIMAL(5,2) NOT NULL CHECK (porcentaje_cobertura BETWEEN 0 AND 100)
);

CREATE TABLE paciente (
    id_paciente      SERIAL       PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    dni              VARCHAR(15)  NOT NULL UNIQUE,
    telefono         VARCHAR(25),
    email            VARCHAR(150),
    fecha_nacimiento DATE         NOT NULL,
    id_obra_social   INT          REFERENCES obra_social(id_obra_social),
    nro_afiliado     VARCHAR(30)
);

CREATE TABLE tipo_turno (
    id_tipo_turno SERIAL      PRIMARY KEY,
    descripcion   VARCHAR(50) NOT NULL
);

CREATE TABLE turno (
    id_turno       SERIAL      PRIMARY KEY,
    id_paciente    INT         NOT NULL REFERENCES paciente(id_paciente),
    id_medico      INT         NOT NULL REFERENCES medico(id_medico),
    id_tipo_turno  INT         NOT NULL REFERENCES tipo_turno(id_tipo_turno),
    id_consultorio INT         REFERENCES consultorio(id_consultorio),
    fecha_hora     TIMESTAMP   NOT NULL,
    estado         VARCHAR(20) NOT NULL DEFAULT 'pendiente'
                               CHECK (estado IN ('pendiente', 'confirmado', 'cancelado', 'realizado')),
    origen         VARCHAR(50) NOT NULL DEFAULT 'Telegram'
);

CREATE TABLE estudio_laboratorio (
    id_estudio SERIAL       PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL
);

CREATE TABLE turno_laboratorio (
    id_turno_lab SERIAL PRIMARY KEY,
    id_turno     INT    NOT NULL REFERENCES turno(id_turno),
    id_estudio   INT    NOT NULL REFERENCES estudio_laboratorio(id_estudio),
    UNIQUE (id_turno, id_estudio)
);

CREATE TABLE licencia (
    id_licencia      SERIAL       PRIMARY KEY,
    tipo             VARCHAR(100) NOT NULL,
    descripcion      TEXT,
    dias_disponibles INT          NOT NULL CHECK (dias_disponibles > 0)
);

CREATE TABLE personal_licencia (
    id_personal_licencia SERIAL      PRIMARY KEY,
    id_personal          INT         NOT NULL REFERENCES personal(id_personal),
    id_licencia          INT         NOT NULL REFERENCES licencia(id_licencia),
    fecha_inicio         DATE        NOT NULL,
    fecha_fin            DATE        NOT NULL,
    estado               VARCHAR(20) NOT NULL DEFAULT 'activa'
                                     CHECK (estado IN ('activa', 'finalizada', 'cancelada')),
    CHECK (fecha_fin >= fecha_inicio)
);

CREATE TABLE ticket (
    id_ticket      SERIAL      PRIMARY KEY,
    id_solicitante INT         NOT NULL REFERENCES personal(id_personal),
    id_asignado    INT         REFERENCES personal(id_personal),
    tipo           VARCHAR(20) NOT NULL CHECK (tipo IN ('queja', 'insumo', 'equipamiento')),
    descripcion    TEXT        NOT NULL,
    fecha_creacion TIMESTAMP   NOT NULL DEFAULT NOW(),
    estado         VARCHAR(20) NOT NULL DEFAULT 'abierto'
                               CHECK (estado IN ('abierto', 'en_progreso', 'cerrado'))
);

CREATE TABLE horario_base (
    id_horario         SERIAL   PRIMARY KEY,
    id_medico          INT      REFERENCES medico(id_medico),
    es_laboratorio     BOOLEAN  NOT NULL DEFAULT FALSE,
    dia_semana         SMALLINT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio        TIME     NOT NULL,
    hora_fin           TIME     NOT NULL,
    duracion_turno_min INT      NOT NULL CHECK (duracion_turno_min > 0),
    CHECK (hora_fin > hora_inicio),
    -- Exactamente uno de los dos debe estar activo
    CHECK (
        (id_medico IS NOT NULL AND es_laboratorio = FALSE) OR
        (id_medico IS NULL     AND es_laboratorio = TRUE)
    )
);

CREATE TABLE medicamento (
    id_medicamento   SERIAL       PRIMARY KEY,
    nombre_comercial VARCHAR(150) NOT NULL,
    nombre_generico  VARCHAR(150) NOT NULL,
    presentacion     VARCHAR(100) NOT NULL
);

CREATE TABLE receta (
    id_receta      SERIAL    PRIMARY KEY,
    id_turno       INT       NOT NULL UNIQUE REFERENCES turno(id_turno),
    fecha_emision  TIMESTAMP NOT NULL DEFAULT NOW(),
    observaciones  TEXT
);

CREATE TABLE receta_medicamento (
    id_receta_medicamento SERIAL       PRIMARY KEY,
    id_receta             INT          NOT NULL REFERENCES receta(id_receta),
    id_medicamento        INT          NOT NULL REFERENCES medicamento(id_medicamento),
    dosis                 VARCHAR(100) NOT NULL,
    frecuencia            VARCHAR(100) NOT NULL,
    duracion              VARCHAR(100),
    indicaciones          TEXT,
    UNIQUE (id_receta, id_medicamento)
);

CREATE TABLE bloqueo_agenda (
    id_bloqueo           SERIAL       PRIMARY KEY,
    id_medico            INT          REFERENCES medico(id_medico),
    es_laboratorio       BOOLEAN      NOT NULL DEFAULT FALSE,
    fecha_inicio         TIMESTAMP    NOT NULL,
    fecha_fin            TIMESTAMP    NOT NULL,
    motivo               VARCHAR(100) NOT NULL,
    id_personal_licencia INT          REFERENCES personal_licencia(id_personal_licencia),
    CHECK (fecha_fin > fecha_inicio),
    CHECK (
        (id_medico IS NOT NULL AND es_laboratorio = FALSE) OR
        (id_medico IS NULL     AND es_laboratorio = TRUE)
    )
);


-- ============================================================
--  DML — Datos iniciales
-- ============================================================

-- ------------------------------------------------------------
--  AREA
-- ------------------------------------------------------------
INSERT INTO area (nombre) VALUES
    ('Administración'),     -- id 1
    ('Atención de Salud');  -- id 2


-- ------------------------------------------------------------
--  DEPARTAMENTO
-- ------------------------------------------------------------
INSERT INTO departamento (nombre, id_area) VALUES
    ('Recursos Humanos',     1),   -- id 1
    ('Beneficios',           1),   -- id 2
    ('Clínica Médica',       2),   -- id 3
    ('Laboratorio',          2),   -- id 4
    ('Gestión de Pacientes', 2);   -- id 5


-- ------------------------------------------------------------
--  CARGO
-- ------------------------------------------------------------
INSERT INTO cargo (nombre) VALUES
    ('Jefa de Recursos Humanos'),       -- id 1
    ('Asistente de RRHH'),              -- id 2
    ('Jefa de Beneficios'),             -- id 3
    ('Asistente de Beneficios'),        -- id 4
    ('Médico Clínico'),                 -- id 5
    ('Enfermero Jefe'),                 -- id 6
    ('Jefa de Gestión de Pacientes'),   -- id 7
    ('Gestor de Turnos');               -- id 8


-- ------------------------------------------------------------
--  PERSONAL
--  DNIs de médicos y enfermero son ficticios (no figuraban
--  en el documento de personal).
-- ------------------------------------------------------------
INSERT INTO personal (nombre, apellido, dni, telefono, email, fecha_ingreso, id_cargo, id_departamento) VALUES
    ('Marcela Beatriz', 'Fontana',       '28741302', '+5491148237651', 'm.fontana@clinicadelsur.com',  '2018-03-01', 1, 1),  -- id 1
    ('Ignacio',         'Ramírez',       '35128904', '+5491150342198', 'i.ramirez@clinicadelsur.com',  '2021-06-15', 2, 1),  -- id 2
    ('Claudia Noemí',   'Herrera',       '30456712', '+5491147128843', 'c.herrera@clinicadelsur.com',  '2019-01-10', 3, 2),  -- id 3
    ('Tomás Ezequiel',  'Peralta',       '38902567', '+5491161284450', 't.peralta@clinicadelsur.com',  '2022-09-01', 4, 2),  -- id 4
    ('Alejandro Martín','Solís',         '26432891', '+5491149013367', 'a.solis@clinicadelsur.com',    '2016-04-01', 5, 3),  -- id 5
    ('Valentina',       'Cáceres',       '33217560', '+5491152479910', 'v.caceres@clinicadelsur.com',  '2020-02-01', 5, 3),  -- id 6
    ('Rodrigo',         'Fernández Paz', '29875043', '+5491143886725', 'r.fernandez@clinicadelsur.com','2017-11-15', 5, 3),  -- id 7
    ('Lucas Hernán',    'Quiroga',       '36541209', '+5491147561193', 'l.quiroga@clinicadelsur.com',  '2021-03-01', 6, 4),  -- id 8
    ('Sofía Inés',      'Morales',       '32678445', '+5491155638821', 's.morales@clinicadelsur.com',  '2019-07-01', 7, 5),  -- id 9
    ('Emiliano',        'Castro',        '37214980', '+5491148905534', 'e.castro@clinicadelsur.com',   '2022-01-10', 8, 5),  -- id 10
    ('Daniela Luz',     'Vega',          '40103227', '+5491162374401', 'd.vega@clinicadelsur.com',     '2023-05-01', 8, 5);  -- id 11


-- ------------------------------------------------------------
--  MEDICO  (solo los 3 médicos clínicos, no el enfermero)
-- ------------------------------------------------------------
INSERT INTO medico (id_personal, matricula) VALUES
    (5, 'MP 48231'),   -- id 1 — Dr. Solís
    (6, 'MP 51874'),   -- id 2 — Dra. Cáceres
    (7, 'MP 55609');   -- id 3 — Dr. Fernández Paz


-- ------------------------------------------------------------
--  CONSULTORIO
-- ------------------------------------------------------------
INSERT INTO consultorio (nombre) VALUES
    ('Consultorio 1'),   -- id 1
    ('Consultorio 2');   -- id 2


-- ------------------------------------------------------------
--  OBRA_SOCIAL
-- ------------------------------------------------------------
INSERT INTO obra_social (nombre, plan, porcentaje_cobertura) VALUES
    ('OSDE',          'Plan 210',    70.00),   -- id 1
    ('Swiss Medical', 'SMG10',       65.00),   -- id 2
    ('IOMA',          'Plan Básico', 60.00),   -- id 3
    ('Galeno',        'Bronze',      55.00);   -- id 4


-- ------------------------------------------------------------
--  TIPO_TURNO
-- ------------------------------------------------------------
INSERT INTO tipo_turno (descripcion) VALUES
    ('Clínica Médica'),   -- id 1
    ('Laboratorio');      -- id 2


-- ------------------------------------------------------------
--  ESTUDIO_LABORATORIO
-- ------------------------------------------------------------
INSERT INTO estudio_laboratorio (nombre) VALUES
    ('Hemograma'),       -- id 1
    ('Uroanálisis'),     -- id 2
    ('Coproanálisis'),   -- id 3
    ('Perfil Lipídico'); -- id 4


-- ------------------------------------------------------------
--  MEDICAMENTO
-- ------------------------------------------------------------
INSERT INTO medicamento (nombre_comercial, nombre_generico, presentacion) VALUES
    ('Ibuprofeno Luar',    'Ibuprofeno',           'Comprimidos 400 mg'),      -- id 1
    ('Tafirol',            'Paracetamol',           'Comprimidos 500 mg'),      -- id 2
    ('Amoxidal',           'Amoxicilina',           'Cápsulas 500 mg'),         -- id 3
    ('Losacor',            'Losartán',              'Comprimidos 50 mg'),        -- id 4
    ('Atenolol Roux',      'Atenolol',              'Comprimidos 50 mg'),        -- id 5
    ('Omeprazol Cinfa',    'Omeprazol',             'Cápsulas 20 mg'),           -- id 6
    ('Metformina Sandoz',  'Metformina',            'Comprimidos 500 mg'),       -- id 7
    ('Aerius',             'Desloratadina',         'Comprimidos 5 mg'),         -- id 8
    ('Ciprofloxacina MK',  'Ciprofloxacina',        'Comprimidos 500 mg'),       -- id 9
    ('Diclofenac Sodico',  'Diclofenac sódico',     'Ampollas 75 mg/3 ml');     -- id 10


-- ------------------------------------------------------------
--  LICENCIA
-- ------------------------------------------------------------
INSERT INTO licencia (tipo, descripcion, dias_disponibles) VALUES
    ('Día Off',                 'Día libre disponible para el personal',                          1),   -- id 1
    ('Licencia por Enfermedad', 'Licencia médica por enfermedad debidamente justificada',         30),  -- id 2
    ('Vacaciones',              'Período anual de descanso del personal',                         15),  -- id 3
    ('Licencia por Maternidad', 'Licencia para madres por nacimiento o adopción de hijo',         90),  -- id 4
    ('Licencia por Paternidad', 'Licencia para padres por nacimiento o adopción de hijo',         15),  -- id 5
    ('Licencia por Examen',     'Días disponibles para rendir exámenes académicos o de carrera',  2);   -- id 6


-- ------------------------------------------------------------
--  HORARIO_BASE
--
--  Dr. Solís (id_medico 1):
--    Lunes a Viernes | 08:00–13:00 | slots de 20 min
--
--  Dra. Cáceres (id_medico 2):
--    Lunes a Viernes | 14:00–19:00 | slots de 20 min
--
--  Dr. Fernández Paz (id_medico 3) — rotativo:
--    Lun/Mié/Vie 08:00–12:00 | Mar/Jue 14:00–18:00 | slots de 20 min
--
--  Laboratorio:
--    Lunes a Viernes | 07:00–12:00 | slots de 15 min
-- ------------------------------------------------------------

-- Dr. Solís
INSERT INTO horario_base (id_medico, es_laboratorio, dia_semana, hora_inicio, hora_fin, duracion_turno_min) VALUES
    (1, FALSE, 1, '08:00', '13:00', 20),
    (1, FALSE, 2, '08:00', '13:00', 20),
    (1, FALSE, 3, '08:00', '13:00', 20),
    (1, FALSE, 4, '08:00', '13:00', 20),
    (1, FALSE, 5, '08:00', '13:00', 20);

-- Dra. Cáceres
INSERT INTO horario_base (id_medico, es_laboratorio, dia_semana, hora_inicio, hora_fin, duracion_turno_min) VALUES
    (2, FALSE, 1, '14:00', '19:00', 20),
    (2, FALSE, 2, '14:00', '19:00', 20),
    (2, FALSE, 3, '14:00', '19:00', 20),
    (2, FALSE, 4, '14:00', '19:00', 20),
    (2, FALSE, 5, '14:00', '19:00', 20);

-- Dr. Fernández Paz (rotativo)
INSERT INTO horario_base (id_medico, es_laboratorio, dia_semana, hora_inicio, hora_fin, duracion_turno_min) VALUES
    (3, FALSE, 1, '08:00', '12:00', 20),
    (3, FALSE, 2, '14:00', '18:00', 20),
    (3, FALSE, 3, '08:00', '12:00', 20),
    (3, FALSE, 4, '14:00', '18:00', 20),
    (3, FALSE, 5, '08:00', '12:00', 20);

-- Laboratorio
INSERT INTO horario_base (id_medico, es_laboratorio, dia_semana, hora_inicio, hora_fin, duracion_turno_min) VALUES
    (NULL, TRUE, 1, '07:00', '12:00', 15),
    (NULL, TRUE, 2, '07:00', '12:00', 15),
    (NULL, TRUE, 3, '07:00', '12:00', 15),
    (NULL, TRUE, 4, '07:00', '12:00', 15),
    (NULL, TRUE, 5, '07:00', '12:00', 15);
