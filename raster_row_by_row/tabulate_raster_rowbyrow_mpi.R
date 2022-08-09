library(Rmpi)
library(snow)
library(parallel)
library(raster)
library(foreign)


#Alligned rasters
r1 <- raster('raster1.tif')
r2 <- raster('raster2.tif')

a.out <- data.frame(seq_numb = 1:20000)
a.out$n  <- 0
bss <- blockSize(xav, minblocks = 15000)
n <- bss$n


fun_ex <- function(i){
	
  db <- data.frame(
		ras1 = getValues(r1, row = bss$row[i], nrows = bss$nrows[i]),
		ras2 = getValues(r2, row = bss$row[i], nrows = bss$nrows[i]))

	#Operacao 1
	db$out <- NA
  	na <- which(db$r1 == 15)

	if(length(na) > 0) { db[na, 'out'] <- 1  }


  	db <- db[which(!is.na(db$ras2)),]
  
	if(all(is.na(db$out))){
		s <- NA
	} else {
		s <- aggregate(db$out ~ db$ras2, FUN = sum)
		colnames(s) <- c('ras2', 'soma')
	
  	}

	return(s)

}


exporta <- function(){

        cl <- getCluster()
        on.exit(returnCluster())
        nodes <- length(cl)

        for(i in 1:nodes){
			sendCall(cl[[i]], fun_ex, i, tag = i)
        }

        for (i in 1:bss$n) {
			
      d <- recvOneData(cl)

			if (!d$value$success) {
				saveRDS(d, 'erro.rds')
				cat('erro no numero: ', d$value$tag, '\n'); flush.console();
				stop('cluster error')
			}

			ni <- nodes + i
			if (ni <= bss$n) {
				sendCall(cl[[d$node]], fun_ex, ni, tag = ni)
			}

	  	b <- d$value$tag
      print(paste0('recebido: ', b))

			if(!all(is.na(d$value$value))){
      a.out[match(s[,1], a.out[,1]), 'soma'] <- d$value$value[,2]
			}
      
			rm(d)
      
      }
        
		saveRDS(a.out, '/mnt/nfs/home/atlas/arquivos/temporarios/DSSAT_pasture/pasture/grid/contagem.rds')

  
        return(NULL)
}

#Inicia o cluster de processamento
cl <- makeCluster(80, type = 'MPI', outfile='')
options(rasterClusterObject = cl)
options(rasterClusterCores = length(cl))
options(rasterCluster = TRUE)
options(rasterClusterExclude = NULL)
clusterEvalQ(cl, library(raster))
clusterExport(cl=cl,
	list('a.out', 'fun_ex', 'bss', 'xav', 'b'))
output <- exporta()
stopCluster(cl)




