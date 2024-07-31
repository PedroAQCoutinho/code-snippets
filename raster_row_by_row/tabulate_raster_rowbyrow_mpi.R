library(Rmpi)
library(snow)
library(dplyr)
library(parallel)
library(raster)
library(foreign)
library(RSQLite)
rm(list=ls())
##This code aims to tabulate a big raster row by row due to inssuficient memmory for the operations
##This is based on MPI parallel processing approach and was used in a cluster with several processing cores

#Load rasters

#Alligned rasters

prodes <- raster('/home/pedro/Documents/GIT_WORKSPACE/ICS-Priorizacao-CPD/rasters/pa_br_desmatamento_prodes_1-250000_2022.tif')
uf <- raster('/home/pedro/Documents/GIT_WORKSPACE/ICS-Priorizacao-CPD/rasters/pa_br_municipios_ibge_30m_2022.tif')


#Blocks
bss <- blockSize(prodes)
n <- bss$n



conn <- dbConnect(SQLite(), paste('/home/pedro/OneDrive/ICS/Oficinas_priorizacao_CPD/dados/prodes.sql', sep = ""))


#Operations over table function
fun_ex <- function(i){
	
  out <- data.frame(prodes = getValues(prodes,row = bss$row[i], nrows = bss$nrows[i]),
                    uf = getValues(uf,row = bss$row[i], nrows = bss$nrows[i]))
  
  out <- out %>%
    filter(!is.na(uf)) %>%
    mutate(uf = substr(uf, 1, 2)) %>%
    group_by(uf, prodes) %>%
    summarise(area = n()*0.087) %>%
    filter(prodes >= 8 & prodes <= 22)

	return(out)

}

exporta <- function(){
  
  #Parametros do cluster
  cl <- getCluster()
  on.exit(returnCluster())
  #Numero de nós
  nodes <- length(cl)
  
  #Distribui a funcao nos slaves
  for(i in 1:nodes){
    sendCall(cl[[i]], fun_ex, i, tag = i)
  }
  
  # Contador de iterações
  counter <- 0
  
  # Dispara os processos 
  for (i in 1:bss$n) {
    
    # Pega o resultado do processo que estver terminado e que esteja na fila
    d <- recvOneData(cl)
    
    # Se nao retornou resultado, erro salvo no erro.rds. É possivel verificar qual erro deu abrindo o arquivo
    if (!d$value$success) {
      saveRDS(d, 'erro.rds')
      cat('erro no numero: ', d$value$tag, '\n'); flush.console();
      stop('cluster error')
    }
    
    # Lógica de destribuicao de processos, nao me lembro...
    ni <- nodes + i
    if (ni <= bss$n) {
      sendCall(cl[[d$node]], fun_ex, ni, tag = ni)
    }
    
    # Se deu certo o processamento da funcao fun_ex ele retorna true
    b <- d$value$tag
    
    print(paste0('recebido: ', b))
    
    # Altera a tabela out
    if(!all(is.na(d$value$value))){
      
      # d$value$value é onde está armazenada a saída (tabela s) da função fun_ex
      tabela <- d$value$value
      
      # Inicia uma transação a cada 10 iterações
      if (counter %% 10 == 0) {
        dbBegin(conn)
      }
      
      dbWriteTable(conn, 'contagem', tabela , row.names = F, append = T)
      
      # Comita a transação a cada 10 iterações
      if (counter %% 10 == 9) {
        dbCommit(conn)
      }
      
      rm(d)
      
    }
    
    print(i)
    
    # Incrementa o contador
    counter <- counter + 1
  }
  
  # Certifique-se de comitar qualquer transação restante
  if (counter %% 10 != 0) {
    dbCommit(conn)
  }
  
  print("Finalizado")  
}


#Inicia o cluster de processamento
cl <- makeCluster(4, type = 'MPI', outfile='')
options(rasterClusterObject = cl)
options(rasterClusterCores = length(cl))
options(rasterCluster = TRUE)
options(rasterClusterExclude = NULL)
clusterEvalQ(cl, library(raster))
clusterEvalQ(cl, library(dplyr))
clusterEvalQ(cl, library(RSQLite))
clusterEvalQ(cl, library(DBI))
clusterExport(cl=cl,
	ls())
output <- exporta()


stopCluster(cl)
dbDisconnect(conn)


readRDS('erro.rds')

