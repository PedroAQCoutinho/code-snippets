library(jsonlite)
library(dotenv)

############
#CONFIG FILE
############

# Lendo o arquivo de configuração​

config <- fromJSON("config_env_files/config.json")

paths <- config$paths
ckan_recursos <- config$ckan_recursos
salvar_dados <- config$salvar_dados
auxiliares <- config$auxiliares
arquivos <- config$arquivos

source(paths$ckan_utils_path)
source(paths$biblioteca_path)


#leitura de arquivos
r1 <- raster(paste(paths$dados_path, arquivos$malha, sep = '/'))


cl <- makeCluster(auxiliares$num_nucleos)




############
#ENV FILE
############


dotenv::load_dot_env()

db_name <- Sys.getenv('DB_NAME')
db_password <- Sys.getenv('DB_PASSWORD')
db_port <- Sys.getenv('DB_PORT')
db_user <- Sys.getenv('DB_USER')
db_host <- Sys.getenv('DB_HOST')


con <- dbConnect(
  RPostgres::Postgres(),
  dbname = db_name,
  host = db_host, 
  port = db_port,       
  user = db_user,
  password = db_password
)


#Dentro do código init_ckanr() há um trecho que faz
#Sys.getenv('CKAN_KEY') e ussa essa key para fazer autenticação
ckan <- init_ckanr()






