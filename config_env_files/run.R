library(jsonlite)
library(dotenv)



source("https://raw.githubusercontent.com/PedroAQCoutinho/code-snippets/main/config_env_files/ckan_utils.R")



# rm(list=ls())
############
#CONFIG FILE
############

# Lendo o arquivo de configuração
config <- fromJSON("config.json")



paths <- config$paths
ckan_recursos <- config$ckan_recursos
salvar_dados <- config$salvar_dados
auxiliares <- config$auxiliares
arquivos <- config$arquivos

#Fazer conexoes
load_dot_env(file = '.env') #Sistema operacional ja pussui a var armazenada

############
#ENV FILE
############

db_name <- Sys.getenv('DB_NAME')
db_password <- Sys.getenv('DB_PASSWORD')
db_port <- Sys.getenv('DB_PORT')
db_user <- Sys.getenv('DB_USER')
db_host <- Sys.getenv('DB_HOST')









