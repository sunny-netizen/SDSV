library(sf)
library(igraph)
library(lsa)

###################### inputs
# roots population
# rootspop <- st_read("/home/ucfnhbx/Scratch/hiery2/rootspop.geojson")
# head(rootspop) # V1     V2 weight                geometry
#firsttree <- st_read("/home/ucfnhbx/Scratch/hiery2/firsttree.geojson")
#firsttree <- read.csv("/home/ucfnhbx/Scratch/hiery2/firsttree.csv")
#head(firsttree)
#dim(firsttree)
masktree <- st_read("/home/ucfnhbx/Scratch/hiery2/masktree.geojson")
tail(masktree)
#nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv")  %>% 
#  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
#  st_transform(., crs =3035)

# treegraph
queentree <- read.csv("/home/ucfnhbx/Scratch/hiery2/queentree_.csv")
#queentree$V1<- queentree$V1 %>% str_remove(., "L.*_")
#queentree$V2<- queentree$V1 %>% str_remove(., "L.*_")
tail(queentree)
dim(queentree)
g <- graph.data.frame(queentree)

# correspondence data
vor <- st_read("/home/ucfnhbx/Scratch/hiery2/vor.geojson")
essnuts <- st_read("/home/ucfnhbx/Scratch/hiery2/essnuts.geojson")

#####################################
# Create a Vector with Columns
#columns <- c("sam1","sam2","n1","n2","coph","dna","ess") 
#Create a Empty DataFrame with 0 rows and n columns
#harvest <- data.frame() #data.frame(matrix(nrow = 0, ncol = length(columns))) 
harvest <- data.frame(sam1=numeric(), sam2=numeric(),
                      n1=numeric(), n2=numeric(), 
                      coph=numeric(), dna=numeric(), ess=numeric() )

            #-  #L3
jumps <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 
          2800, 2300, 3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 
          6600, 7000, 7500, 14500)
                             #L25       #L26

# harvest samples
start_time <- Sys.time()
#harvest <- mclapply(X=1:1000, function(i) {
for (i in 1:20000) {
  print(i)
  tryCatch({
    sam <- sample(nrow(masktree), size=2, replace=F)
    n <- masktree[sam,]
    n1 <- n[1,] 
    n2 <- n[2,] 
    #n1$new_id_cluster %in% list(V(g))
    #n2$new_id_cluster %in% list(V(g))

    #if (n1$p_ds == 300) {m1 = n1
    #} else { m1 = paste0("L",match(p_ds, jumps)+1,"_",n1) 
    #}
    #if (n2$p_ds == 300) {m2 = n2
    #} else { m2 = paste0("L",match(p_ds, jumps)+1,"_",n2) 
    #}

    # cophenetic distance
    #coph <- distances(g, n1$V2, n2$V2)[[1]]
    #coph <- distances(g, n1$id_cluster, n2$id_cluster)[[1]]
    #coph <- distances(g, m1, m2)[[1]]
    coph <- distances(g, n1$new_id_cluster, n2$new_id_cluster)[[1]]
    
    # add geo
    #n <- dplyr::inner_join(nodes, n, by = c("osmid"="ID_points"))

    # join with comparative data
    nvor <- st_join(x=n, y=vor, largest = TRUE)%>%
      dplyr::select(c(PC1, PC2)) %>%
      st_drop_geometry()
    ness <- st_join(n, essnuts, largest = TRUE)%>%
      dplyr::select(c(ipcrtiv:impfun))%>%
      st_drop_geometry()

    disdna <- 1 - cosine(as.numeric(nvor[1,]), as.numeric(nvor[2,]))
    disess <- 1 - cosine(as.numeric(ness[1,]), as.numeric(ness[2,]))

    leaf <- data.frame(sam1 = sam[1], sam2 = sam[2], n1 = n1$id_cluster, n2 = n2$id_cluster, coph=coph, dna=disdna[1], ess=disess[1])
    #return(leaf) 
    #harvest <- harvest %>% dplyr::add_row(sam1 = sam[1], sam2 = sam[2], n1 = n1$V1, n2 = n2$V2, coph=coph, dna=disdna[1], ess=disess[1])
    harvest <- rbind(harvest, leaf)
  }, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
} #, mc.cores = cores) %>% dplyr::bind_rows() #$ -pe smp 1
end_time <- Sys.time()
elapse <- end_time - start_time
print(elapse) 
#flog.info(paste("flog elapse=", elapse))

dim(harvest)
print(dim(harvest))
harvest <- harvest %>% dplyr::distinct()
dim(harvest)
write.csv(harvest, "/home/ucfnhbx/Scratch/coco2/harvest.csv", row.names=FALSE)


############### vz
library(ggplot2)
install.packages("egg", dependencies = TRUE)
library(egg)
install.packages("devtools", dependencies = TRUE)
devtools::install_github("thomasp85/patchwork")
library(patchwork)
install.packages("cowplot", dependencies = TRUE)
library(cowplot)

#harvest <- read.csv("/home/ucfnhbx/Scratch/coco2/harvest.csv")
harvest <- read.csv('~/Documents/Dissertation_codes/SDSV/Dissertation/sapphire/harvest.csv')
head(harvest)
summary(harvest$dna)
summary(harvest$ess)
summary(harvest$coph)

# histogram
hdna <- ggplot(harvest, aes(x=dna)) + geom_histogram(color="white", fill="darkorange") +
  ylab('Count') + xlab('Genetic Cosine Distance') +
  scale_x_continuous() + scale_y_continuous()
ggsave("/home/ucfnhbx/Scratch/coco2/histdna.png")

hess <- ggplot(harvest, aes(x=ess)) + geom_histogram(color="white", fill="purple") +
  ylab('Count') + xlab('Human Values Cosine Distance') + 
  scale_x_continuous() + scale_y_continuous()
ggsave("/home/ucfnhbx/Scratch/coco2/histess.png")

hcoph <- ggplot(harvest, aes(x=coph)) + geom_histogram(color="white", fill="darkgreen") +
  ylab('Count') + xlab('Cophenetic Distance (m)') +
  scale_x_continuous() + scale_y_continuous()
ggsave("/home/ucfnhbx/Scratch/coco2/histcoph.png")

# boxplot
# Create a new plot object
#y-axis more intermediates
# label meters
bdna <- ggplot(harvest, aes(x=dna)) + geom_boxplot(fill="darkorange")
bess  <- ggplot(harvest, aes(x=ess)) + geom_boxplot(fill="purple")
bcoph  <- ggplot(harvest, aes(x=coph)) + geom_boxplot(fill="darkgreen")

#https://stackoverflow.com/questions/48164435/merge-and-perfectly-align-histogram-and-boxplot-using-ggplot2
cowplot::plot_grid(bdna, hdna, ncol = 1, rel_heights = c(1, 4), align = 'v', axis = 'lr')
cowplot::plot_grid(bess, hess, ncol = 1, rel_heights = c(1, 4), align = 'v', axis = 'lr')
cowplot::plot_grid(bcoph, hcoph, ncol = 1, rel_heights = c(1, 4), align = 'v', axis = 'lr')

install.packages("tidyquant")
library(tidyquant)
library(ggplot2)
library(zoo)

# scatter
ggplot(harvest) + geom_point(aes(x=coph, y=dna), color = 'darkorange', size = 2) + 
  ylab('Genetics Cosine Distance') + xlab('.') + xlab('Cophenetic Distance (m)') +
  tidyquant::geom_ma(aes(x=coph, y=dna), ma_fun = SMA, n = 200, linetype = "solid", color = "darkgreen") +
  geom_smooth(method="lm", aes(x=coph, y=dna), color='purple') +
  #geom_line(aes(x=coph, y=rollmean(x=dna, k=2000, na.pad=TRUE))) +
  scale_x_continuous() + scale_y_continuous()
ggsave("/home/ucfnhbx/Scratch/coco2/scatterdna.png")

ggplot(harvest) + geom_point(aes(x=coph, y=ess), color = 'purple', size = 2)+
  ylab('Values Cosine Distance') + xlab('Cophenetic Distance (m)') +
  tidyquant::geom_ma(aes(x=coph, y=ess), ma_fun = SMA, n = 2000, linetype = "solid", color = "green") +
  geom_smooth(method="lm", aes(x=coph, y=ess), color = 'darkorange') +
  scale_x_continuous() + scale_y_continuous()
ggsave("/home/ucfnhbx/Scratch/coco2/scatteress.png")


#png(file_png)
#grid.arrange(patchworkGrob(dnaplot / essplot), left = 'Cosine Distance')
#dev.off()
cor.test(x=harvest$coph, y = harvest$dna, method = c("pearson"))
cor.test(x=harvest$coph, y = harvest$ess, method = c("pearson"))
