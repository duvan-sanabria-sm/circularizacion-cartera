➡️ [Volver a la documentación principal](../README.md)

# 📁 Documentos

A continuación, se describen las rutas y archivos que utiliza el robot durante la ejecución del proceso.

---

## 📄 Estados de Cuenta de Clientes

**Ruta:**
`\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\cliente\`

**Descripción:**  
En esta carpeta se almacena el estado de cuenta generado para cada cliente.  
El robot toma estos archivos y los adjunta en el cuerpo del correo electrónico que se envía a cada cliente.

---

## 📊 Plantilla Estado de Cuenta

**Archivo:**  
`\\10.10.15.120\DatosCartera\Estados de Cuenta Automatizado\PLANTILLA ESTADO DE CUENTA SM.xlsx`

**Descripción:**  
Esta es la plantilla de Excel que utiliza el robot como base para generar el estado de cuenta.  
En esta plantilla, el robot pega la información del cliente y las facturas vencidas para generar el documento final que posteriormente se envía por correo.

---

## 🧾 Notas

- El robot debe tener permisos de lectura y escritura sobre estas rutas.
- No se debe cambiar el nombre del archivo de plantilla.
- No se debe modificar la estructura de carpetas sin actualizar la configuración del robot.