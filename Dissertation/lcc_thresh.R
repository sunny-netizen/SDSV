library(magrittr)
library(dplyr)
library(ggplot2)

filepath <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/"
file_lcc1 <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/lcc.txt"
file_lcc2 <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/lcc2.txt"
file_lcc3 <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/lcc3.txt"
clust_sizing <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/cluster_sizes/clust_size_p"
#file_lccplot <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/LCC_Thresholds.png"
#file_transheight <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/transheight.png"
#file_height <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/height.png"

nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv")
total_intersections <- 23583851 #19565126 #dim(nodes)[1]
r0=seq(100, 15000, by=100) 

# create lcc1
write('threshold\t size',file=file_lcc1,append = FALSE)
for (i in r0){
  thresh <- read.csv(paste0(clust_sizing,i,".txt"), header=T, sep=" ")
  thresh <- thresh[order(thresh$n_points, decreasing = T),][1,]
  write(c(i,thresh$n_points),
        file=file_lcc1,
        append = TRUE)
}

# create lcc2
write('threshold\t size',file=file_lcc2,append = FALSE)
for (i in r0){
  thresh <- read.csv(paste0(clust_sizing,i,".txt"), header=T, sep=" ")
  thresh <- thresh[order(thresh$n_points, decreasing = T),][2,]
  write(c(i,thresh$n_points),
        file=file_lcc2,
        append = TRUE)
}

# create lcc3
write('threshold\t size',file=file_lcc3,append = FALSE)
for (i in r0){
  thresh <- read.csv(paste0(clust_sizing,i,".txt"), header=T, sep=" ")
  thresh <- thresh[order(thresh$n_points, decreasing = T),][3,]
  write(c(i,thresh$n_points),
        file=file_lcc3,
        append = TRUE)
}

##### sorting
info <- read.csv(file_lcc1,header=T, sep=" ") %>%
  #info <- read.csv(paste0(dir_res,"lcc_copy.txt"),header=T, sep=" ") %>%
  dplyr::mutate(., size_norm = round(size/total_intersections, 2)) %>%  
  dplyr::mutate(., height = size - lag(size, n=1L, default=0) ) 
head(info)
#highest <- info[order(info$height, decreasing = TRUE),][1:20,] 
#highest
#write.csv(highest, paste0(filepath,"highest.csv") ) 

info2 <- read.csv(file_lcc2,header=T, sep=" ") %>%
  dplyr::mutate(., size_norm = round(size/total_intersections, 2)) %>%  
  dplyr::mutate(., height = size - lag(size, n=1L, default=0) ) 
head(info2)
#highest2 <- info2[order(info2$height, decreasing = TRUE),][1:10,] 
#highest2

info3 <- read.csv(file_lcc3,header=T, sep=" ") %>%
  dplyr::mutate(., size_norm = round(size/total_intersections, 2)) %>%  
  dplyr::mutate(., height = size - lag(size, n=1L, default=0) ) 
head(info3)
#highest3 <- info3[order(info3$height, decreasing = TRUE),][1:10,] 
#highest3


###### plotting three largest clusters
#png(file_lccplot, width = 1000, height = 700, res=100)

ggplot() +
  #lcc
  geom_line(data=info, aes(x=threshold, y=size_norm, group=1, color=lead(height)), size=2) +
  geom_point(data=info, aes(x=threshold, y=size_norm, group=1, color=height), size=2) +
  #lcc2
  geom_line(data=info2, aes(x=threshold, y=size_norm, group=2, color=lead(height)), size=1) +
  geom_point(data=info2, aes(x=threshold, y=size_norm, group=2, color=height), size=1) +
  #lcc3
  geom_line(data=info3, aes(x=threshold, y=size_norm, group=3, color=lead(height)), size=0.5) +
  geom_point(data=info3, aes(x=threshold, y=size_norm, group=2, color=height), size=0.5) +
  #colors
  #geom_vline(xintercept=300,color="red",size=1.5, alpha=0.5)+
  #scale_color_gradient(low="red", high="green", mid="black", midpoint=0)+
  #geom_hline(yintercept=jenks.lines, color="magenta", linetype="dashed", size=1)+
  scale_color_gradient2(low="red", high="blue", mid="grey", midpoint=0)+
  labs(x="Distance Threshold (m)", y="Size (Normalised)", color = "Transition Height (m)") +
  scale_x_continuous(breaks=seq(0,15000,500)) +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  theme(panel.grid.major = element_line(size = 0.1, color="#CCCCCC"), 
      panel.grid.minor = element_line(size = 0.08, color="#CCCCCC"),
      panel.background = element_rect(fill = "white", #"#CCCCCC",
                                      colour = "azure",
                                      size = 0.5, linetype = "solid"
      ))
ggsave(paste0(filepath,"lcc123.png"), width=14)


##### lcc1 with jenks
library(BAMMtools)
jenks <- data.frame("size"=getJenksBreaks(info$size, 25)) %>%
  ### add 300 cities here
  dplyr::left_join(., info, by=("size"))
write.csv(jenks, paste0(filepath,"jumps.csv"))
#library(Ckmeans.1d.dp)
#ckm <- Ckmeans.1d.dp(info$size)
#midpoints <- ahist(ckm, style="midpoints", data=info$size, plot=FALSE)$breaks[2:k]
#midpoints <- data.frame(size=midpoints) %>% dplyr::left_join(., info, by=("size"))

##### lcc1 with custom
ggplot() +
  geom_line(data=info, aes(x=threshold, y=size_norm, group=1, color=lead(height)), size=2) +
  geom_point(data=info, aes(x=threshold, y=size_norm, group=1, color=height), size=2) +
  scale_color_gradient2(low="blue", high="red", mid="white", midpoint=0)+
  geom_vline(xintercept=c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 2800, 2300, 
    3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 6600, 7000, 7500, 14500), 
    color="red", size=0.5, alpha=0.5, linetype = "twodash")+ 
  labs(x="Distance Threshold (m)", y="Size (Normalised)", color = "Transition Height (m)") +
  scale_x_continuous(breaks=seq(0,15000,500)) +
  scale_y_continuous(breaks=seq(0,1,0.1)) +
  theme(panel.grid.major = element_line(size = 0.1, color="#CCCCCC"), 
      panel.grid.minor = element_line(size = 0.08, color="#CCCCCC"),
      panel.background = element_rect(fill = "white", #"#CCCCCC",
                                      colour = "azure",
                                      size = 0.5, linetype = "solid"
      ))
ggsave(paste0(filepath,"lcc1custom.png"), width=14)
#ggsave(paste0(filepath,"lcc1highestjumps.png"), width=14)
#ggsave(paste0(filepath,"lcc1jenks.png"), width=14)


# height vs. threshold
ggplot(data=info, aes(x=threshold, y=height))+
  geom_point()+
  xlab("Distance Threshold (m)") +
  ylab("Largest Cluster Size Transition Height (Number of Intersections)")
ggsave(paste0(filepath,"heightthresh.png"), width=14)

# height histogram
ggplot() + 
  theme_light() +
  geom_histogram(data=info, aes(x=height), fill="#993333", alpha=1)+ #binwidth=15000, 
  #geom_histogram(data=info2, aes(x=height), binwidth=15000, fill="blue", alpha=0.5)+
  #geom_histogram(data=info3, aes(x=height), binwidth=15000, fill="orange", alpha=0.5)+
  geom_vline(xintercept=600000, color="magenta", linetype="dashed", size=1)
  #geom_vline(aes(xintercept=mean(info$height)), color="blue", linetype="dashed", size=1)
ggsave(paste0(filepath,"heighthist.png"), width=14)

# kernel density estimations
png("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/kde.png")
plot(density(info$height))
dev.off()
png("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/kdenorm.png")
plot(density(info$size_norm))
dev.off()


ggplot() + 
  theme_light()+
  #geom_line(data=info, aes(x=threshold, y=height), color= 'black')+
  geom_hline(yintercept=jenks.lines, color="magenta", linetype="dashed", size=1)
  #geom_density(data=info, aes(size), color='blue') +
  #geom_density(data=info, aes(height), color='green')+
  #xlim(NA, 15000)
ggsave("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/heightthresh.png", width=14)
