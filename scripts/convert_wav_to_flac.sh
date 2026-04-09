#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

dir="$1"

if [ ! -d "$dir" ]; then
    echo "Error: '$dir' no es un directorio válido"
    exit 1
fi

find "$dir" -type f -name "*.wav" | while read -r wavfile; do
    flacfile="${wavfile%.wav}.flac"
    
    if [ ! -f "$flacfile" ]; then
        echo "Convirtiendo: $wavfile"
        ffmpeg -i "$wavfile" "${wavfile%.wav}.flac"
    else
        echo "Ya existe: $flacfile (omitido)"
    fi
done

echo "Conversión completada"