library(tidyverse)
library(igraph)
library(parallel)
library(futile.logger)
library(sf)

#jumped <- read.csv("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/jumps.csv")
#jump <- jumped$threshold
jump <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 2800, 2300, 
    3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 6600, 7000, 7500, 14500)

file_fulltree <- "/home/ucfnhbx/Scratch/hiery2/Full_tree.txt"
file_treegraph <- "/home/ucfnhbx/Scratch/hiery2/Tree_graph.txt"
file_queentree <- "/home/ucfnhbx/Scratch/hiery2/queentree.csv"
file_chopqueentree <- "/home/ucfnhbx/Scratch/hiery2/chopqueentree.csv"
file_roots <- "/home/ucfnhbx/Scratch/hiery2/roots.csv"
file_rootsgeojson <- "/home/ucfnhbx/Scratch/hiery2/rootsgeo.geojson"

treegraph <- read.table(file_treegraph, header=F, sep=' ')

# nodes to first clusters
roots <- treegraph %>%
  #dplyr::filter(substr(V1,1,1)=='L') %>%
  dplyr::filter(substr(V2,1,1)!='L') %>%
  dplyr::mutate(weight = jump[1])
tail(roots)
head(roots)
dim(roots)
# "V1","V2","weight"
write.csv(roots, file_roots, row.names = FALSE) # 772918

nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv")
nodes$osmid <- as.numeric(nodes$osmid)
roots$V1 <- as.numeric(roots$V1)
rootsgeo <- dplyr::inner_join(roots, nodes, by=c("V1"="osmid") ) %>%
  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
  st_transform(., crs =3035)
head(rootsgeo)
dim(rootsgeo)
write.csv(rootsgeo, file_rootsgeo, row.names = FALSE) # 774691
st_write(rootsgeo, file_rootsgeojson, append=TRUE)
#ggplot() + geom_sf(data=rootsgeo, aes(geometry=geometry))
#ggsave("/home/ucfnhbx/Scratch/hiery2/rootsgeoplot.png")

trunk <- treegraph %>%
  dplyr::filter(substr(V1,1,1)!='L') %>%
  dplyr::filter(substr(V2,1,1)=='L') %>%
  dplyr::mutate(weight = jump[2] - jump[1])
tail(trunk)
head(trunk)

branches <- treegraph %>%
  dplyr::filter(substr(V1,1,1)=='L') %>%
  dplyr::filter(substr(V2,1,1)=='L') %>%
  dplyr::mutate(weight1 = jump[as.numeric(str_extract(V1, "\\d+"))-1]) %>%
  dplyr::mutate(weight2 = jump[as.numeric(str_extract(V2, "\\d+"))-1]) %>%
  dplyr::mutate(weight = abs(weight2 - weight1)) %>%
  dplyr::select(!c(weight1, weight2))
tail(branches)
head(branches)

elw <- rbind(roots, trunk, branches)
tail(elw)
princessL <- paste0('L',(length(jump) + 1)) # penultimate level to the queen
allnodes <- c(elw$V1, elw$V2) %>% unique()
princessnodes <- allnodes[grep(princessL, allnodes)] #find
queenL <- paste0('L',(length(jump) + 2))
qjump <- 2*mean(jump - lag(jump, default = 0)) # arbitrarily as mean of all jumps, represents crossing the sea
crown <- cbind(V1 = princessnodes, V2 = c(queenL), weight=qjump)
tail(crown)
queentree <- rbind(elw, crown) # queen is weighted and crowned
tail(queentree)
write.csv(queentree, file_queentree, row.names = FALSE)
write.table(queentree, "/home/ucfnhbx/Scratch/hiery2/queentree.txt", append = FALSE, sep = " ", dec = ".",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

# tree no roots
#chopqueentree <- rbind(trunk, branches, crown) 
#write.csv(chopqueentree, file_chopqueentree, row.names = FALSE)

# sed 's/\"//g' file.txt > file_new.txt
# tr ',' ' ' < "headlessqueen4.txt" > "headlessqueen5.txt"
