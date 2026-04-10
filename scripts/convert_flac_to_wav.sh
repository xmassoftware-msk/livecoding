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

find "$dir" -type f -name "*.flac" | while read -r flacfile; do
    wavfile="${flacfile%.flac}.wav"
    
    if [ ! -f "$wavfile" ]; then
        echo "Convirtiendo: $flacfile"
        ffmpeg -i "$flacfile" "${flacfile%.flac}.wav"
    else
        echo "Ya existe: $wavfile (omitido)"
    fi
done

echo "Conversión completada"