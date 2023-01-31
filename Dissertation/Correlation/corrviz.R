library(sf)
#install.packages("lsa", repos = "http://cran.us.r-project.org")
library(lsa)
#library(futile.logger)
#install.packages("futile.logger")
library(parallel)
library(tidyverse)
library(magrittr)

##### scratch
file_eigs <- "/home/ucfnhbx/Scratch/data/dna/NovPCAeigs-20220627.txt"
file_nuts <- "/home/ucfnhbx/Scratch/data/ess/NUTS_RG_20M_2021_4326-20220626.geojson"
file_ess <- "/home/ucfnhbx/Scratch/data//ess/ESS9-20220626.csv"
file_mainland <- "/home/ucfnhbx/Scratch/data/geo/mainland.geojson"
file_dna <- "/home/ucfnhbx/Scratch/data/dna/Nov2008_predict-20220627.csv"
file_pca <- "/home/ucfnhbx/Scratch/data/dna/Nov2008_PCA-20220622.txt"
file_colors <- "/home/ucfnhbx/Scratch/data/dna/ColorTablePCmap-20220627edit.txt"

#### plots and geojson
file_dnaplot <- "/home/ucfnhbx/Scratch/coco2/dnaplot.png"
file_combineplot <- "/home/ucfnhbx/Scratch/coco2/combineplot.png"
file_datamask <- "/home/ucfnhbx/Scratch/coco2/datamask.geojson"
file_rootsgeo <- "/home/ucfnhbx/Scratch/hiery2/rootsgeo.csv"
file_rootsgeojson <- "/home/ucfnhbx/Scratch/hiery2/rootsgeo.geojson"
file_rootspop <- "/home/ucfnhbx/Scratch/hiery2/rootspop.geojson"
file_vor <- "/home/ucfnhbx/Scratch/hiery2/vor.geojson"
file_essnuts <- "/home/ucfnhbx/Scratch/hiery2/essnuts.geojson"

##### ucl drive
file_eigs <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/dna/NovPCAeigs-20220627.txt"
file_nuts <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/ess/NUTS_RG_20M_2021_4326-20220626.geojson"
file_ess <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/ess/ESS9-20220626.csv"
file_mainland <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/geo/mainland.geojson"
file_dna <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/dna/Nov2008_predict-20220627.csv"
file_pca <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/dna/Nov2008_PCA-20220622.txt"
file_colors <- "/Volumes/ucfnhbx/Documents/GitHub/MScSDSV_Dissertation/Data/dna/ColorTablePCmap-20220627edit.txt"

#######################
####################### ess
nuts <- st_read(file_nuts) %>%
  dplyr::select(c(NUTS_ID, LEVL_CODE, CNTR_CODE, geometry)) %>%
  st_transform(crs=3035)
#dplyr::sample_n(nuts, 10)

#check
#data <- nuts %>% dplyr::filter(LEVL_CODE==0)
#head(data$NUTS_ID)
#ggplot(data=data)+
#  geom_sf(aes(geometry=geometry))
#head(data)

# ess with nuts
ess <- read.csv(file_ess, header=TRUE ) %>%
  dplyr::select(c(region, regunit, cntry, ipcrtiv:impfun ))
  #dplyr::filter(c(ipcrtiv:impfun) == c(7,8,9))
#head(ess)

# ess test, indeed, only 1 nuts layer per country
#nestednuts <- read.csv(file_ess, header=TRUE ) %>% 
#  group_by(cntry) %>% 
#  summarise(count = n_distinct(regunit))
#nestednuts$count %>% n_distinct()

essnuts <- ess %>%
  dplyr::group_by(region) %>%
  dplyr::summarise(dplyr::across(ipcrtiv:impfun, mean, na.rm=TRUE))%>%
  dplyr::left_join(nuts, by = c("region" = "NUTS_ID"))%>%
  st_as_sf()
#head(essnuts)
st_write(essnuts, file_essnuts, append=FALSE)

#values <- colnames(essnuts)[2:22]
#file_essplot <- "/home/ucfnhbx/Scratch/coco2/essplot/essplot_"
#for (val in values) {
#  ggplot(data = essnuts) +
#    geom_sf(aes_string(geometry="geometry", fill=val), color = NA) +
#    guides(fill=guide_legend(title="Average Response")) +
#    scale_fill_continuous(trans = 'reverse')
#  ggsave(paste0(file_essplot,val,".png"))
#}

################
################ dna
eigs <- read.table(file_eigs) %>%
  dplyr::rename(id = V1) %>%
  dplyr::select(!c(V2, V23))
head(eigs)

colors <- read.delim(file_colors, header = F)
head(colors)

pca <- read.delim(file_pca) %>%
  dplyr::left_join(., colors, by=c("plabels"="V1")) #%>%
  #st_as_sf(coords = c("longitude","latitude"), crs=4326)%>%
  #st_transform(crs=3035)
head(pca)
dim(pca)

# transformed dna coordinates, 1387 rows
dna <- read.csv(file_dna, header=TRUE)%>%
  dplyr::rename(id = V1, lon = V2, lat = V3)%>%
  dplyr::left_join(pca, by= c("id"="ID")) %>%
  st_as_sf(coords = c("lon","lat"), crs=4326)%>%
  st_transform(crs=3035)
head(dna)

# generate voronoi polygons
#https://gis.stackexchange.com/questions/362134/i-want-to-create-a-voronoi-diagram-while-retaining-the-data-in-the-data-frame
vor <- st_voronoi(st_combine(st_geometry(dna)), dTolerance=0) %>%
  st_collection_extract()%>%
  #data.frame() %>%
  st_as_sf() %>%
  st_join(dna)
tail(vor)
head(vor)
st_write(vor, file_vor, append=FALSE)
#dt$slocationzone <-  sf::st_sfc( sapply( dt$slocationzone, `[`) )
#https://stackoverflow.com/questions/56862241/sf-object-created-as-list-in-r-data-table

col <- as.character(dna$V2)
names(col) <- as.character(dna$plabels)
head(col)

mainland <- st_read(file_mainland) %>%
  st_transform(crs=3035)
  
# dnaplot
ggplot() + 
  geom_sf(data=mainland, mapping = aes(geometry=geometry), fill="white", lwd=0.2) +
  geom_sf(data=dna, mapping = aes(geometry=geometry, color=factor(plabels)), size = 0.1) +
  geom_sf(data=vor, mapping=aes(geometry=geometry), alpha=0, lwd=0.2) +
  scale_color_manual(values=col, name = "Country", guide = guide_legend(override.aes = list(size = 2, alpha = 1) ) )
#ggsave(file_dnaplot, scale=3)

###################
library(raster)
library(terra)
################### combine
#ggplot() + 
#  theme_light() +
#  geom_sf(data=mainland, aes(geometry=geometry, fill="Landmass"), fill='green', size=0) +
#  geom_sf(data=st_as_sfc(st_bbox(vor)), aes(geometry=geometry, color="Genetics"), fill=NA, size=1) +
#  geom_sf(data=st_union(essnuts), aes(geometry=geometry, color="Human Values Scale"), fill=NA, size=0.5) #+
  #guides(color=guide_legend(title="Data Boundaries"))+
#ggsave(file_combineplot)

#overlap boundaries
ggplot() + 
  theme_light() +
  geom_sf(data=mainland, 
          aes(geometry=geometry, color='darkolivegreen3'), fill='darkolivegreen3', size=0) +
  geom_sf(data=st_as_sfc(st_bbox(vor)), 
          aes(geometry=geometry, color='salmon'), fill='NA', size=1) +
  geom_sf(data=st_union(essnuts), 
          aes(geometry=geometry, color='purple'), fill='NA', size=0.5) +
  scale_color_identity(name = "Data",
                       breaks = c('darkolivegreen3', 'purple','salmon'),
                       labels = c("Continental Europe", "Cultural Values","Genetics"),
                       guide = guide_legend(override.aes = list( fill = c('darkolivegreen3',NA,NA)
                                                                )))
#https://aosmith.rbind.io/2018/07/19/manual-legends-ggplot2/#descriptive-strings-and-scale_color_manual


################## datamask
#rootsgeojson <- st_read(file_rootsgeojson)
mainland <- st_read(file_mainland) %>%
  st_transform(crs=3035)
#datamask <- st_read(file_datamask)
#rootspop <- st_read(file_rootspop)
essnuts <- st_read(file_essnuts)
vor <- st_read(file_vor)

datamask <- st_intersection(mainland, essnuts$geometry) %>%
  st_intersection(., vor, left=F) %>%
  st_union()
st_write(datamask, file_datamask, append=FALSE)

#rootspop <- st_intersection(rootsgeojson, datamask)
#st_write(rootspop, file_rootspop, append=FALSE)

file_datamaskplot <- "/home/ucfnhbx/Scratch/coco2/datamaskplot.png"
file_datamaskessplot <- "/home/ucfnhbx/Scratch/coco2/datamaskessplot.png"
file_datamaskdnaplot <- "/home/ucfnhbx/Scratch/coco2/datamaskdnaplot.png"

ggplot() + 
  theme_light() +
  #geom_sf(data=rootsgeojson, aes(geometry=geometry, color="Intersections Excluded"), size=0.1) +
  #geom_sf(data=rootspop, aes(geometry=geometry, color="Intersections Included"), size=0.1) +
  geom_sf(data=datamask, aes(geometry=geometry, color="Study Area"), fill=NA, size=0.5) +
  guides(color=guide_legend(title="Data Extent"))
ggsave(file_datamaskplot)


############ firsttree plot
firsttree_geo <- st_read("/home/ucfnhbx/Scratch/hiery2/firsttree.geojson")
datamask <- st_read("/home/ucfnhbx/Scratch/coco2/datamask.geojson")
#essnuts <- st_read("/home/ucfnhbx/Scratch/hiery2/essnuts.geojson")
#vor <- st_read("/home/ucfnhbx/Scratch/hiery2/vor.geojson")

ggplot() + 
  theme_light() +
  geom_sf(data=firsttree_geo, aes(geometry=geometry, color="Intersections"), size=0.1) +
  geom_sf(data=datamask, aes(geometry=geometry, color="Study Area"), fill=NA, size=0.5) +
  guides(color=guide_legend(title="Data Extent"))
ggsave("/home/ucfnhbx/Scratch/hiery2/firsttree.png")



"ggplot() + 
  theme_light() +
  geom_sf(data=essnuts, aes(geometry=geometry, color="Human Values Scale"), fill=NA, size=0.5) +
  geom_sf(data=rootspop, aes(geometry=geometry, color="Intersections Included"), size=0.1) +
  #geom_sf(data=datamask, aes(geometry=geometry, color="Study Area"), fill=NA, size=0.5) +
  guides(color=guide_legend(title="Data Extent"))
ggsave(file_datamaskessplot)

ggplot() + 
  theme_light() +
  geom_sf(data=vor, mapping=aes(geometry=geometry, color="Genetics"), alpha=0, lwd=0.2) +
  geom_sf(data=rootspop, aes(geometry=geometry, color="Intersections Included"), size=0.1) +
  #geom_sf(data=datamask, aes(geometry=geometry, color="Study Area"), fill=NA, size=0.5) +
  guides(color=guide_legend(title="Data Extent"))
ggsave(file_datamaskessplot)
