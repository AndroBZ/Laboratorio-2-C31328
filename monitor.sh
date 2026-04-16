#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Uso: $0 \"comando\" [intervalo]"
    exit 1
fi

COMANDO="$1"
INTERVALO=${2:-2}

bash -c "exec $COMANDO" &
PID=$!

echo "Proceso iniciado con PID: $PID"
LOG="monitor_${PID}.log"

echo "TIME CPU MEM RSS" > $LOG

trap "echo 'Interrumpido...'; kill $PID; exit" SIGINT

while ps -p $PID > /dev/null 2>&1; do
 
    TIMESTAMP=$(date "+%H:%M:%S")
    
    DATA=$(ps -p $PID -o %cpu,%mem,rss --no-headers | xargs)
    
    if [ ! -z "$DATA" ]; then
        echo "$TIMESTAMP $DATA" >> $LOG
        
        echo "$TIMESTAMP $DATA"
    fi
    
    sleep $INTERVALO
done

echo "Proceso terminado. Datos guardados en $LOG"

gnuplot << EOF
set terminal png
set output "monitor_${PID}.png"
set title "Monitoreo PID $PID"
set xlabel "Tiempo"
set ylabel "CPU (%)"
set y2label "Memoria RSS (KB)"
set y2tics
set ytics nomirror
# Columna 2: CPU, Columna 4: RSS
plot "$LOG" using 0:2 with lines title "CPU", \
     "$LOG" using 0:4 axes x1y2 with lines title "Mem RSS"
EOF

echo "Gráfica generada: monitor_${PID}.png"
