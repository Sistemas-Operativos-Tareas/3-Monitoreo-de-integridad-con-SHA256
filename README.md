# Sistemas Operativos
## Monitoreo de integridad con SHA256

### Descripción

Este proyecto implementa un script en Bash para verificar la integridad de archivos críticos de un sistema Linux mediante funciones hash SHA256.

El sistema compara los valores SHA256 actuales contra valores previamente almacenados para detectar modificaciones y generar bitácoras en formato JSON.

### Objetivo

Detectar modificaciones en archivos definidos mediante un archivo de configuración JSON y registrar los resultados de cada verificación.

### Tecnologías utilizadas

- Linux
- Bash
- SHA256
- JSON
- jq
- Git
- GitHub
- Cron

## Estructura del proyecto
Monitoreo de integridad con SHA256/
│
├── monitorear_integridad.sh
├── config_archivos.json
├── guardar-sha256.sha256
├── bitacoras/
│ └── log_hashes_YYYY-MM-DD-HH-MM.json
└── pruebas/
├── prueba.txt
└── fstab_prueba

Los valores SHA256 de referencia se almacenan en:
    guardar-sha256.sha256
    
Para ejecutar el monitoreo manualmente:
    ./monitorear_integridad.sh
    
## El script realiza las siguientes acciones:

Lee los archivos definidos en el archivo JSON.
Calcula el valor SHA256 actual de cada archivo.
Compara el hash actual contra el hash esperado.
Detecta modificaciones.
Genera una bitácora en formato JSON.


## Ejecución automática con cron

El monitoreo de integridad se ejecuta automáticamente una vez al día mediante cron con privilegios administrativos para poder verificar archivos protegidos del sistema como `/etc/shadow`. Para pruebas
*/5 * * * * cd "/ruta/del/proyecto/Monitoreo de integridad con SHA256" && ./monitorear_integridad.sh

y se dejo una vez al dia a las 10 de la noche
0 22 * * * cd "/ruta/del/proyecto/Monitoreo de integridad con SHA256" && ./monitorear_integridad.sh

## Pruebas realizadas

Se realizaron pruebas para verificar el funcionamiento del sistema:

Verificación de archivos sin modificaciones.
Detección de cambios en archivos monitoreados.
Generación de alertas cuando un archivo cambia.
Creación de bitácoras en formato JSON.

## Resultado

El proyecto permite monitorear la integridad de archivos críticos de Linux utilizando SHA256, detectar modificaciones no autorizadas y registrar evidencia de cada verificación realizada.
