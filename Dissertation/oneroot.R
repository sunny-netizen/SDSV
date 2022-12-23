library(dplyr)
library(sf)

jump <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 2800, 2300, 
    3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 6600, 7000, 7500, 14500)

# Inputs
file_fulltree <- "/home/ucfnhbx/Scratch/hiery2/Full_tree.txt"
file_treegraph <- "/home/ucfnhbx/Scratch/hiery2/Tree_graph.txt"

# Outputs
file_queentree <- "/home/ucfnhbx/Scratch/hiery2/queentree.csv"
file_chopqueentree <- "/home/ucfnhbx/Scratch/hiery2/chopqueentree.csv"
#file_leaves <- "/home/ucfnhbx/Scratch/hiery2/leaves.csv"
#file_leavesgeojson <- "/home/ucfnhbx/Scratch/hiery2/leavesgeo.geojson"

# load the edgelist of the dendrogram, "V1","V2"
treegraph <- read.table(file_treegraph, header=F, sep=' ')
head(treegraph)
dim(treegraph)

# check should not exist
treegraph %>%
  dplyr::filter(substr(V1,1,1)=='L') %>% 
  dplyr::filter(substr(V2,1,1)!='L')

# V1 is L1 intersections, V2 is L2 first clusters
leaves <- treegraph %>%
  dplyr::filter(substr(V2,1,1)!='L') %>%
  dplyr::mutate(V1 = paste0('L1_',V1)) %>%
  dplyr::mutate(V2 = paste0('L2_',V2)) #%>%
  #dplyr::mutate(height = jump[1])
tail(leaves)
head(leaves)
dim(leaves)

# V1 is L2, V2 is L3
branches <- treegraph %>%
  dplyr::filter(substr(V1,1,1)!='L') %>%
  dplyr::filter(substr(V2,1,1)=='L') %>%
  dplyr::mutate(V1 = paste0('L2_',V1)) #%>%
  #dplyr::mutate(height = jump[2])
tail(branches)
head(branches)

# V1 is L3 and above, V
trunk <- treegraph %>%
  dplyr::filter(substr(V1,1,1)=='L') %>%
  dplyr::filter(substr(V2,1,1)=='L') #%>%
  #dplyr::mutate(weight1 = jump[as.numeric(str_extract(V1, "\\d+"))-1]) %>%
  #dplyr::mutate(weight2 = jump[as.numeric(str_extract(V2, "\\d+"))-1]) %>%
 # dplyr::mutate(weight = abs(weight2 - weight1)) %>%
  #dplyr::select(!c(weight1, weight2)) 
tail(trunk)
head(trunk)

# find orphans that are not L1
elw <- rbind(leaves, branches, trunk)
tail(elw)
elw1 <- elw$V1 %>% unique()
elw2 <- elw$V2 %>% unique()
length(elw1)
length(elw2)
elww <- data.frame(c(elw1, elw2)) %>%
  dplyr::rename(id = c.elw1..elw2.) %>%
  group_by(id) %>%
  summarise(count = n()) %>%
  dplyr::filter(count == 1) %>%
  dplyr::filter(str_detect(rowname, "L1", negate = TRUE))
head(elww)

# add root for non-leaf single occurance nodes
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

# tree no leaves
#chopqueentree <- rbind(branches, trunk, crown) 
#write.csv(chopqueentree, file_chopqueentree, row.names = FALSE)

# sed 's/\"//g' file.txt > file_new.txt
# tr ',' ' ' < "headlessqueen4.txt" > "headlessqueen5.txt"

# add geo to leaves
nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv")
nodes$osmid <- as.numeric(nodes$osmid)
leaves$V1 <- as.numeric(leaves$V1)
leavesgeo <- dplyr::inner_join(leaves, nodes, by=c("V1"="osmid") ) %>%
  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
  st_transform(., crs =3035)
head(leavesgeo)
dim(leavesgeo)
write.csv(leavesgeo, file_leavesgeo, row.names = FALSE) # 774691
st_write(leavesgeo, file_leavesgeojson, append=TRUE)
#ggplot() + geom_sf(data=leavesgeo, aes(geometry=geometry))
#ggsave("/home/ucfnhbx/Scratch/hiery2/leavesgeoplot.png")
