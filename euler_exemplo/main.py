import os
import requests
import zipfile
import geopandas as gpd

# Definir a URL do arquivo e o diretório de trabalho
url = 'https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_municipais/municipio_2022/Brasil/BR/BR_UF_2022.zip'
work_dir = '.'

# Garantir que estamos no diretório de trabalho correto
os.chdir(work_dir)

# Nome do arquivo zip a ser baixado
zip_filename = 'BR_UF_2022.zip'

# 1. Baixar o arquivo ZIP
print(f"Baixando {zip_filename} ...")
response = requests.get(url)
with open(zip_filename, 'wb') as file:
    file.write(response.content)

print(f"Arquivo {zip_filename} baixado com sucesso!")

# 2. Descompactar o arquivo ZIP
print(f"Descompactando {zip_filename} ...")
with zipfile.ZipFile(zip_filename, 'r') as zip_ref:
    zip_ref.extractall(work_dir)

print(f"Arquivo {zip_filename} descompactado com sucesso!")

# 3. Encontrar o arquivo .shp na pasta descompactada
# Geralmente, o arquivo .shp é um dos arquivos extraídos
shapefile_path = None
for root, dirs, files in os.walk(work_dir):
    for file in files:
        if file.endswith('.shp'):
            shapefile_path = os.path.join(root, file)
            break

if shapefile_path:
    print(f"Shapefile encontrado: {shapefile_path}")

    # 4. Ler o arquivo .shp usando GeoPandas
    print("Lendo o shapefile com GeoPandas...")
    gdf = gpd.read_file(shapefile_path)

    # 5. Salvar como arquivo Parquet
    parquet_filename = os.path.join(work_dir, 'BR_UF_2022.parquet')
    print(f"Salvando o arquivo como Parquet: {parquet_filename} ...")
    gdf.to_parquet(parquet_filename)

    print("Arquivo Parquet salvo com sucesso!")
else:
    print("Erro: Nenhum arquivo .shp encontrado!")
