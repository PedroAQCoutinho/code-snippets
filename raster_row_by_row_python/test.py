import argparse






if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Processar raster e armazenar blocos no PostgreSQL.')
    parser.add_argument('raster_path', type=str, help='Caminho para o arquivo raster')


    args = parser.parse_args()



print(args.raster_path)