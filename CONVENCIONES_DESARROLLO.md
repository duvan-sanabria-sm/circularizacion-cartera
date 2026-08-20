# Convenciones de desarrollo

Este documento define reglas operativas para mantener ordenado el desarrollo del robot UiPath `CircularizacionCartera`.

## Rama por funcionalidad

Cuando se solicite una funcionalidad nueva, se debe crear una rama nueva antes de modificar archivos.

Formato recomendado:

```text
codex/<descripcion-corta>
```

Ejemplos:

```text
codex/estabilizar-descarga-reportes
codex/corregir-retry-scope-final
codex/generar-estados-cuenta
codex/validar-proformas
```

## Flujo de trabajo

1. Revisar el estado del repositorio con `git status`.
2. Crear una rama nueva para funcionalidades nuevas.
3. Mantener el cambio enfocado en la solicitud.
4. Validar que `Main.xaml` cargue correctamente en UiPath Studio.
5. Validar que no haya errores evidentes de XML en los archivos `.xaml`.
6. Ejecutar `.\tools\validate-project.ps1` cuando aplique.
7. Documentar cambios relevantes en `README.md`, `docs/` o en el markdown tecnico correspondiente.
8. Hacer commit con un mensaje claro.

## Correcciones sobre una incidencia

Si ya existe una rama asociada a la incidencia en curso, las correcciones relacionadas pueden continuar en esa misma rama.

Ejemplos:

```text
codex/error-login-netsuite
codex/error-proformas-retry-scope
codex/timeout-descarga-reportes
```

## Cambios en `Main.xaml`

`Main.xaml` concentra la mayor parte de la logica del robot. Para evitar regresiones:

- Hacer cambios pequenos y verificables.
- No mover bloques grandes sin una razon clara.
- Evitar dejar actividades temporales de diagnostico en nivel `Error`.
- Revisar condiciones de cierre como `isFinish` despues de modificar `Retry Scope`.
- Confirmar que las actividades dentro de `Comment Out` sean intencionales.
- Cuando se habilite una seccion comentada, probarla por etapas.

## Logs y documentacion de errores

Los errores de ejecucion deben documentarse en `ERRORES_EJECUCION.md` cuando aparezca un patron repetido o una falla que requiera seguimiento.

Cada caso deberia incluir:

- Fecha y hora observada.
- Mensaje principal del log.
- Actividad o etapa relacionada.
- Interpretacion.
- Impacto.
- Accion recomendada.
- Criterio de cierre.

## Archivos locales de prueba

Los archivos exportados o adjuntos para diagnostico, como logs temporales, reportes descargados o copias de archivos Excel, no deben incluirse en commits salvo que se pidan explicitamente como fixture o evidencia versionada.

Ejemplos de archivos que normalmente quedan fuera del commit:

```text
robot-logs-*.csv
ResultadosKSREPORTECARTERAROBOT*.xls
Reporte de Proformas_*.xls
*.tmp
*.crdownload
```

## Rutas y configuracion

Evitar introducir nuevas rutas absolutas o valores de ambiente directamente en el XAML.

Cuando sea posible, mover estos valores a configuracion o activos de Orchestrator:

- Rutas compartidas de red.
- URLs de NetSuite.
- Correos de origen, destino, copia o prueba.
- Nombres de reportes.
- Rutas de macros o plantillas.

Si una ruta absoluta ya existe y se modifica, documentar el motivo y validar que sea compatible con el usuario robot.

## NetSuite y Chrome

El robot depende de interaccion con NetSuite en Chrome. Antes de validar una correccion:

- Confirmar que la extension de UiPath para Chrome este activa.
- Confirmar que la sesion de NetSuite este en un estado esperado.
- Considerar pantallas alternativas: login, sesion activa, seleccion de rol o redireccion.
- Evitar selectores excesivamente fragiles cuando NetSuite use ids dinamicos.
- Registrar URL y titulo de pagina cuando una pantalla no sea reconocida.

## Excel y reportes

Los reportes descargados y manipulados por Excel deben tratarse como salidas operativas, no como codigo fuente.

Buenas practicas:

- Cerrar archivos de prueba antes de ejecutar el robot.
- Validar que el usuario robot tenga permisos sobre la ruta compartida.
- No versionar reportes generados.
- Revisar tiempos de espera de descarga cuando el archivo venga de red o NetSuite.
- Confirmar que las macros referenciadas existan y coincidan con los activos configurados.

## Mensajes de commit

Usar mensajes concretos y orientados al cambio.

Ejemplos:

```text
docs: documentar errores de ejecucion de circularizacion
fix: ajustar condicion final del retry scope
fix: estabilizar selector de login de netsuite
chore: actualizar convenciones de desarrollo
```

## Criterio minimo antes de cerrar una tarea

Antes de dar una tarea por cerrada:

- El cambio solicitado debe estar implementado o documentado.
- El archivo modificado debe poder leerse correctamente.
- No se deben revertir cambios ajenos.
- Los archivos temporales usados para diagnostico deben quedar fuera del commit.
- Si no fue posible ejecutar una validacion, se debe dejar la razon documentada en la respuesta final.
