#!/usr/bin/env bash

DIRECTORIO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG="$DIRECTORIO_SCRIPT/config_archivos.json"
REFERENCIA="$DIRECTORIO_SCRIPT/guardar-sha256.sha256"

# Fecha y hora de la ejecución
MARCA_TIEMPO=$(date +%F-%H-%M)
FECHA=$(date +%F)
HORA=$(date +%H:%M)

# Nombre de la bitácora
CARPETA_BITACORAS="$DIRECTORIO_SCRIPT/bitacoras"
mkdir -p "$CARPETA_BITACORAS"

BITACORA="$CARPETA_BITACORAS/log_hashes_${MARCA_TIEMPO}.json"

if [ ! -f "$CONFIG" ]; then
    echo "Error: no existe $CONFIG"
    exit 1
fi

if [ ! -f "$REFERENCIA" ]; then
    echo "Error: no existe $REFERENCIA"
    exit 1
fi

echo "=== Monitoreo de integridad SHA256 ==="

# Lista JSON donde guardaremos los resultados
resultados='[]'

while IFS= read -r archivo; do

    hash_actual=""
    hash_esperado=""
    estado="error"

    if [ ! -f "$archivo" ]; then
        echo "[ERROR] No existe o no es un archivo regular: $archivo"

    elif ! resultado=$(sudo sha256sum -- "$archivo"); then
        echo "[ERROR] No se pudo calcular la huella: $archivo"

    else
        hash_actual=$(printf '%s\n' "$resultado" | awk '{print $1}')

        hash_esperado=$(awk -v ruta="$archivo" \
            'substr($0, 67) == ruta {print substr($0, 1, 64)}' \
            "$REFERENCIA")

        if [ -z "$hash_esperado" ]; then
            estado="sin_referencia"
            echo "[SIN REFERENCIA] $archivo"

        elif [ "$hash_actual" = "$hash_esperado" ]; then
            estado="sin_cambios"
            echo "[OK] $archivo"

        else
            estado="modificado"
            echo "[MODIFICADO] $archivo"
            echo "  Esperado: $hash_esperado"
            echo "  Actual:   $hash_actual"
        fi
    fi

    # Agregar resultado del archivo al JSON
    resultados=$(jq \
        --arg ruta "$archivo" \
        --arg actual "$hash_actual" \
        --arg esperado "$hash_esperado" \
        --arg estado "$estado" \
        '. + [{
            ruta: $ruta,
            sha256_actual: $actual,
            sha256_esperado: $esperado,
            estado: $estado
        }]' <<< "$resultados") || exit 1

done < <(jq -r '.archivos[]' "$CONFIG")


# Construir la bitácora JSON
reporte=$(jq -n \
    --arg fecha "$FECHA" \
    --arg hora "$HORA" \
    --argjson archivos "$resultados" '
    {
        fecha: $fecha,
        hora: $hora,
        operacion: "verificacion_hashes",

        archivos: $archivos,

        resumen: {
            total_verificados: ($archivos | length),

            sin_cambios: (
                [$archivos[] |
                    select(.estado == "sin_cambios")] | length
            ),

            modificados: (
                [$archivos[] |
                    select(.estado == "modificado")] | length
            ),

            errores: (
                [$archivos[] |
                    select(.estado == "error")] | length
            ),

            sin_referencia: (
                [$archivos[] |
                    select(.estado == "sin_referencia")] | length
            )
        },

        alerta: any($archivos[]; .estado != "sin_cambios"),

        estado_final: (
            if any($archivos[]; .estado != "sin_cambios")
            then "completado_con_alertas"
            else "completado"
            end
        )
    }
') || exit 1


# Mostrar alerta si hubo algún problema
if jq -e '.alerta' <<< "$reporte" > /dev/null; then
    echo "[ALERTA] Se detectaron modificaciones en archivos monitoreados."
fi


# Guardar la bitácora
printf '%s\n' "$reporte" > "$BITACORA" || exit 1

echo "Bitácora guardada: $BITACORA"
