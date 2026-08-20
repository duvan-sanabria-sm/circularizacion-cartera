# Avances y estado

[Volver a la documentación principal](../../README.md)

## Migración y despliegue

- Se creó el proyecto en Azure DevOps.
- Se conectó el repositorio.
- Se instaló la extensión de UiPath para Azure DevOps.
- Se configuró una conexión de servicio de UiPath.
- Se creó el pipeline de empaquetado y despliegue.
- El pipeline usa un agente self-hosted del pool `Default`.
- Se implementó un script para crear/resolver folders e importar activos en Orchestrator.

## Revisión técnica del robot

- Se documentó el objetivo, entradas, transformaciones, salidas y dependencias.
- Se identificó que la lógica principal permanece deshabilitada con `Comment Out`.
- Se identificó que la condición de éxito exterior no puede cumplirse en el flujo activo.
- Se registraron riesgos de rutas locales, destinatarios de prueba, capturas de excepciones vacías y cierre global de Excel.
- Se agregó una validación estática ejecutable desde PowerShell.

## Pendiente antes de producción

- Confirmar la ruta compartida oficial.
- Modularizar y habilitar progresivamente el flujo completo.
- Externalizar configuración y eliminar valores de desarrollo.
- Validar la plantilla, los activos VBA y las conexiones de NetSuite/Microsoft 365.
- Ejecutar pruebas de generación sin correo, correo controlado y prueba integral.
- Definir evidencias, monitoreo, soporte y procedimiento de reversa.
