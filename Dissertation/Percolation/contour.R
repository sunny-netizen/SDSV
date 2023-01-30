module load beta-modules
module -f unload compilers mpi gcc-libs
module load r/recommended
export R_LIBS=/home/ucfnhbx/Scratch/lib/r/site-packages:$R_LIBS
R

library(tidyverse)
library(sf)

# list of all geo   # osmid  y   x   geometry
nodes <- read.csv('/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv')
head(nodes)
dim(nodes) #23583851        4

# threshold
p<-100

# list of cluster sizes # "ID" "n_points"
clust <- read.csv(paste0('/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/cluster_sizes/clust_size_p',p,'.txt'), sep = " ")
head(clust)

# find cluster id of lcc
lcc <- clust[order(clust$n_points, decreasing = T),][1,]$ID
head(lcc)

# list of intersections in each cluster #"id_point","id_cluster"
memb <- read.csv(paste0('/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/membTables/membership',p,'.txt'))
head(memb)

# find members of lcc   # "id_point","id_cluster"
lccmemb <- memb %>% dplyr::filter(id_cluster==lcc)
head(lccmemb)
dim(lccmemb) #48960     2


#lccnodes <- dplyr::left_join(nodes, lccmemb, by=c('osmid'='id_point'))

# find geo of lcc members
lccmembgeo <- dplyr::left_join(lccmemb, nodes, by=c('id_point'='osmid')) %>% 
  st_as_sf(coords = c("x", "y"), crs = 4326)
head(lccmembgeo)

gg <- ggplot(lccmembgeo) + geom_sf()
ggsave(gg, file='/home/ucfnhbx/Scratch/contour.png')


gg <- ggplot()

lccmemb$id_point %in% nodes$osmid


