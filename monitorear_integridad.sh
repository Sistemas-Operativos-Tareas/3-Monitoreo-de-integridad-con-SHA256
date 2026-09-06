#!/usr/bin/env bash

CONFIG="config_archivos.json"
REFERENCIA="guardar-sha256.sha256"

if [ ! -f "$CONFIG" ]; then
    echo "Error: no existe $CONFIG"
    exit 1
fi

if [ ! -f "$REFERENCIA" ]; then
    echo "Error: no existe $REFERENCIA"
    exit 1
fi

echo "=== Monitoreo de integridad SHA256 ==="

while IFS= read -r archivo; do

    if [ ! -f "$archivo" ]; then
        echo "[ERROR] No existe o no es un archivo regular: $archivo"
        continue
    fi

    if ! resultado=$(sha256sum -- "$archivo"); then
        echo "[ERROR] No se pudo calcular la huella: $archivo"
        continue
    fi

    hash_actual=$(printf '%s\n' "$resultado" | awk '{print $1}')

    hash_esperado=$(awk -v ruta="$archivo" \
        'substr($0, 67) == ruta {print substr($0, 1, 64)}' \
        "$REFERENCIA")

    if [ -z "$hash_esperado" ]; then
        echo "[SIN REFERENCIA] $archivo"
    elif [ "$hash_actual" = "$hash_esperado" ]; then
        echo "[OK] $archivo"
    else
        echo "[MODIFICADO] $archivo"
        echo "  Esperado: $hash_esperado"
        echo "  Actual:   $hash_actual"
    fi

done < <(jq -r '.archivos[]' "$CONFIG")
