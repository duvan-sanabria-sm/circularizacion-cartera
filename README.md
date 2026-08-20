# Robot de Circularización de Cartera

Automatización UiPath que obtiene información de cartera desde NetSuite y prepara estados de cuenta por cliente. El proyecto está configurado como proceso Windows, con ejecución no atendida pero con interacción de interfaz de usuario.

> Estado revisado el 13 de agosto de 2026: el procesamiento completo y el envío de correos están dentro de una actividad `Comment Out` en `Main.xaml`. La ruta activa descarga y mueve los reportes, crea la carpeta de ejecución y calcula la fecha de corte; después, la condición final del `Retry Scope` no puede cumplirse porque `isFinish = True` permanece en el bloque deshabilitado. No debe considerarse listo para producción hasta resolver los puntos críticos de la auditoría.

## Documentación

- [Descripción funcional y flujo actual](docs/descripcion-funcional.md)
- [Configuración, operación y soporte](docs/operacion.md)
- [Auditoría técnica y mejoras recomendadas](docs/auditoria-tecnica.md)
- [Documentos y rutas utilizados](docs/requirements/usage_documents.md)
- [Reportes y salidas](docs/requirements/reports.md)
- [Requerimientos](docs/requirements/01_requerimientos.md)
- [Avances de migración](docs/requirements/advances.md)
- [Ejecución del pipeline](docs/pipeline/ejecucion-pipeline.md)

## Componentes principales

| Componente | Propósito |
|---|---|
| `Main.xaml` | Punto de entrada y orquestación del proceso. |
| `Recoleccion de Informacion.uiform` | Formulario UiPath; actualmente solo contiene el botón de envío. |
| `vba/ModifiyExcelFormat.vb` | Macro `FormatStatementReport` para dar formato al estado de cuenta. |
| `orchestrator/assets/assets.json` | Definición exportada de activos de Orchestrator. |
| `orchestrator/scripts/import-assets.ps1` | Creación de la jerarquía de carpetas e importación de activos. |
| `azure-pipelines.yml` | Empaquetado, preparación de Orchestrator y despliegue. |
| `tools/validate-project.ps1` | Validación estática de portabilidad y consistencia. |

## Validación rápida

Desde PowerShell, en la raíz del proyecto:

```powershell
.\tools\validate-project.ps1
```

La validación no ejecuta NetSuite, Excel, Outlook ni Orchestrator; revisa la estructura y alerta sobre riesgos conocidos.
