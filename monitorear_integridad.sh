#!/usr/bin/env bash

CONFIG="config_archivos.json"
HASHES="guardar-sha256.sha256"

if [ ! -f "$CONFIG" ]; then
    echo "Error: no existe $CONFIG"
    exit 1
fi

if [ ! -f "$HASHES" ]; then
    echo "Error: no existe $HASHES"
    exit 1
fi

echo "=== Monitoreo de integridad SHA256 ==="

jq -r '.archivos[]' "$CONFIG" | while read -r archivo; do

    if [ ! -f "$archivo" ]; then
        echo "[NO EXISTE] $archivo"
        continue
    fi

    if sha256sum -c "$HASHES" --status -- "$archivo"; then
        echo "[OK] $archivo"
    else
        echo "[MODIFICADO] $archivo"
    fi

done
