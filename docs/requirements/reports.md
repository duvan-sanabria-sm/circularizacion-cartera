# Reportes y salidas

[Volver a la documentación principal](../../README.md)

## Reportes de entrada

| Reporte | Origen | Uso |
|---|---|---|
| Cartera | NetSuite, búsqueda `searchid=2010` | Facturas, saldos y datos para circularización. |
| Proformas | NetSuite, Suitelet `script=496&deploy=1` | Documentos en estado de proforma. |
| Clientes y correos | NetSuite, búsqueda `searchid=2011` | Nombre, NIT y correo asociado al cliente. |

Los nombres exactos de los archivos descargados se obtienen en tiempo de ejecución y luego se mueven a la carpeta base.

## Salidas previstas

- Carpeta de ejecución identificada por fecha.
- Archivo Excel por cliente, nombrado a partir del cliente después de retirar caracteres inválidos.
- Hoja `ESTADO CUENTA` con facturas y proformas.
- Fila de total de cartera pendiente, calculada por VBA.
- Correo con el estado de cuenta adjunto.
- Notificación de terminación del proceso.

## Estado actual

La generación de archivos, el formato VBA y el envío de correos están deshabilitados dentro de `Comment Out`. En el estado actual solo se esperan como salidas los reportes descargados/movidos y la carpeta de trabajo, pero la ejecución termina fallando la condición final del reintento.
