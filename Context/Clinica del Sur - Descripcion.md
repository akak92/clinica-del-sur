“Clínica del Sur” es un centro de salud privado que está compuesto por dos áreas. Por un lado se encuentra el Área de Administración y por otro lado se encuentra el Área de Atención de Salud..

El Área de Administración está compuesto por dos Departamentos:

* Departamento de Recursos Humanos: Se encarga de las contrataciones de nuevo personal, recepción de quejas y gestión de tickets relacionados a los insumos y al equipamiento de la Clínica.  
* Departamento de Beneficios: Se ocupa de mantener actualizados los beneficios disponibles para el personal que trabaja en la clínica (días off, tipos de licencias, etc)

El Área de Atención de Salud es un poco más complejo y extenso, contando a día de hoy con tres departamentos

* Departamento de Clínica Médica  
  * Actualmente cuenta con 3 médicos clínicos  
  * El departamento cuenta con dos Salas de Atención Clínica (Consultorio 1 y Consultorio 2\)  
* Laboratorio  
  * Actualmente el Laboratorio realiza únicamente los siguientes estudios:  
    * Hemograma  
    * Uroanálisis  
    * Coproanálisis  
    * Perfil Lipídico  
  * El Laboratorio cuenta con un Enfermero Jefe encargado de realizar las extracciones sanguíneas o recibir las muestras de orina y/o materia fecal.  
* Departamento de Gestión de Pacientes  
  * Actualmente es el encargado de brindar atención a los pacientes (o potenciales pacientes) agendando turnos con los médicos con los que cuenta la clínica y/o también turnos de Laboratorio  
    * Los pacientes solicitan turnos directamente a través de **Astrid**, el agente externo de la clínica disponible vía Telegram. Astrid puede registrar nuevos pacientes y agendar turnos de forma autónoma.  
    * El personal del departamento gestiona y supervisa los turnos a través del **Agente Interno**, también disponible vía Telegram.  
    * Todos los turnos quedan registrados en la Base de Datos de la Clínica.

Aclaraciones Importantes

* Los turnos de Laboratorio pueden ser expedidos exclusivamente por los médicos que trabajan en la clínica.

## Sistema de Automatización

La clínica cuenta con dos agentes de inteligencia artificial (Openclaw) integrados a la Base de Datos, ambos operando vía Telegram:

* **Astrid (Agente Externo):** Atiende a pacientes y potenciales pacientes. Puede registrar nuevos pacientes, consultar disponibilidad y agendar o cancelar turnos de forma autónoma. Su tono es cordial y colaborativo.
* **Agente Interno:** Atiende al personal de la clínica. Cada empleado accede a funcionalidades según su rol (médico, enfermero, gestor de turnos, RRHH, beneficios). Entre sus funciones se incluyen: consulta de agenda, reporte de ausencias, solicitud de licencias y gestión de tickets.

## Otros Aspectos del Sistema

* **Recetas médicas:** Los médicos pueden emitir recetas durante un turno formal. Cada receta queda registrada en la base de datos vinculada al turno, al paciente y al médico, junto con el detalle de los medicamentos prescriptos.
* **Obra social:** Los pacientes pueden tener asociada una obra social. El sistema registra el plan y el porcentaje de cobertura, lo que permite determinar el costo del turno según la cobertura disponible.
* **Disponibilidad de agenda:** Cada médico y el laboratorio cuentan con un horario base semanal registrado en el sistema. Las ausencias, licencias y feriados se gestionan como bloqueos de agenda, permitiendo calcular la disponibilidad real en tiempo real al momento de agendar un turno.