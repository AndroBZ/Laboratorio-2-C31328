#!/bin/bash


if [ $# -lt 1 ]; then
    echo "Uso: $0 \"comando\" [intervalo]"
    exit 1
fi

COMANDO="$1"
INTERVALO=${2:-2}
START_TIME=$(date +%s)


bash -c "exec $COMANDO" &
PID=$!

echo "Proceso iniciado con PID: $PID"
LOG="monitor_${PID}.log"
GRAFICA="monitor_${PID}.png"

echo "SECONDS CPU MEM RSS" > "$LOG"

trap "echo 'Interrumpido...'; kill $PID; exit" SIGINT


while ps -p $PID > /dev/null 2>&1; do
    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    
    DATA=$(ps --ppid $PID -p $PID -o %cpu,%mem,rss --no-headers | awk '{cpu+=$1; mem+=$2; rss+=$3} END {print cpu, mem, rss}')

    if [ ! -z "$DATA" ]; then
        echo "$ELAPSED $DATA" >> "$LOG"
        echo "T: ${ELAPSED}s | $DATA"
    fi
    
    sleep $INTERVALO
done

echo "Proceso terminado. Datos guardados en $LOG"

if command -v gnuplot >/dev/null 2>&1; then
    gnuplot << EOF
        set terminal png size 800,600
        set output "$GRAFICA"
        set title "Comando: $COMANDO | PID: $PID"
        set xlabel "Tiempo transcurrido (segundos)"
        set ylabel "CPU (%)"
        set y2label "Memoria RSS (KB)"
        set ytics nomirror
        set y2tics
        set grid
        plot "$LOG" using 1:2 with lines title "CPU %" axis x1y1, \
             "$LOG" using 1:4 with lines title "RSS (KB)" axis x1y2
EOF
    echo "Gráfica generada: $GRAFICA"
else
    echo "Error: gnuplot no instalado."
fi
