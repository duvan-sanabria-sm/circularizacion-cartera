# Documentos y rutas utilizados

[Volver a la documentación principal](../../README.md)

## Configuración encontrada en el XAML

### Carpeta base

`\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\`

Recibe los reportes descargados y contiene la plantilla base.

### Carpeta de estados de cuenta por cliente

`\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\cliente\`

El flujo previsto crea debajo una carpeta por fecha de ejecución y genera allí un archivo `.xlsx` por cliente.

### Plantilla

`\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\PLANTILLA ESTADO DE CUENTA SM.xlsx`

La hoja utilizada por el robot se llama `ESTADO CUENTA`. La escritura de facturas comienza en la fila 8.

### Archivo VBA

`vba\ModifiyExcelFormat.vb`

Orchestrator lo expone mediante el activo `Ruta VBA limpieza plantilla`. Contiene el método `FormatStatementReport`, que agrega el total y aplica formato al estado de cuenta.

## Discrepancia pendiente

La documentación histórica registraba la ruta `\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\`. No coincide con las variables de `Main.xaml`. El dueño funcional debe confirmar cuál es la ruta oficial y luego debe existir una sola fuente de configuración.

## Requisitos de acceso

- Lectura y escritura sobre la carpeta base y `cliente`.
- Permiso para crear y eliminar carpetas de ejecución.
- Permiso para copiar y modificar la plantilla.
- La plantilla no debe estar abierta ni bloqueada durante la ejecución.
