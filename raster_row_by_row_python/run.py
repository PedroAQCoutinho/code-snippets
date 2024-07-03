import rasterio
import psycopg2
import multiprocessing as mp
import argparse
from dotenv import load_dotenv
import os
import logging
import pandas as pd
import math

def init_logger():
    logging.basicConfig(filename='processamento_raster.log', level=logging.INFO, 
                        format='%(asctime)s - %(levelname)s - %(message)s')
    return logging.getLogger()

def process_block(blocks, table_name, column_names, db_params, group_by_columns, aggregations, i, total_blocks):
    logger = init_logger()
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()

    # Combine os valores dos blocos em uma lista de tuplas
    combined_values = list(zip(*[block.flatten().tolist() for block in blocks]))

    # Crie um DataFrame a partir dos valores combinados
    df = pd.DataFrame(combined_values, columns=column_names)

    # Execute o agrupamento e sumarização
    grouped_df = df.groupby(group_by_columns).agg(aggregations).reset_index()

    # Construa a string de inserção
    columns_str = ','.join(grouped_df.columns)
    values_str = ','.join(['%s' for _ in grouped_df.columns])
    insert_query = f"INSERT INTO {table_name} ({columns_str}) VALUES ({values_str})"

    # Insira os valores agrupados no banco de dados
    for _, row in grouped_df.iterrows():
        cur.execute(insert_query, tuple(row))

    conn.commit()

    # Log a inserção dos dados
    logger.info(f'Inserido {i} de um total de {total_blocks} blocos.')

    # Feche a conexão com o banco de dados
    cur.close()
    conn.close()

def iterate_raster_blocks_and_store(raster_paths, table_name, num_cores, group_by_columns, aggregations, logger, max_blocks=None):
    # Parâmetros do banco de dados carregados do arquivo .env
    db_params = {
        'dbname': os.getenv('DB_NAME'),
        'user': os.getenv('DB_USER'),
        'password': os.getenv('DB_PASSWORD'),
        'host': os.getenv('DB_HOST'),
        'port': os.getenv('DB_PORT')
    }

    # Gerar nomes das colunas a partir dos nomes dos arquivos raster
    column_names = [os.path.splitext(os.path.basename(path))[0] for path in raster_paths]

    # Conecte-se ao banco de dados PostgreSQL
    conn = psycopg2.connect(**db_params)
    cur = conn.cursor()
    
    # Verifique se a tabela já existe
    cur.execute(f"""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = '{table_name}'
        );
    """)
    table_exists = cur.fetchone()[0]

    if table_exists:
        # Se a tabela existe, delete-a ou trunque-a
        logger.info(f"Tabela {table_name} já existe. Deletando a tabela.")
        cur.execute(f"DROP TABLE {table_name}")
        conn.commit()
        logger.info(f"Tabela {table_name} deletada.")
    else:
        logger.info(f"Tabela {table_name} não existe. Nenhuma ação de deletar necessária.")

    # Crie a tabela no banco de dados
    logger.info(f"Criando tabela {table_name}.")
    columns_definition = ', '.join([f"{col} FLOAT" for col in column_names])
    cur.execute(f"""
        CREATE TABLE {table_name} (
            id SERIAL PRIMARY KEY,
            {columns_definition}
        )
    """)
    conn.commit()
    logger.info(f"Tabela {table_name} criada.")

    # Abra todos os arquivos raster
    src_files = [rasterio.open(path) for path in raster_paths]

    # Determine o tamanho do bloco com base no número máximo de blocos
    if max_blocks:
        width = src_files[0].width
        height = src_files[0].height
        total_pixels = width * height
        pixels_per_block = math.ceil(total_pixels / max_blocks)
        block_width = block_height = int(math.sqrt(pixels_per_block))
        block_width = min(block_width, width)
        block_height = min(block_height, height)
    else:
        block_width, block_height = src_files[0].block_shapes[0]

    total_blocks_x = math.ceil(width / block_width)
    total_blocks_y = math.ceil(height / block_height)
    total_blocks = total_blocks_x * total_blocks_y

    # Prepare a pool de processos
    pool = mp.Pool(processes=num_cores)

    # Lista para armazenar os objetos de resultado
    results = []

    # Itere sobre cada bloco
    block_idx = 0
    for y in range(0, height, block_height):
        for x in range(0, width, block_width):
            window = rasterio.windows.Window(x, y, min(block_width, width - x), min(block_height, height - y))

            # Leia os blocos de todos os rasters
            blocks = [src.read(window=window) for src in src_files]

            # Processa o bloco em paralelo e armazena o resultado
            block_idx += 1
            result = pool.apply_async(process_block, args=(blocks, table_name, column_names, db_params, group_by_columns, aggregations, block_idx, total_blocks))
            results.append(result)

            # Log progresso
            logger.info(f'Executada iteração {block_idx} de {total_blocks} iterações')

    # Espere que todos os processos sejam concluídos
    for result in results:
        result.wait()

    # Feche a pool de processos
    pool.close()
    pool.join()

    # Feche todos os arquivos raster
    for src in src_files:
        src.close()

    # Feche a conexão com o banco de dados
    cur.close()
    conn.close()

def load_rasters_from_folder(folder_path):
    raster_files = [os.path.join(folder_path, f) for f in os.listdir(folder_path) if f.endswith('.tif')]
    return raster_files

if __name__ == '__main__':
    # Impedir que o código seja executado novamente ao criar novos processos
    mp.set_start_method('spawn', force=True)

    # Carregar variáveis de ambiente do arquivo .env
    load_dotenv()

    # Configurar o logger
    logger = init_logger()

    parser = argparse.ArgumentParser(description='Processar rasters e armazenar blocos no PostgreSQL.')
    parser.add_argument('-r', '--raster-paths', type=str, nargs='+', help='Caminhos para os arquivos raster')
    parser.add_argument('-f', '--folder-path', type=str, help='Caminho para a pasta contendo os arquivos raster')
    parser.add_argument('-t', '--table-name', type=str, required=True, help='Nome da tabela no banco de dados')
    parser.add_argument('-n', '--num-cores', type=int, required=True, help='Número de núcleos para paralelizar')
    parser.add_argument('-g', '--group-by', type=str, nargs='+', required=True, help='Campos para agrupar')
    parser.add_argument('-a', '--aggregations', type=str, nargs='+', required=True, help='Campos e funções para agregação no formato campo:funcao')
    parser.add_argument('--max-blocks', type=int, help='Número máximo de blocos em que os dados serão divididos')

    args = parser.parse_args()

    if args.folder_path:
        raster_paths = load_rasters_from_folder(args.folder_path)
    else:
        raster_paths = args.raster_paths

    # Parse the aggregations argument into a dictionary
    aggregations = {agg.split(':')[0]: agg.split(':')[1] for agg in args.aggregations}

    iterate_raster_blocks_and_store(raster_paths, args.table_name, args.num_cores, args.group_by, aggregations, logger, args.max_blocks)
