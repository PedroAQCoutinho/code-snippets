import argparse
import rasterio
import numpy as np

def process_raster(input_raster_path, output_raster_path, nodata_value):
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

def main():
    parser = argparse.ArgumentParser(description="Transformar pixels com valor 0 em valores nulos (nodata) em um dado raster.")
    parser.add_argument("input_raster", help="Caminho para o arquivo raster de entrada")
    parser.add_argument("output_raster", help="Caminho para o novo arquivo raster de saída")
    parser.add_argument("nodata_value", type=float, help="Valor nulo (nodata) a ser usado no novo raster")
    
    args = parser.parse_args()
    
    process_raster(args.input_raster, args.output_raster, args.nodata_value)

if __name__ == "__main__":
    main()
