library(raster)
library(snow)
library(parallel)
library(Rmpi)

rm(list=ls())
##This code aims to build a big raster row by reofipjweiofw due to inssuficient memmory for the operations
##This is based on MPI parallel processing approach and was used in a cluster with several processing cores

#Load rastersa
r1 <- raster('path/to/raster1')
r2 <- raster('path/to/raster1')
#Create an alligned output which will be overwrited
output <- raster(r1)
#Create blocks
bss <- blockSize(output, minrows = 50); bss


#Function for table management
fun_ex <- function(i){
	#Get table
	db <- data.frame(
		ras1 = getValues(r1, row = bss$row[i], nrows = bss$nrows[i]),
		ras2 = getValues(r2, row = bss$row[i], nrows = bss$nrows[i]),
		out = NA)

	#if operations
	sp <- which(is.na(db$ras2))
	if(length(sp) > 0) db[sp, 'out'] <- 15
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
           filename = '/home/pedro/Documents/GIT_WORKSPACE/code-snippets/raster_row_by_row/rasters_prototipo/raster_output.tif',
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
cl <- makeCluster(2, type = 'MPI', outfile='')
options(rasterClusterObject = cl)
options(rasterClusterCores = length(cl))
options(rasterCluster = TRUE)
options(rasterClusterExclude = NULL)
 
 #Load libraries
clusterEvalQ(cl, library(raster))
clusterExport(cl=cl,
	ls())

#Run
system.time(output <- exporta(output))
stopCluster(cl)


sleep(1)
