library(raster)
library(snow)
library(parallel)
library(Rmpi)

##This code aims to build a big raster row by row due to inssuficient memmory for the operations
##This is based on MPI parallel processing approach and was used in a cluster with several processing cores

#Load rasters
r1 <- raster('raster1.tif')
r2 <- raster('raster.tif')
#Create an alligned output which will be overwrited
output <- raster(r1)
#Create blocks
bss <- blockSize(output, minblocks = 10000)

#Function for table management
fun_ex <- function(i){
	#Get table
	db <- data.frame(
		ras1 = getValues(r1, row = bss$row[i], nrows = bss$nrows[i]),
		ras2 = getValues(r2, row = bss$row[i], nrows = bss$nrows[i]),
		out = NA)

	#if operations
	sp <- which(db$ras2==10)
	if(length(sp) > 0) db[sp, 'out'] <- db[sp, 'ras1']
	return(db$out)
			
}
 


#Function for exporting results
exporta <- function(x){
         out <- raster(x)
         cl <- getCluster()
         on.exit(returnCluster())
         nodes <- length(cl)
 	 #Put the functions in the nodes
         for(i in 1:nodes){
 			sendCall(cl[[i]], fun_ex, i, tag = i)
         }
 
	#Start writing
         out <- writeStart(out,
           filename = 'raster_output.tif',
           datatype = 'INT2U',
           format='raster'
        
		)
	#Spread the blocks over the processes
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

	#Write and export
     out <- writeStop(out)
      return(list(out))
                 
 
 }
 
 #Cluster start
cl <- makeCluster(168, type = 'MPI', outfile='')
options(rasterClusterObject = cl)
options(rasterClusterCores = length(cl))
options(rasterCluster = TRUE)
options(rasterClusterExclude = NULL)
 
 #Load libraries
clusterEvalQ(cl, library(raster))
clusterExport(cl=cl,
	ls())

#Run
output <- exporta(output)
stopCluster(cl)
