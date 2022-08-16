import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(levelname)s:%(name)s:%(message)s')
file_handler = logging.FileHandler('appfunctions.log')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


def soma(a, b):
    logger.info(f'Run {a} + {b}')
    return a+b


def division(a, b):
    logger.info(f'Run {a}/{b}')
    return a/b



