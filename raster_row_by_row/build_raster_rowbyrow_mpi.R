library(raster)
library(snow)
library(parallel)
library(Rmpi)


r1 <- raster('raster1.tif')
r2 <- raster('raster.tif')

output <- raster(r1)
bss <- blockSize(output, minblocks = 10000)
 
fun_ex <- function(i){
			db <- data.frame(
					ras1 = getValues(r1, row = bss$row[i], nrows = bss$nrows[i]),
					ras2 = getValues(r2, row = bss$row[i], nrows = bss$nrows[i]),
					out = NA)
				

			sp <- which(db$ras2==10)
				
			if(length(sp) > 0) db[sp, 'out'] <- db[sp, 'ras1']

			return(db$out)
			
}
 



exporta <- function(x){
         out <- raster(x)
         cl <- getCluster()
         on.exit(returnCluster())
         nodes <- length(cl)
 
         for(i in 1:nodes){
 			sendCall(cl[[i]], fun_ex, i, tag = i)
         }
 
         out <- writeStart(out,
           filename = 'raster_output.tif',
           datatype = 'INT2U',
           format='raster'
        
		)
 
         for (i in 1:bss$n) {

 			d <- recvOneData(cl)
 
 			if (!d$value$success) {
 					saveRDS(d, 'erro.rds')
 					cat('erro no numero: ', d$value$tag, '\n'); 
					flush.console();
 					stop('cluster error')
 			}
 
 			ni <- nodes + i
 			if (ni <= bss$n) {
 					sendCall(cl[[d$node]], fun_ex, ni, tag = ni)
 			}
 
 			b <- d$value$tag

 			print(paste0('recebido: ', b))
 
 			out <- writeValues(out, d$value$value, bss$row[b])
   		rm(d)
        
		}

 		#Exporta os dados
     out <- writeStop(out)
      return(list(out))
                 
 
 }
 
 #Inicia o cluster de processamento
cl <- makeCluster(168, type = 'MPI', outfile='')
options(rasterClusterObject = cl)
options(rasterClusterCores = length(cl))
options(rasterCluster = TRUE)
options(rasterClusterExclude = NULL)
 
 #Carrega bibliotecas no cluster
clusterEvalQ(cl, library(raster))
clusterExport(cl=cl,
	ls())
 
output <- exporta(output)
stopCluster(cl)