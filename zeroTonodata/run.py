import rasterio
import numpy as np

# Defina o caminho para o arquivo raster original e o novo arquivo raster
input_raster_path = '/home/pedro/Documents/DADOS/Aptidao_BR_geotiff/IQscr_Crop_BR.tif'
output_raster_path = '/home/pedro/Documents/DADOS/Aptidao_BR_geotiff/pa_br_aptidao_250m_zndt.tif'

# Valor nulo (nodata) a ser usado no novo raster
nodata_value = 0

# Abre o arquivo raster original
with rasterio.open(input_raster_path) as src:
    # Lê os dados da primeira banda do raster
    data = src.read(1)
    
    # Substitui os valores 0 pelo valor nulo (nodata_value)
    data = np.where(data == 0, nodata_value, data)
    
    # Cria um novo perfil baseado no perfil original, incluindo o valor nulo (nodata)
    profile = src.profile
    profile.update(nodata=nodata_value)
    
    # Cria um novo arquivo raster com os dados modificados
    with rasterio.open(output_raster_path, 'w', **profile) as dst:
        dst.write(data, 1)

print(f"Novo arquivo raster criado em: {output_raster_path}")
