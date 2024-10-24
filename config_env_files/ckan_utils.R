library(pacman)
p_load(httr, jsonlite, ckanr, stringr)

address <- "https://repositorio.gppesalq.agr.br"
key <- Sys.getenv("CKAN_KEY")



init_ckanr <- function(){
  ckan = ckanr_setup(url = address,key = key)
  
}





download_all_resources <- function(dataset_id, path){
  resources = package_show(id = dataset_id)
  
  for(resource in resources$resources){
    download_resource_to_disk(resource,path)
  }
  
}

download_resource <- function(resource_id,path){
  resource = resource_show(resource_id)
  if (tail(str_split_1(resource$url, '/'),n=1) %in% list.files(path)) {
    
    print('Arquivo ja baixado')
    return(list(path = paste0(path, tail(str_split_1(resource$url, '/'),n=1) )))
    
  } else {
    
    return(download_resource_to_disk(resource,path))
    
  }
  
}

download_resource_to_disk <- function(resource, path){
  filename <- tail(str_split_1(resource$url, '/'),n=1)
  print(paste("Download file:",filename))
  
  ckan_fetch(resource$url, "disk", paste(path,filename,sep = ""))
}

get_resource <- function(resource_id, sep=','){
  resource = resource_show(resource_id)
  
  return(ckan_fetch(resource$url,sep=sep))
}

get_all_resources <- function(dataset_id, format=NULL, sep=','){
  resources_v = c()
  
  resources = package_show(id = dataset_id)
  
  for(resource in resources$resources){
    if(!is.null(format) && toupper(resource$format) == toupper(format)){
      print(resources_v)
      resources_v <- c(resources_v, get_resource(resource$id, sep=sep))
    }
    else if(is.null(format)){
      resources_v <- c(resources_v, get_resource(resource$id, sep=sep))
    }
  }
  
  return(resources_v)
}