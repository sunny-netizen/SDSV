library(sf)
library(ggplot2)
library(magrittr)
library(dplyr)
library(parallel)
#library(forcats)
library(futile.logger)

dir_res <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/" 
file_n_clust <- "cluster_sizes/clust_size_p" 
file_memb <- 'membTables/membership'
file_threshplot <- "/home/ucfnhbx/Scratch/perco/plot/perc_"

mainland <- st_read("/home/ucfnhbx/Scratch/data/mainland.geojson") %>% st_transform(., crs =3035)
nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv")  %>% 
  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
  st_transform(., crs =3035)

#jumped <- read.csv("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/jumps.csv")
#jumps <- jumped$threshold
#jumps <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 2800, 2300,
#    3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 6600, 7000, 7500, 14500)
start_time <- Sys.time()
print("start")
futile.logger::flog.logger("start")
mclapply( X=1200, function(i) 
{ 
  print(i)
  # clusters in decreasing size
  clusti <- read.csv(paste(dir_res,file_n_clust,i,".txt", sep = "", collapse = NULL), header=T, sep=" ") %>% 
    dplyr::filter(n_points > 1000) #%>%
    #dplyr::arrange(desc(n_points))
  head(clusti)

  # nodes in each cluster
  membi <- read.csv(paste0(dir_res,file_memb,i,".txt"), header=T,sep=",") %>%
    dplyr::inner_join(., y=clusti, by = c("id_cluster"="ID")) %>%
    dplyr::inner_join(., y=nodes, by = c("id_point"="osmid")) %>%
    dplyr::arrange(desc(n_points))
  head(membi)

  # plot
  ggplot() +
    theme_grey() + 
    geom_sf(data = mainland, aes(geometry = geometry), color = "black", fill = "white", size = 0.1, alpha = 1 ) +
    
    theme(legend.position="none")+
    geom_sf(data = membi, aes(geometry = geometry, color = factor(n_points) ), alpha=0.3, size = 0.000001) +
    scale_fill_brewer(palette = "Set1")
    
    #geom_sf(data = membi, aes(geometry = geometry, color = n_points ), alpha=0.3, size = 0.000001) +
    #scale_colour_gradient(low="red", high="blue", name = "Cluster Sizes")
    #scale_colour_gradientn(rainbow.....)

    #geom_sf(data = membi, aes(geometry = geometry, color = factor(n_points) ), alpha=0.3, size = 0.000001) + #fct_rev 
    #scale_color_manual(
    #  values= rep_len(
    #    c("red", "blue", "green", "yellow", "orange", "magenta", "aquamarine3", "firebrick", "darkgreen", "cyan"), 
    #    length.out = dim(membi)[1]
    #    ),
    #  name = "Largest Cluster Sizes", drop=TRUE, guide = guide_legend(override.aes = list(size = 1, alpha = 1) ), breaks = clusti[1:10,]$n_points 
    #  ) 
  ggsave(paste0(file_threshplot,as.character(i),"m.png")) 
}, mc.cores = 1)
end_time <- Sys.time()
time <- end_time - start_time
print("end")
print(time)
futile.logger::flog.logger(print(time))


#core test
# nodes nrow 2000, 1 jump100, 1 core, 1 min, job 126702
# nodes nrow 2000, 4 jump100, 4 core, 2 min, job 126984 
# nodes nrow 2000, 4 jump100, 3 core, 1 min, job 129381