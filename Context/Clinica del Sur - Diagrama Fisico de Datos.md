# Clínica del Sur - Diagrama Físico de Datos

## Diagrama

```mermaid
erDiagram

    AREA {
        INT id_area PK
        VARCHAR(100) nombre
    }

    DEPARTAMENTO {
        INT id_departamento PK
        VARCHAR(100) nombre
        INT id_area FK
    }

    CARGO {
        INT id_cargo PK
        VARCHAR(100) nombre
    }

    PERSONAL {
        INT id_personal PK
        VARCHAR(100) nombre
        VARCHAR(100) apellido
        VARCHAR(15) dni
        VARCHAR(25) telefono
        VARCHAR(150) email
        DATE fecha_ingreso
        INT id_cargo FK
        INT id_departamento FK
    }

    MEDICO {
        INT id_medico PK
        INT id_personal FK
        VARCHAR(20) matricula
    }

    CONSULTORIO {
        INT id_consultorio PK
        VARCHAR(50) nombre
    }

    OBRA_SOCIAL {
        INT id_obra_social PK
        VARCHAR(100) nombre
        VARCHAR(100) plan
        DECIMAL porcentaje_cobertura
    }

    PACIENTE {
        INT id_paciente PK
        VARCHAR(100) nombre
        VARCHAR(100) apellido
        VARCHAR(15) dni
        VARCHAR(25) telefono
        VARCHAR(150) email
        DATE fecha_nacimiento
        INT id_obra_social FK "NULL si no posee"
        VARCHAR(30) nro_afiliado "NULL si no posee"
    }

    TIPO_TURNO {
        INT id_tipo_turno PK
        VARCHAR(50) descripcion
    }

    TURNO {
        INT id_turno PK
        INT id_paciente FK
        INT id_medico FK
        INT id_tipo_turno FK
        INT id_consultorio FK "NULL para turnos de lab"
        DATETIME fecha_hora
        VARCHAR(20) estado
        VARCHAR(50) origen "Ej: Telegram"
    }

    ESTUDIO_LABORATORIO {
        INT id_estudio PK
        VARCHAR(100) nombre
    }

    TURNO_LABORATORIO {
        INT id_turno_lab PK
        INT id_turno FK
        INT id_estudio FK
    }

    LICENCIA {
        INT id_licencia PK
        VARCHAR(100) tipo
        TEXT descripcion
        INT dias_disponibles
    }

    PERSONAL_LICENCIA {
        INT id_personal_licencia PK
        INT id_personal FK
        INT id_licencia FK
        DATE fecha_inicio
        DATE fecha_fin
        VARCHAR(20) estado
    }

    TICKET {
        INT id_ticket PK
        INT id_solicitante FK
        INT id_asignado FK
        VARCHAR(20) tipo "queja | insumo | equipamiento"
        TEXT descripcion
        DATETIME fecha_creacion
        VARCHAR(20) estado
    }

    HORARIO_BASE {
        INT id_horario PK
        INT id_medico FK "NULL si es laboratorio"
        BOOLEAN es_laboratorio
        TINYINT dia_semana "1=Lunes ... 7=Domingo"
        TIME hora_inicio
        TIME hora_fin
        INT duracion_turno_min
    }

    BLOQUEO_AGENDA {
        INT id_bloqueo PK
        INT id_medico FK "NULL si es laboratorio"
        BOOLEAN es_laboratorio
        DATETIME fecha_inicio
        DATETIME fecha_fin
        VARCHAR(100) motivo "Feriado | Licencia | Ausencia"
        INT id_personal_licencia FK "NULL si no deriva de licencia"
    }

    MEDICAMENTO {
        INT id_medicamento PK
        VARCHAR(150) nombre_comercial
        VARCHAR(150) nombre_generico
        VARCHAR(100) presentacion
    }

    RECETA {
        INT id_receta PK
        INT id_turno FK
        DATETIME fecha_emision
        TEXT observaciones
    }

    RECETA_MEDICAMENTO {
        INT id_receta_medicamento PK
        INT id_receta FK
        INT id_medicamento FK
        VARCHAR(100) dosis
        VARCHAR(100) frecuencia
        VARCHAR(100) duracion
        TEXT indicaciones
    }

    AREA ||--o{ DEPARTAMENTO : "contiene"
    DEPARTAMENTO ||--o{ PERSONAL : "emplea"
    CARGO ||--o{ PERSONAL : "define"
    PERSONAL ||--o| MEDICO : "especializa"
    MEDICO ||--o{ TURNO : "atiende"
    PACIENTE ||--o{ TURNO : "solicita"
    TIPO_TURNO ||--o{ TURNO : "clasifica"
    CONSULTORIO ||--o{ TURNO : "aloja"
    TURNO ||--o| TURNO_LABORATORIO : "genera"
    ESTUDIO_LABORATORIO ||--o{ TURNO_LABORATORIO : "incluye"
    LICENCIA ||--o{ PERSONAL_LICENCIA : "asignada en"
    PERSONAL ||--o{ PERSONAL_LICENCIA : "tiene"
    PERSONAL ||--o{ TICKET : "solicita"
    PERSONAL ||--o{ TICKET : "gestiona"
    OBRA_SOCIAL ||--o{ PACIENTE : "cubre"
    MEDICO ||--o{ HORARIO_BASE : "define disponibilidad"
    MEDICO ||--o{ BLOQUEO_AGENDA : "tiene bloqueo"
    PERSONAL_LICENCIA ||--o{ BLOQUEO_AGENDA : "origina"
    TURNO ||--o| RECETA : "genera"
    RECETA ||--o{ RECETA_MEDICAMENTO : "detalla"
    MEDICAMENTO ||--o{ RECETA_MEDICAMENTO : "incluido en"
```

---

## Descripción de Tablas

### `AREA`
Representa las dos grandes áreas de la clínica: *Administración* y *Atención de Salud*.

### `DEPARTAMENTO`
Cada área contiene departamentos. Pertenece a un `AREA`.

### `CARGO`
Catálogo de los cargos disponibles en la clínica (Médico Clínico, Enfermero Jefe, Gestor de Turnos, etc.).

### `PERSONAL`
Almacena a todos los empleados de la clínica. Referencia su cargo (`CARGO`) y su departamento (`DEPARTAMENTO`).

### `MEDICO`
Extensión de `PERSONAL` exclusiva para médicos clínicos. Contiene la matrícula profesional. Solo el personal con cargo médico tendrá registro en esta tabla.

### `CONSULTORIO`
Los consultorios físicos disponibles para la atención clínica (Consultorio 1 y Consultorio 2).

### `OBRA_SOCIAL`
Catálogo de obras sociales aceptadas por la clínica. Incluye el nombre, el plan y el porcentaje de cobertura, lo que permite calcular el costo final del turno según si el paciente posee cobertura o no.

### `PACIENTE`
Personas que solicitan o tienen turnos agendados en la clínica. El campo `id_obra_social` es nullable: si el paciente no posee obra social ambos campos quedan en NULL y el turno se factura a precio de lista completo.

### `TIPO_TURNO`
Catálogo de tipos de turno: *Clínica Médica* o *Laboratorio*.

### `TURNO`
Registro centralizado de todos los turnos agendados. El campo `id_consultorio` es NULL cuando el turno es de Laboratorio. El campo `origen` indica el canal por el que fue agendado (ej: Telegram). Los turnos de Laboratorio solo pueden ser expedidos por un médico de la clínica, por lo que `id_medico` siempre es obligatorio.

### `ESTUDIO_LABORATORIO`
Catálogo de los estudios que realiza el laboratorio: Hemograma, Uroanálisis, Coproanálisis y Perfil Lipídico.

### `TURNO_LABORATORIO`
Relaciona un turno de tipo Laboratorio con el/los estudio(s) solicitado(s).

### `LICENCIA`
Catálogo de tipos de licencias disponibles para el personal (días off, licencia por enfermedad, etc.), gestionado por el Departamento de Beneficios.

### `PERSONAL_LICENCIA`
Registro de licencias asignadas a cada empleado, con sus fechas y estado.

### `TICKET`
Tickets de gestión interna creados por el personal y administrados por el Departamento de RRHH. Puede referirse a una queja, solicitud de insumos o de equipamiento. Contiene dos FK a `PERSONAL`: el solicitante y el empleado de RRHH asignado.

### `MEDICAMENTO`
Catálogo de medicamentos prescribibles. Almacena nombre comercial, nombre genérico y presentación (comprimidos, jarabe, inyectable, etc.).

### `RECETA`
Receta médica emitida durante un turno formal. Al vincularse al `TURNO` queda trazabilidad completa del médico que la emitió y el paciente que la recibió. Un turno puede generar como máximo una receta.

### `RECETA_MEDICAMENTO`
Detalle de los medicamentos incluidos en una receta. Cada fila representa un medicamento prescripto con su dosis, frecuencia, duración del tratamiento e indicaciones adicionales.

### `HORARIO_BASE`
Define el esquema semanal recurrente de disponibilidad de cada médico o del laboratorio. Indica qué días de la semana trabaja, en qué franja horaria y cuánto dura cada slot de turno. Con esta información el sistema calcula dinámicamente los slots disponibles para cualquier fecha futura sin necesidad de pre-generarlos.

### `BLOQUEO_AGENDA`
Registra excepciones al horario base: feriados, vacaciones, ausencias puntuales, etc. Si el bloqueo deriva de una licencia formal registrada en `PERSONAL_LICENCIA`, se vincula mediante `id_personal_licencia` para mantener consistencia. Al agendar un turno, el sistema cruza el `HORARIO_BASE`, los `BLOQUEO_AGENDA` vigentes y los `TURNO` ya reservados para determinar si el slot solicitado está disponible.
