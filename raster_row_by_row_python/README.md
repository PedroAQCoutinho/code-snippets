Repositório dedicado a criar uma função para contagem de pixels de um raster e fazer o upload desses valores em um banco de dados.

Etapas do processamento:

1. Ler todos os rasters
2. Dividi-los em blocos com número de linhas e colunas pré definido (faltam melhorias)
3. Iterar sobre cada bloco e extrair os valores em forma de pandas dataframe
4. Para cada iteração, aplicar operações de groupby e agregador (agg). Os campos a serem utilizados como groupby e agregador (agg) devem ser especificados nos argumentos
5. Definir um método de paralelização multiprocessing 
6. Subir os dados em um banco de dados especificado em .env




Problemas: O código funciona porém ele quebra a memória. Foram realizados testes e até com 1 nucleo de paralelização quebrou a memoria



Para obter ajuda:

`python run.py -h`
