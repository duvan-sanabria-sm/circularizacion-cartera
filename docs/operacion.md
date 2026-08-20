# Configuración, operación y soporte

[Volver a la documentación principal](../README.md)

## Requisitos de ejecución

- Windows y UiPath Robot compatible con el proyecto Windows.
- Dependencias restauradas desde `project.json`.
- Microsoft Excel y Google Chrome instalados.
- Extensión de UiPath habilitada en Chrome.
- Acceso autenticado a NetSuite.
- Acceso a Microsoft 365 y al buzón configurado.
- Permisos de lectura, escritura, creación y eliminación en la carpeta compartida.
- Acceso al folder de Orchestrator `Servimeters/Comercio/Cartera`.

## Configuración actual encontrada

| Elemento | Valor o ubicación | Observación |
|---|---|---|
| Carpeta base del XAML | `\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\` | Está codificada en `Main.xaml`. |
| Carpeta de clientes | `\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\cliente\` | Está codificada en `Main.xaml`. |
| Plantilla | `PLANTILLA ESTADO DE CUENTA SM.xlsx` | Debe existir en la carpeta base. |
| Folder de Orchestrator | `Servimeters/Comercio/Cartera` | Está codificado en las actividades `Get Asset`. |
| Activo VBA utilizado | `Ruta VBA limpieza plantilla` | Su valor esperado es `vba\ModifiyExcelFormat.vb`. |
| Macro utilizada | `FormatStatementReport` | Recibe la hoja `ESTADO CUENTA`. |
| Cuenta funcional | `analista.creditoycartera@servimeters.com` | Aparece en las conexiones de Microsoft 365. |

La documentación anterior mencionaba `\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\`. Esa ruta no coincide con las variables activas del XAML y debe confirmarse con el dueño del proceso antes de producción.

## Variables del pipeline

| Variable | Uso |
|---|---|
| `UIPATH_ORG` | Nombre de la organización de UiPath Automation Cloud. |
| `UIPATH_TENANT` | Tenant de destino. |
| `UIPATH_CLIENT_ID` | Identificador de la External Application. |
| `UIPATH_CLIENT_SECRET` | Secreto; debe almacenarse como variable secreta. |
| `UIPATH_FOLDER_PATH` | Ruta completa del folder de Orchestrator. |

El pipeline empaqueta el proyecto, valida `UIPATH_FOLDER_PATH`, crea o resuelve la jerarquía, importa activos y despliega el paquete.

## Ejecución controlada

1. Ejecutar `.\tools\validate-project.ps1` y revisar todas las advertencias.
2. Confirmar que la plantilla y los archivos VBA existen en las rutas configuradas.
3. Verificar que no haya libros de Excel de otros usuarios abiertos en la máquina robot.
4. Confirmar que los destinatarios no sean direcciones de prueba.
5. Ejecutar primero en un folder y buzón de pruebas.
6. Revisar los archivos descargados, el número de clientes y los adjuntos generados.
7. Habilitar el flujo completo únicamente después de una prueba supervisada y aprobación funcional.

## Evidencias recomendadas por ejecución

- Hora de inicio y fin.
- Nombres de los reportes descargados.
- Fecha de corte calculada.
- Cantidad de clientes procesados, omitidos y fallidos.
- Cantidad de correos enviados.
- Ruta de salida de los estados de cuenta.
- Excepción completa y cliente afectado cuando haya error.

## Recuperación ante fallos

- Si falla una descarga, comprobar sesión, selectores y permisos de Chrome.
- Si falla Excel, cerrar únicamente los procesos del usuario robot y verificar que la plantilla no esté bloqueada.
- Si falla una macro, validar el valor del activo y que el método exista en el archivo VBA.
- Si falla el correo, revisar la conexión de Microsoft 365 y conservar el archivo generado para reintento.
- Si la carpeta de la fecha ya existe, respaldar su contenido antes de permitir que el flujo la elimine y recree.

