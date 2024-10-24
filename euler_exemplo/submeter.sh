#!/bin/bash

#PBS -N exemplo
#PBS -l select=1:ncpus=1
#PBS -l walltime=1:00:00
#PBS -q atlas

#Carrega os modulos gcc e R, necessarios para carregar o R
module load gcc R

#Muda o diretorio para o diretorio do exemplo
cd /home/atlas/exemplo/

#Faz o R ler o arquivo script.R
#Nao se esqueca de conferir o conteudo do arquivo script.R

R --no-save < script.R > output 2>&1
