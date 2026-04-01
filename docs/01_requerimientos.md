➡️ [Volver a la documentación principal](../README.md)

## 1. 🧩 Requerimientos Funcionales (RF)

## RF-01 – Deploy de los robots en el Orquestador

### Descripción
Se requiere migrar los procesos (robots/proyectos) existentes en una cuenta de UiPath Orchestrator hacia una nueva cuenta de UiPath Orchestrator, asegurando que los paquetes, procesos y configuraciones asociadas queden correctamente desplegadas en el entorno destino.

### Entradas
- Cuenta origen de UiPath Orchestrator
- Cuenta destino de UiPath Orchestrator
- Proyectos UiPath (código fuente o paquetes .nupkg)
- Acceso al Orchestrator origen y destino
- Credenciales o External Application
- Repositorio Git con los proyectos
- Azure DevOps
- Lista de procesos a migrar
- Estructura de carpetas (folders/subfolders)

### Proceso
1. Identificar los procesos existentes en el Orchestrator origen.
2. Exportar u obtener los proyectos UiPath.
3. Subir los proyectos al repositorio Git.
4. Configurar pipeline en Azure DevOps.
5. Empaquetar los proyectos UiPath.
6. Publicar los paquetes en el Orchestrator destino.
7. Crear o actualizar los procesos en el Orchestrator destino.
8. Validar que los procesos estén asociados al paquete correcto.
9. Ejecutar pruebas de ejecución.
10. Documentar los procesos migrados.

### Salidas
- Procesos desplegados en la nueva cuenta de UiPath Orchestrator.
- Paquetes publicados en el Orchestrator destino.
- Procesos funcionales en el folder correspondiente.
- Registro de migración realizada.

### Reglas de negocio
- Los procesos deben conservar el mismo nombre que en el Orchestrator origen.
- Los procesos deben desplegarse en el folder correspondiente.
- Las versiones de los paquetes deben controlarse mediante versionamiento.
- No se deben sobrescribir procesos en producción sin validación previa.
- Todo despliegue debe realizarse mediante pipeline.

### Prioridad
- Alta

---