# Casos de Error - Circularizacion de Cartera

Fecha de documentacion consolidada: 2026-08-20

## Identificacion

- Proceso UiPath: `Circularizacion-cartera`.
- Fuentes analizadas:
  - `robot-logs-2026-08-20-15-41-06-420-237405.csv`.
  - `robot-logs-2026-08-20-15-42-09-320-237406.csv`.
- Nota sobre fuentes: los dos CSV adjuntos tienen el mismo hash SHA256, por lo que contienen la misma informacion y se analizan como una sola fuente efectiva.
- Periodo cubierto por el log: del `2026-08-12 12:00:10` al `2026-08-20 12:50:54`.
- Total de registros del log: 33.
- Eventos informativos: 20.
- Advertencias: 4.
- Errores: 9.
- Host principal observado: `BOGTI011`.
- Usuarios/robots observados:
  - `duvan.sanabria-unattended`.
  - `duvan.sanabriam@gmail.com-attended`.

## Objetivo

Documentar los errores observados durante las ejecuciones del robot, separando cada caso por etapa del flujo para facilitar diagnostico, priorizacion y correccion.

Este documento complementa el `README.md` y la auditoria tecnica existente. No reemplaza las reglas funcionales del proceso; se enfoca en fallas tecnicas, sintomas visibles en UiPath y acciones recomendadas.

## Resumen ejecutivo

| Caso | Cantidad en log | Etapa | Impacto |
|---|---:|---|---|
| Selector `login-submit` no encontrado | 4 | Login / sesion NetSuite en Chrome | Puede retrasar o impedir la descarga de reportes desde NetSuite |
| Nombre de `Reporte de Proformas` registrado como error | 6 | Descarga y traslado de reportes | Genera ruido operacional; no necesariamente indica una excepcion real |
| `Retry Scope: Error en el flujo` | 3 | Cierre del `Retry Scope` exterior | Hace que la ejecucion termine como fallida aunque haya completado parte del flujo activo |

## Orden recomendado de atencion

1. Corregir la condicion final del `Retry Scope` exterior para que el flujo activo pueda finalizar correctamente.
2. Cambiar el log de `nombreReporteProformas` de nivel `Error` a `Trace` o `Info`.
3. Robustecer la validacion de sesion y el selector de login de NetSuite.
4. Aumentar y validar los tiempos de espera de descarga de reportes.
5. Ejecutar una prueba supervisada y comparar archivos descargados contra la carpeta compartida.

La razon de este orden es operacional: mientras `isFinish` no cambie a `True` en la ruta activa, el robot seguira marcando error al final; mientras el nombre de proformas se registre como `Error`, el log parecera peor de lo que realmente es; y si el login de NetSuite cambia de pantalla, la descarga puede quedar inestable.

## Caso 1 - Selector `login-submit` no encontrado en NetSuite

### Evidencia en log

- Fechas observadas:
  - `2026-08-13 16:18:36`.
  - `2026-08-20 12:39:06`.
  - `2026-08-20 12:43:20`.
  - `2026-08-20 12:47:24`.
- Mensaje principal: `[Target]: Strict selector failure`.
- Selector esperado: `<webctrl id='login-submit' tag='BUTTON'/>`.
- Coincidencias cercanas reportadas por UiPath:
  - `<webctrl id='uif48' tag='BUTTON'/>`.
  - `<webctrl id='uif52' tag='BUTTON'/>`.
  - `<webctrl id='uif55' tag='BUTTON'/>`.
  - `<webctrl id='uif58' tag='BUTTON'/>`.
  - `<webctrl id='button' tag='BUTTON'/>`.
- Actividad relacionada en `Main.xaml`: `Click 'Iniciar sesion'`.
- Selector observado en `Main.xaml`: boton `login-submit` en pagina `NetSuite Login`.

### Interpretacion

El robot espera encontrar el boton de inicio de sesion de NetSuite con id fijo `login-submit`, pero la pagina visible no siempre coincide exactamente con la pantalla grabada en Studio. UiPath encuentra otros botones de la interfaz, incluyendo ids dinamicos tipo `uif48`, `uif52`, `uif55` y `uif58`.

Esto indica que Chrome puede estar en una variante distinta de NetSuite: sesion ya iniciada, seleccion de rol, redireccion intermedia, pagina con ids dinamicos, pantalla cargando lentamente o login con estructura actualizada.

### Impacto

- La descarga inicial de reportes puede quedar inestable.
- El robot puede consumir reintentos antes de llegar a la pantalla correcta.
- Si no se normaliza la sesion, la ejecucion puede fallar antes de obtener los archivos requeridos.

### Accion recomendada

- Antes de hacer clic en `Iniciar sesion`, validar en que pantalla esta Chrome:
  - Si ya esta autenticado, omitir el login y navegar directo al reporte.
  - Si aparece login, diligenciar credenciales y usar un selector mas robusto.
  - Si aparece seleccion de rol o pantalla intermedia, manejar ese caso explicitamente.
- Regrabar o ajustar el selector para depender menos del id exacto cuando NetSuite renderiza ids dinamicos.
- Agregar logs de diagnostico con el titulo de la pagina y la URL actual antes del clic.
- Confirmar que la extension de UiPath para Chrome este activa y que la resolucion/zoom no cambie entre ejecuciones.

### Criterio de cierre

El robot debe poder iniciar desde Chrome abierto en cualquiera de estos estados: login, sesion activa o pantalla intermedia, y llegar al reporte sin registrar `Strict selector failure` para `login-submit`.

## Caso 2 - `Reporte de Proformas` registrado como error

### Evidencia en log

- Fechas observadas:
  - `2026-08-13 16:12:49`.
  - `2026-08-13 16:16:03`.
  - `2026-08-13 16:19:39`.
  - `2026-08-20 12:40:18`.
  - `2026-08-20 12:44:13`.
  - `2026-08-20 12:48:27`.
- Mensajes:
  - `Reporte de Proformas_2026_08_13.xls`.
  - `Reporte de Proformas_2026_08_20.xls`.
- Actividad relacionada en `Main.xaml`: `Log Message`.
- Ubicacion observada en `Main.xaml`: despues de asignar `nombreReporteProformas`.
- Configuracion encontrada: el `Log Message` que escribe `[nombreReporteProformas]` esta en nivel `Error` en una ruta del workflow.

### Interpretacion

El mensaje no muestra una excepcion ni stack trace. Solo registra el nombre del archivo descargado, pero lo hace con nivel `Error`. Por eso el log contabiliza errores aunque el paso siguiente registre que UiPath abrio o uso los archivos Excel en la carpeta compartida.

En la misma zona del flujo existe otra version del `Log Message` con nivel `Trace`, lo que sugiere que el nivel `Error` quedo como residuo de diagnostico o prueba.

### Impacto

- Aumenta falsamente la cantidad de errores en Orchestrator.
- Puede activar alertas o revisiones innecesarias.
- Dificulta separar fallas reales de trazas normales de ejecucion.

### Accion recomendada

- Cambiar el nivel del `Log Message` de `[nombreReporteProformas]` de `Error` a `Info` o `Trace`.
- Reservar el nivel `Error` para excepciones reales o fallas funcionales.
- Agregar un mensaje mas claro, por ejemplo: `Reporte de proformas descargado: <nombre>`.
- Revisar si hay otros `Log Message` temporales usados durante depuracion.

### Criterio de cierre

Una descarga correcta de proformas debe quedar registrada como `Info` o `Trace`, no como `Error`. El conteo de errores del log debe reflejar solamente fallas reales.

## Caso 3 - `Retry Scope: Error en el flujo`

### Evidencia en log

- Fechas observadas:
  - `2026-08-12 12:05:03`.
  - `2026-08-13 16:21:02`.
  - `2026-08-20 12:50:53`.
- Mensaje principal: `Retry Scope: Error en el flujo`.
- Stack visible:
  - `at Throw "Retry Scope"`.
  - `at RetryScope "Retry Scope"`.
  - `at Sequence "MainAction"`.
  - `at Main "Main"`.
- Configuracion encontrada en `Main.xaml`:
  - Variable `isFinish` inicia en `False`.
  - El `Retry Scope` exterior tiene condicion `Check True` con expresion `[isFinish]`.
  - La asignacion `isFinish = True` aparece dentro de una ruta del flujo que actualmente esta deshabilitada por `Comment Out`, segun el `README.md` y `docs/descripcion-funcional.md`.

### Interpretacion

El error final no parece originarse necesariamente en la descarga de archivos, sino en la condicion de cierre del `Retry Scope`. La ruta activa descarga/mueve reportes y calcula datos de ejecucion, pero la marca de exito (`isFinish = True`) queda en el bloque de procesamiento completo que esta comentado.

Como `isFinish` permanece en `False`, el `Check True` del `Retry Scope` no se cumple, UiPath reintenta hasta agotar los tres intentos y finalmente lanza `Error en el flujo`.

### Impacto

- La ejecucion termina con estado fallido aunque haya descargado reportes.
- Se reprocesa la descarga hasta tres veces.
- Puede generar archivos repetidos como `ResultadosKSREPORTECARTERAROBOT353.xls`, `523.xls`, `842.xls`.
- Dificulta saber si la falla real esta en NetSuite, en descarga, en movimiento de archivos o solo en la condicion de finalizacion.

### Accion recomendada

- Definir una condicion de exito para el flujo activo actual.
- Si por ahora el alcance activo es solo descargar y mover reportes, asignar `isFinish = True` despues de validar:
  - `ExcelReporte` no es `Nothing`.
  - `ExcelReporteProformas` no es `Nothing`.
  - Ambos archivos existen en la ruta compartida esperada.
  - La carpeta de ejecucion fue creada correctamente.
- Si el procesamiento completo debe volver a ejecutarse, sacar del `Comment Out` las actividades necesarias por etapas y mantener `isFinish = True` al final real del flujo.
- Cambiar el mensaje `Error en el flujo` por uno mas diagnostico, por ejemplo: `No se cumplio la condicion final isFinish=True despues de descargar y preparar reportes`.

### Criterio de cierre

El robot debe terminar una ejecucion exitosa sin agotar reintentos y sin lanzar `Retry Scope: Error en el flujo` cuando los reportes requeridos fueron descargados y movidos correctamente.

## Observaciones tecnicas adicionales

- Los tiempos de espera de `GetLastDownloadedFile` observados en `Main.xaml` son bajos para descargas por red: `1000` ms para cartera y `1500` ms para proformas.
- El flujo usa rutas compartidas como `\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\...`; se debe validar permiso de lectura/escritura para el usuario robot.
- El README del proyecto indica que el procesamiento completo y envio de correos estan dentro de `Comment Out`; por tanto, una ejecucion actual puede no generar estados de cuenta ni correos aunque descargue los reportes.
- Se observa ejecucion atendida y no atendida. Dado que el proceso interactua con Chrome, conviene validar que el modo de ejecucion tenga sesion interactiva disponible.

## Validaciones sugeridas para la siguiente prueba

1. Abrir Chrome con sesion limpia y confirmar que NetSuite llega a la pagina de reportes.
2. Ejecutar el robot con logs en nivel `Trace`.
3. Confirmar que se descarguen los dos reportes esperados:
   - `ResultadosKSREPORTECARTERAROBOT*.xls`.
   - `Reporte de Proformas_yyyy_MM_dd.xls`.
4. Confirmar que ambos archivos queden en `\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\`.
5. Confirmar que `nombreReporteProformas` no se registre como `Error`.
6. Confirmar que `isFinish` cambie a `True` en la ruta activa o que la condicion del `Retry Scope` se ajuste al alcance actual.

## Checklist de correccion

- [x] Cambiar el `Log Message` de `nombreReporteProformas` de `Error` a `Info` o `Trace`.
- [x] Ajustar la condicion de cierre del `Retry Scope` exterior para el flujo activo.
- [x] Generar reporte markdown de error en carpeta del dia bajo la ruta base del proceso.
- [ ] Agregar validacion explicita de archivos descargados y movidos.
- [ ] Robustecer selector o flujo de login de NetSuite.
- [ ] Aumentar timeout de descarga y espera de pagina.
- [ ] Ejecutar prueba supervisada y guardar nuevo log para comparar contra este documento.

## Correcciones aplicadas el 2026-08-20

- `Main.xaml`: el mensaje de `nombreReporteProformas` paso de nivel `Error` a `Info` para evitar falsos positivos en Orchestrator.
- `Main.xaml`: se agrego una marca activa `isFinish = True` despues del bloque actualmente comentado, de forma que la ruta activa no vuelva a descargar reportes solo porque la condicion final nunca se cumplia.
- `Main.xaml`: el `Catch` exterior ahora intenta crear un reporte markdown por error en `\\10.10.15.120\Automatizaciones\Uipath\estados_cuenta_cartera\yyyy-MM-dd\errores\ERROR_EJECUCION_yyyyMMdd_HHmmss.md`.
