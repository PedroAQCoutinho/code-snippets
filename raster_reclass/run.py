import argparse
import numpy as np
from osgeo import gdal, gdal_array

def reclassify_raster(input_raster, output_raster, breaks):
    # Abrir o raster de entrada
    dataset = gdal.Open(input_raster)
    band = dataset.GetRasterBand(1)
    data = band.ReadAsArray()
    nodata_value = band.GetNoDataValue()
    
    # Verificar se existe algum valor NaN e substituir pelo valor nodata
    if np.isnan(data).any():
        if nodata_value is None:
            # Se não há valor nodata definido, definimos um
            nodata_value = -9999
            data[np.isnan(data)] = nodata_value
        else:
            data[np.isnan(data)] = nodata_value
    
    # Calcular os percentis
    percentiles = np.linspace(0, 100, breaks + 1)[1:-1]
    thresholds = np.percentile(data[data != nodata_value], percentiles)
    
    # Reclassificar o raster
    reclassified = np.digitize(data, thresholds) + 1
    
    # Ajustar o valor nodata
    reclassified[data == nodata_value] = nodata_value
    
    # Criar o raster de saída
    driver = gdal.GetDriverByName('GTiff')
    out_dataset = driver.Create(output_raster, dataset.RasterXSize, dataset.RasterYSize, 1, gdal.GDT_Int32)
    out_dataset.SetGeoTransform(dataset.GetGeoTransform())
    out_dataset.SetProjection(dataset.GetProjection())
    
    out_band = out_dataset.GetRasterBand(1)
    out_band.WriteArray(reclassified)
    out_band.SetNoDataValue(nodata_value)
    
    # Fechar os datasets
    out_band.FlushCache()
    del dataset, out_dataset

def main():
    parser = argparse.ArgumentParser(description="Reclassify raster into specified number of breaks using GDAL.")
    parser.add_argument('input_raster', type=str, help='Path to the input raster file')
    parser.add_argument('output_raster', type=str, help='Path to the output raster file')
    parser.add_argument('breaks', type=int, help='Number of breaks (e.g., 3 for terciles, 4 for quartiles, 5 for quintiles, etc.)')
    
    args = parser.parse_args()
    
    reclassify_raster(args.input_raster, args.output_raster, args.breaks)

if __name__ == '__main__':
    main()
