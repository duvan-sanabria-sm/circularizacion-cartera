# Requerimientos del proceso

[Volver a la documentación principal](../../README.md)

## RF-01 — Descargar reportes de NetSuite

El robot debe descargar los reportes de cartera, proformas y datos de clientes requeridos para la circularización. Si falta uno de los archivos obligatorios, debe detener el procesamiento y registrar el motivo.

## RF-02 — Preparar la información de cartera

El robot debe conservar los documentos con saldo pendiente, ordenar la información y agrupar facturas y proformas por cliente. Los nombres de columnas esperados deben validarse antes de procesar.

## RF-03 — Generar estados de cuenta

Para cada cliente con datos válidos, el robot debe copiar la plantilla, escribir la información en la hoja `ESTADO CUENTA`, calcular totales y aplicar el formato definido.

## RF-04 — Enviar la circularización

El robot debe enviar cada estado de cuenta únicamente al correo validado del cliente. Las copias, el remitente y los destinatarios de prueba deben administrarse mediante configuración, no mediante valores codificados en el workflow.

## RF-05 — Registrar el resultado

Cada ejecución debe registrar inicio, fin, fecha de corte, archivos descargados, clientes procesados, correos enviados y errores. Un error recuperable puede reintentarse; un error no recuperable debe propagarse con contexto.

## RF-06 — Limpiar archivos temporales

El robot debe eliminar solo los archivos y carpetas creados por la ejecución actual. Antes de una eliminación recursiva debe validar que la ruta se encuentre dentro de la carpeta de trabajo configurada.

## RF-07 — Desplegar mediante pipeline

El proyecto debe empaquetarse y desplegarse mediante Azure DevOps al folder configurado en `UIPATH_FOLDER_PATH`. Los activos requeridos deben existir o crearse en Orchestrator sin exponer secretos.

## Requerimientos no funcionales

- La configuración debe ser portable entre desarrollo, pruebas y producción.
- Las credenciales y secretos no deben almacenarse en Git ni registrarse en logs.
- El proceso debe poder ejecutarse en una máquina robot dedicada con Excel y Chrome.
- Los workflows deben dividirse por responsabilidad y usar argumentos explícitos.
- Los mensajes interactivos deben evitarse en ejecución no atendida.
- Debe existir una prueba controlada sin envío y otra con un único destinatario antes de producción.

## Criterios mínimos de aceptación

1. Los tres reportes se descargan y validan.
2. La cantidad de clientes de entrada se reconcilia con procesados, omitidos y fallidos.
3. Cada archivo generado abre sin errores y contiene el cliente correcto.
4. Los totales coinciden con los reportes fuente.
5. Ningún correo se envía a direcciones codificadas de desarrollo.
6. Un fallo produce un log accionable y un estado fallido en Orchestrator.
