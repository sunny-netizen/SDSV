# Code for the percolation process on network
library(igraph)
library(reshape2)
#install.packages("rlang", repos="http://cran.r-project.org")
#install.packages("glue", repos="http://cran.r-project.org")
#install.packages("lifecycle", repos="http://cran.r-project.org")
#install.packages("tidyselect", repos="http://cran.r-project.org")
#install.packages("purr", repos="http://cran.r-project.org")
#install.packages("tidyverse", repos="http://cran.r-project.org")
install.packages("readr", repos="http://cran.r-project.org")
install.packages("dplyr", repos="http://cran.r-project.org")
library(readr)
library(dplyr)
library(sf)
library(parallel)
#library(ggplot2)

################# directories #######################
#directory where you will create your membership tables
dir_res <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/" 

#file containing the information of the network in the following format
# "id_node1","id_node2","link_weight"
file_network <- "/home/ucfnhbx/Scratch/osm/gridfor/edgelist.csv" 

#Files for the results:
    file_memb <- 'membTables/membership' #### sunny added

    #number of clusters at each threshold
    file_n_clust <- "cluster_sizes/clust_size_p" 
    
    #file for the largest cluster size
    file_clust_size <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/lcc.txt"

#file with the coordinates if you want to plot them
    # may be same as file_network
file_coords <- "a.csv" 

#let us read the file that contains the list of nodes
all_table <- read.csv(file_network,header=T,sep=",")
head(all_table)

#choose the column that contains the weight that you wish to use for the percolation
#let us assume is the last column, otherwise change is.
p_col=3 #dim(all_table)[2]

########################## constructing network, skip ########################
#let us construct the network first and do the percolation afterwards
#node1=all_table$start_point #id_node1
#node2=all_table$end_point #id_node2
#weight=all_table$length #link_weight
#df=data.frame(node1,node2,weight)
#head(df)

#g_net=graph.data.frame(df,directed=FALSE) 
#head(E(g_net))
#all_weights=(E(g_net)$weight)
#head(all_weights)
#plot(g_net)

#let us introduce the coordinates to the nodes
#data_coords <- read.csv(file_coords,sep=',',header=TRUE)

#data_coords <- within(data_coords, rm("" #rm('X'))
#dim(data_coords)
#head(V(g_net)$name)
#length(V(g_net))

#vect_pos=match( V(g_net)$name, data_coords$intersection_point )
#length(vect_pos)
#head(vect_pos)

#v_lat=data_coords$lat[vect_pos]
#v_lon=data_coords$lon[vect_pos]

#g_net <- set.vertex.attribute(g_net, "x", value=v_lon)
#g_net <- set.vertex.attribute(g_net, "y", value=v_lat)


#**************** this bit can be ignored *************************
#let us plot a subset
#just to have a sense, you can choose an initial threshold, here we had normalised data, so probabilities
#new_graph <- subgraph.edges(g_net, which((E(g_net)$weight) > 0.5))
#sub_weight=(E(new_graph)$weight)
#head(sub_weight)
#min(sub_weight)
#length(V(g_net))
#length(V(new_graph))

#palette_edges=hsv(h=1-((sub_weight/max(sub_weight)*2/3)+1/3),s = 1,v=1)

#plot(new_graph,vertex.size=.1,vertex.label=NA,edge.color=palette_edges)

#palette_edges_all=hsv(h=1-((all_weights/max(all_weights)*2/3)+1/3),s = 1,v=1)

#plot(g_net,vertex.size=.1,vertex.label=NA,edge.color=palette_edges_all)

#**************** end of bit that can be ignored *************************

# define vector with percolation threshold
#"ID" "n_points"
#"1" 4801
#"2" 2
#"3" 2

############### Percolation!!! ################################
rmin=100 #meters
rmax=15000 #meters
r0=seq(rmin, rmax,by=100) #100
#i_loop=length(r0)
#i_loop
#write('threshold\t size',file=file_clust_size,append = FALSE)
start_time <- Sys.time()
mclapply( X=r0, function(i) #for (i in r0)
{
  #find sub-matrix such that all weights <= threshold r0
	mat_r0=all_table[all_table[,p_col]<=i,,drop=FALSE]
	#added the ,drop=FALSE] so that when matrix has only one row (say only two points form 
	#a unique cluster for the threshold distance), it's still considered a matrix
	#create graph
	m2=mat_r0[,1:2,drop=FALSE]
	head(m2)
	rm(mat_r0)
	
	m2[,1]=as.character(m2[,1])
	m2[,2]=as.character(m2[,2])
	m_g=as.matrix(m2)
	g <- graph.edgelist(m_g, directed=TRUE)
	rm(m_g)
	
	#take subcomponents
	membclusters <- clusters(g, mode="weak")$membership
	m <- cbind(V(g)$name,membclusters)
	colnames(m) <- c("id_point","id_cluster")
	rm(membclusters)
	rm(g)
	
	# write out membership tables
	file_name <- paste(dir_res,file_memb,i,".txt",sep="") #i_loop
	write.table(m,file_name,col.names = TRUE, sep=",",row.names=FALSE)
	
	# calculate biggest cluster
	M_data <- as.data.frame(m)
	head(M_data)
	table_data <- table(M_data$id_cluster)
	biggest_clust=max(unname(table_data))
	
	print(i) #print(i_loop)
	#write out cluster sizes
	file_out <- paste(dir_res,file_n_clust,i,".txt",sep="") #sunny added i instead of i_loop
	write.table(table_data,file_out,row.names=FALSE,col.names=c('ID','n_points'))
	
	#let us construct at the same time the file with the largest cluster size.
	write(c(i,biggest_clust),file=file_clust_size,append = TRUE) # i_loop replaced i
	#i_loop=i_loop-1
}, mc.cores = 8)
end_time <- Sys.time()
print(end_time - start_time)