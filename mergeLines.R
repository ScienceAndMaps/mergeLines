
require(sf)

### USER SETTINGS ####
input_file <- "" # e.g. lines.shp, put in same directory as this script
output_file <- "" # e.g. merged_lines.gpkg, will be overwritten if it already exists
wd <- paste0(dirname(rstudioapi::getSourceEditorContext()$path),"/") # if not running in RStudio, set wd to directory of this script, e.g. wd <- 'C:/Dir/'
######################


lines <- st_read(paste0(wd,input_file),stringsAsFactors=FALSE) # read in lines
lines <- lines[,!names(lines) %in% names(st_drop_geometry(lines))] # remove any attributes

nrow_start <- nrow(lines)
nrow_run <- nrow_start+1
ncol_start <- ncol(lines)

while (nrow_run > dim(lines)[1]) { # iterate through until complete
  
  nrow_run <- nrow(lines)
  
  lines$intersect_group <- unlist(map(st_intersects(lines),1)) # create grouping based on first line of intersection
  lines <- aggregate(lines, by=list(lines$intersect_group),FUN=first,do_union=TRUE)[,3] # aggregate data based on grouping
  
  print(paste0(nrow_start-nrow(lines)," features merged"))
  
}

if(!dir.exists(file.path(wd, "Outputs"))){dir.create(file.path(wd, "Outputs"))} # create output directory
st_write(lines,paste0(wd,"Outputs/",output_file),delete_dsn=TRUE) # output merged lines
