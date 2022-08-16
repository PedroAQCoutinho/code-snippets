from appfunctions import soma, division
import logging


logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(levelname)s:%(name)s:%(message)s')
file_handler = logging.FileHandler('apprun.log')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)


a = 1
b = 0



try:
    print(division(a,b))
except ZeroDivisionError as e:
    logger.debug(f'Problem in division {a}/{b}. Error: {e}')
