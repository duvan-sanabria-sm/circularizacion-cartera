# Guia para ejecutar el pipeline

[Volver a la documentacion principal](../../README.md)

## Objetivo

Esta guia explica como dejar disponible la maquina local para que Azure DevOps pueda ejecutar el pipeline del proyecto.

El pipeline usa el pool:

```yaml
pool:
  name: 'Default'
```

Si el pool `Default` corresponde a un agente self-hosted instalado en la maquina local, esa maquina debe estar encendida y el agente debe estar conectado antes de ejecutar el pipeline.

## Cuando se debe iniciar el agente

Se debe iniciar el agente local cuando al ejecutar el pipeline aparezca un mensaje similar a:

```text
The agent request is not running because all potential agents are running other requests.
Current position in queue: 1
Job preparation parameters
```

Este mensaje indica que el pipeline quedo en cola porque Azure DevOps no tiene un agente disponible para ejecutar el trabajo.

## Iniciar el agente desde PowerShell

1. Abrir PowerShell en la maquina donde esta configurado el agente self-hosted.
2. Ir a la carpeta donde esta instalado el agente de Azure DevOps.
3. Ejecutar el siguiente comando:

```powershell
.\run.cmd
```

4. Dejar la ventana de PowerShell abierta mientras se ejecuta el pipeline.
5. Volver a Azure DevOps y ejecutar nuevamente el pipeline, o esperar a que el trabajo en cola sea tomado por el agente.

## Importante

- Si se cierra la ventana de PowerShell, el agente deja de estar disponible.
- Si la maquina local esta apagada, suspendida o sin conexion, el pipeline no podra ejecutarse con ese agente.
- Si el agente esta instalado como servicio de Windows, no es necesario ejecutar `.\run.cmd`; en ese caso se debe validar que el servicio del agente este iniciado.

## Validacion rapida

En Azure DevOps se puede revisar el estado del agente en:

```text
Project settings > Agent pools > Default > Agents
```

El agente debe aparecer como `Online` y habilitado.
