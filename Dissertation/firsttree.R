library(sf)
library(ggplot2)
library(tidyverse)

########## tree match

# queentree
queentree <- read.table("/home/ucfnhbx/Scratch/hiery2/queentree_.csv", header=T, sep=',')
dim(queentree)
# list of values in queentree
#queenz <- rbind(queentree$V1, queentree$V2) #%>%
  #str_remove(., "L.*_")
#intree <- fulltree %>% 
#  dplyr::filter( id_cluster %in% queenz) %>%
#  dplyr::arrange(p_ds)

# fulltree
fulltree <- read.csv("/home/ucfnhbx/Scratch/hiery2/Full_tree.txt", sep=' ') 
dim(fulltree)
head(fulltree)

jumps <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 
          2800, 2300, 3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 
          6600, 7000, 7500, 14500)
          
# find the queentree cluster name "L#_" in for each id_point listed in fulltree
intree <- fulltree %>% 
  dplyr::mutate( 
    new_id_cluster = dplyr::case_when( 
      p_ds == 300 ~ as.character(id_cluster),
      p_ds != 300 ~ paste0("L", match(p_ds, jumps)+1, "_", id_cluster)
      )) %>%
  dplyr::filter( (new_id_cluster %in% queentree$V1) | (new_id_cluster %in% queentree$V2) ) %>%
  dplyr::arrange(p_ds)
dim(intree)
head(intree)
tail(intree)

# find lowest threshold for each id, i.e. D3 leaf nodes
firsttree <- intree[match( unique(intree$ID_points), intree$ID_points),]
#write.csv(firsttree, "/home/ucfnhbx/Scratch/hiery2/firsttree.csv", row.names = FALSE)
dim(firsttree)
head(firsttree)
tail(firsttree)

# add geo from nodes
firsttree_geo <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv") %>%
  dplyr::inner_join(., firsttree, by=c("osmid"="ID_points") ) %>%
  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
  st_transform(., crs =3035) #9.5G
#st_write(firsttree_geo, "/home/ucfnhbx/Scratch/hiery2/firsttree.geojson", append=TRUE)
dim(firsttree_geo)
head(firsttree_geo)
#firsttree_geo <- st_read("/home/ucfnhbx/Scratch/hiery2/firsttree.geojson")

# find leafnodes in the mask of study area
#mainland <- st_read("/home/ucfnhbx/Scratch/data/geo/mainland.geojson") %>% st_transform(crs=3035)
#essnuts <- st_read("/home/ucfnhbx/Scratch/hiery2/essnuts.geojson")
#datamask <- st_union(essnuts) %>% st_intersection(mainland, essnuts$geometry)
#st_write(datamask, "/home/ucfnhbx/Scratch/coco2/datamask.geojson")
datamask <- st_read("/home/ucfnhbx/Scratch/coco2/datamask.geojson")
masktree <- st_intersection(firsttree_geo, datamask)
dim(masktree)
head(masktree)
tail(masktree)
write.csv(masktree, "/home/ucfnhbx/Scratch/hiery2/masktree.csv", row.names = FALSE)
#masktree <- st_read("/home/ucfnhbx/Scratch/hiery2/masktree.geojson")

# plot
ggplot() + 
  theme_light() +
  geom_sf(data=masktree, aes(geometry=geometry, color="Intersections"), size=0.1) +
  geom_sf(data=datamask, aes(geometry=geometry, color="Study Area"), fill=NA, size=0.5) +
  guides(color=guide_legend(title="Data Extent"))
ggsave("/home/ucfnhbx/Scratch/hiery2/firsttree.png")

st_write(masktree, "/home/ucfnhbx/Scratch/hiery2/masktree.geojson")