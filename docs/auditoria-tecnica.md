# Auditoría técnica

[Volver a la documentación principal](../README.md)

Revisión estática realizada el 13 de agosto de 2026. No se ejecutaron NetSuite, Excel, Microsoft 365 ni Orchestrator.

## Hallazgos críticos

| Prioridad | Hallazgo | Impacto | Acción recomendada |
|---|---|---|---|
| Crítica | El flujo funcional principal está dentro de `Comment Out`. | No se generan estados de cuenta ni se envían correos. | Revisar el bloque en Studio, retirar actividades de prueba y habilitarlo por etapas. |
| Crítica | `isFinish = True` está dentro del bloque deshabilitado. | El `Retry Scope` exterior no puede finalizar correctamente. | Definir una condición de éxito en el flujo activo o reubicar la asignación tras todas las validaciones. |
| Alta | Existen destinatarios de prueba codificados en el XAML. | Riesgo de fuga de información o envío al destinatario equivocado. | Usar el correo validado del cliente y activos/configuración para copias y notificaciones. |
| Alta | Hay rutas `C:\Users\duvan.sanabria\...` en actividades de prueba. | El paquete no es portable a la máquina robot. | Eliminar el bloque obsoleto o reemplazar rutas por configuración y rutas relativas. |
| Alta | Hay `Catch` vacíos. | Se ocultan errores y se dificulta el soporte. | Registrar contexto y relanzar la excepción cuando no pueda recuperarse. |
| Alta | Se usa `Kill Process` sobre todos los procesos de Excel. | Puede cerrar trabajo ajeno. | Ejecutar en máquina dedicada o cerrar solo la instancia creada por el robot. |

## Hallazgos medios

- El proyecto declara `isAttended: false`, `requiresUserInteraction: true` y contiene `Message Box`; la ejecución no atendida puede quedar bloqueada.
- Los tiempos de espera de descarga de 1 a 1,5 segundos son frágiles para red y archivos grandes.
- `Main.xaml` concentra toda la lógica y supera ampliamente un tamaño mantenible; conviene dividirlo en workflows con argumentos explícitos.
- Las URLs de NetSuite, rutas compartidas, folder de Orchestrator y cuenta de correo están codificados en el workflow.
- `Recoleccion de Informacion.uiform` solo contiene un botón y no recolecta información.
- El activo `Ruta VBA Formato Excel` apunta a `vba\FormatExcel.vb`, archivo que no existe en el repositorio; su uso está a su vez deshabilitado.
- La ruta histórica de los documentos no coincide con la ruta configurada en el XAML.

## Mejoras implementadas en esta revisión

- Documentación funcional del comportamiento activo y del comportamiento previsto.
- Guía de configuración, operación, soporte y evidencias.
- Inventario de riesgos con prioridades.
- Validador estático reutilizable en `tools/validate-project.ps1`.
- Descripción corregida en `project.json`.
- Exclusión de artefactos generados de UiPath en `.gitignore`.

## Plan recomendado de estabilización

1. Crear una copia o rama de estabilización y abrir `Main.xaml` en UiPath Studio.
2. Extraer workflows: `DownloadReports.xaml`, `PrepareReports.xaml`, `BuildStatement.xaml`, `SendStatement.xaml` y `Cleanup.xaml`.
3. Mover rutas, URLs, buzones, destinatarios y folder de Orchestrator a configuración.
4. Sustituir cuadros de mensaje por logs y excepciones controladas.
5. Probar generación de archivos con envío deshabilitado.
6. Probar correo con un único destinatario controlado.
7. Ejecutar una prueba integral con datos acotados y reconciliar cantidades.
8. Habilitar producción con monitoreo y procedimiento de reversa.

