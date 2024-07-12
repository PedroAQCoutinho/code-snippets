#!/bin/bash

# Executar run.py em segundo plano e capturar o PID
python run.py -f /home/pedro -t raster_table -n 4 -g pa_br_vigorpastagem_lapig8_30m_2022 -a pa_br_aptidao_250m:mean pa_br_aptidao_250m_zndt:sum --max-blocks 50000 &
RUN_PID=$!

# Salvar o PID em um arquivo
echo $RUN_PID > run_pid.txt

# Executar monitoramento.py passando o PID como argumento
python monitoramento.py $RUN_PID