#!/bin/bash

#PBS -N ufs
#PBS -l select=1:ncpus=1
#PBS -l walltime=1:00:00
#PBS -q atlas

#Carrega os modulos gcc e R, necessarios para carregar o R
module load python/3.10.1



#Muda o diretorio para o diretorio do exemplo
cd /home/pquilici/gitworkspace/code-snippets/euler_exemplo

python -m venv _euler_exemplo

source _euler_exemplo/bin/activate

pip install pyarrow
pip install geopandas
pip install requests 

#Faz o R ler o arquivo script.R
#Nao se esqueca de conferir o conteudo do arquivo script.R

python main.py > output 2>&1
