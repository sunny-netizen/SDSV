library(futile.logger)
library(igraph)

# input parameters
#jumped <- read.csv("/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/ju.csv")
v_jumps <- c(300, 1000, 1200, 1400, 1500, 1600, 1900, 2000, 2500, 2600, 2800, 2300, 
    3300, 3600, 3700, 4000, 4100, 4500, 5000, 5400, 6600, 7000, 7500, 14500)
n_min <- 10000

# input data
path_data <- "/home/ucfnhbx/Scratch/perco/run_spercolation_outputs/membTables/"

# results paths
path_res <- "/home/ucfnhbx/Scratch/hiery2/"
path_plots <- "/home/ucfnhbx/Scratch/hiery2/"
file_name <- "membership" 

# results files
file_tree <- paste0(path_res,"Full_tree.txt")
file_graph <- paste0(path_res,"Tree_graph.txt")

# hierarchical tree
  i_level=1  # initial value
  for(i in v_jumps)
  {
    # this threshold
    i=v_jumps[i_level]
    print(paste0("level =",i_level," and d=",i))
    flog.info(paste0("log__: level =",i_level," and d=",i))
    
    parent2=c(0) # initialise
    
    # open membtable as M_data
    file_data <- paste(path_data,file_name,i,".txt",sep="")
    M_data <- read.table(file_data,sep=",",header=TRUE)
    #head(M_data)
    #dim(M_data)
    nam <- paste0("M_data", i_level)
    assign(nam, M_data)
    
    #graph of all clusters in threshold
    # g <- graph.data.frame(M_data)
    #plot(g,layout=layout_as_tree)
    
    # dataframe of cluster sizes
    M_table <- table(M_data$id_cluster)
    m <- data.frame(id_cluster=names(M_table),n_points=as.vector(M_table))
    
    # subset clusters of minimum size
    m_sub <- m[m$n_points>=n_min,]
    head(m_sub)
    
    # nodes in subset clusters.  M_sub
    M_sub <- M_data[M_data$id_cluster %in% m_sub$id_cluster,]
    dim(M_sub)
    head(M_sub)
    nam <- paste("M_sub", i_level, sep = "")
    assign(nam, M_sub)
    
    # dataframe of cluster sizes from subset.  m_sub_table
    ## m_sub_table same as m_sub? tail(m_sub_table == m_sub), dim(m_sub_table)==dim(m_sub)
    M_sub_table <- table(M_sub$id_cluster)
    head(M_sub_table)
    m_sub_table <- data.frame(id_cluster=names(M_sub_table),n_points=as.vector(M_sub_table))
    head(m_sub_table)
    nam <- paste("node_weight", i_level, sep = "")
    assign(nam, m_sub_table)
    
    # list of cluster IDs in subset
    v_list <- as.vector(m_sub_table$id_cluster)
    nam <- paste("v_list", i_level, sep = "")
    assign(nam, v_list)
    
    # number of clusters
    n_clusts <- length(M_sub_table)
    nam <- paste("n_clusts", i_level, sep = "")
    assign(nam, n_clusts)
    
    # graph of subset clusters
    g_sub <- graph.data.frame(M_sub,directed=F)
    nam <- paste("g_sub", i_level, sep = "")
    assign(nam, g_sub)

    if(i==v_jumps[1])
    {
      #plot(g_sub,layout=layout_as_tree)#,vertex.size=V(g_sub)$size,vertex.label=NA)
      #plot(g_sub)#,vertex.size=degree(g_sub))  
      Full_tree <- cbind(i,M_sub[ ,c(2,1)]) # label this threshold of nodes in subset clusters
      flog.info(paste0("log_A: level =",i_level," and d=",i))
    }else{
      # nodes in subset clusters in this threshold, label this threshold
      new_bit <- cbind(i,M_sub[ ,c(2,1)]) 
      
      # add on to previous thresholds
      Full_tree <- rbind(Full_tree,new_bit) 
      
      # number of clusters in previous threshold
      n_clust_l1 <- get(paste("n_clusts",i_level-1,sep="")) 
      
      # graph of previous threshold
      g_lev1 <- get(paste("g_sub",i_level-1,sep="")) # 
      
      # list of clusters in previous threshold
      v_list_lev1 <- get(paste("v_list",i_level-1,sep=""))
      
      # in previous threshold: nodes adjacent to nodes in clusters
      m_adj <- adjacent_vertices(g_lev1, v_list_lev1, mode ="all")
      
      # nodes in this threshold
      v_tmp2 <- M_sub$id_point
      
      # loop through each in cluster in previous threshold
      for(j in 1:n_clust_l1)
      {
        # name of cluster
        v_name1 <- v_list_lev1[j]
        
        # nodes adjacent to nodes in cluster
        v_tmp1 <- m_adj[[j]]$name
        
        # nodes adjacent to nodes in cluster, that are in THIS threshold
        v_inter <- intersect(v_tmp1,v_tmp2)
        
        if(length(v_inter)==0)
        {
          print(paste("!!!!there was a mistake for year=","y_loop","and p_ds=",i," for cluster j=",j)) #y_loop var
          flog.info(paste("cluster",j,"doesn't connect to threshold",i))
        }else{
          id_parent <- M_sub[M_sub$id_point==v_inter[1],]$id_cluster
          if(parent2[1]==0)
          {
            parent2=c(id_parent)
            child2=c(v_name1)
          }else{
            parent2=c(parent2,id_parent)
            child2=c(child2,v_name1)
          }
        }
        
      }#end of for(j in 2:n_clusts[i_level-1])
      #create graph
      if(i_level==2)
      {
        flog.info(paste0("log_B: level =",i_level," and d=",i))
        # we have issue with the fact that parent and child are called the same
        # to avoid problems at this level, change the name of the last level
        parent22=paste("L3_",parent2,sep="")
        tree_2 <- data.frame(level1 = parent22, clusters = child2)
        g2 <- graph.data.frame(tree_2,directed=F)
        #we need to assign the real weight to the nodes now
        #Let us obtain the position of the children
        v=match(V(g2)$name,child2)
        v_pos_nn=which(!is.na(v))
        V(g2)[v_pos_nn]$name
        #Assign weight from node_weight list
        for(i_pos in 1:length(v_pos_nn))
        {
          V(g2)[v_pos_nn[i_pos]]$size=node_weight1$n_points[i_pos]  
        }
        #Now let us assign weight to the parents
        #Need to match the name of the node with the name in the list
        v_pos_n=which(is.na(v))
        #V(g2)[v_pos_n]$name
        mod_names_list=paste("L3_",node_weight2$id_cluster,sep="")
        v_pos_list=match(V(g2)[v_pos_n]$name,mod_names_list)
        for(i_pos in 1:length(v_pos_n))
        {
          V(g2)[v_pos_n[i_pos]]$size=node_weight2$n_points[v_pos_list[i_pos]]
        }
      
        
        V(g_sub1)$size <- degree(g_sub1)
        g_u2 <- igraph::union(g_sub1,g2)
        #the attribute size is split in size_1 and size_2 with null values
        #V(g_u2)$size_2
        #need to properly reassign it
        V(g_u2)$size=V(g_u2)$size_1
        v_pos_NA1 <- which(is.na(V(g_u2)$size_1))
        V(g_u2)$size[v_pos_NA1]=V(g_u2)$size_2[v_pos_NA1]
        
        g_tree2 <- g_u2
        #plot(g_u2,vertex.size=V(g_u2)$size)
        #plot(g_tree2,vertex.size=V(g_tree2)$size,layout=layout_as_tree(g_tree2,root = parent22))
        g_old <- g_tree2
      }else{
        flog.info(paste0("log_C: level =",i_level," and d=",i))
        parent32=paste("L",i_level+1,"_",parent2,sep="")
        child32=paste("L",i_level,"_",child2,sep="")
        tree_3 <- data.frame(level1 = parent32, clusters = child32)
        g3 <- graph.data.frame(tree_3,directed=F)
        #we need to assign sizes to nodes
        #Let us start with child nodes
        node_weight_child <- get(paste("node_weight",i_level-1,sep=""))
        child_names_list=paste("L",i_level,"_",node_weight_child$id_cluster,sep="")
        v=match(V(g3)$name,child_names_list)
        v_pos_list=which(!is.na(v))
        #length(v_pos_list)
        #V(g3)$name[v_pos_list]
        for(i_pos in 1:length(v_pos_list))
        {
          V(g3)[v_pos_list[i_pos]]$size=node_weight_child$n_points[i_pos]
        }
        #V(g3)$name
        #V(g3)$size
        #Now let us put the weights of the parents
        node_weight_parent <- get(paste("node_weight",i_level,sep=""))
        parent_names_list=paste("L",i_level+1,"_",node_weight_parent$id_cluster,sep="")
        #node_weight_parent$id_cluster
        v=match(V(g3)$name,parent_names_list)
        v_pos_list=which(!is.na(v))
        #length(v_pos_list)
        #V(g3)$name[v_pos_list]
        #Now need to get the position for the list
        v2=v=match(parent_names_list,V(g3)$name)
        v_in_list=which(!is.na(v))
        #length(v_pos_list)-length(v_in_list)
        for(i_pos in 1:length(v_pos_list))
        {
          V(g3)[v_pos_list[i_pos]]$size=node_weight_parent$n_points[v_in_list[i_pos]]
        }
        #V(g3)$name
        #V(g3)$size
        #node_weight_parent$n_points[v_in_list]
        #node_weight_child$n_points
        
        nam <- paste("g_u", i_level, sep = "")
        assign(nam, g3)
        
        #plot(g3,layout=layout_as_tree(g3,root=parent32))
        #join with previous graph g_sub1 or i_level-1 
        #identical_graphs(g_tree2,g_old)
        g_new <- igraph::union(g_old,g3)
        #V(g_old)$size
        #V(g3)$size
        #V(g_new)$size
        
        #the attribute size is split in size_1 and size_2 with null values
        #V(g_new)$size_1
        #need to properly reassign it
        V(g_new)$size=V(g_new)$size_1
        v_pos_NA1 <- which(is.na(V(g_new)$size_1))
        V(g_new)$size[v_pos_NA1]=V(g_new)$size_2[v_pos_NA1]
        V(g_new)$size
        
        nam <- paste("g_tree", i_level, sep = "")
        assign(nam, g_new)
        # if(i_level<4)
        # {
        #   plot(g_new,vertex.size=V(g_new)$size/2,vertex.label=NA)
        #   title(paste('Tree at level ',i_level+1," year ",y_loop,sep=""))
        #   plot(g_new,vertex.size=V(g_new)$size/2,vertex.label=NA,layout=layout_as_tree(g_new,root = parent32))
        #   title(paste("Firms hierarchical tree, London ",y_loop,"\n",i_level+1," levels",sep=""))
        # }else{
        #   plot(g_new,vertex.size=log(V(g_new)$size),vertex.label=NA)
        #   title(paste('Tree at level ',i_level+1," year ",y_loop,sep=""))
        #   plot(g_new,vertex.size=log(V(g_new)$size),vertex.label=NA,layout=layout_as_tree(g_new,root = parent32))
        #   title(paste("Firms hierarchical tree, London ",y_loop,"\n",i_level+1," levels",sep=""))
        # }
       if(i==v_jumps[length(v_jumps)])
        {
         print(paste0('we have finished'))
         flog.info(paste0("log_D: level =",i_level," and d=",i, ' we have finished'))
          #let us save image
          #file_plot<- paste0(path_plots,'tree_London.png')
          #png(file_plot,height=850,width=1000)
          #plot(g_new,vertex.size=log(V(g_new)$size),vertex.label=NA,layout=layout_as_tree(g_new,root = parent32))
          #title(paste("Hierarchical tree, London \n",i_level+1," levels",sep=""),cex.main=2)
          #dev.off()
        }
        
        #plot(g_new,vertex.size=degree(g_new)/2,layout=layout_as_tree(g_new,root = parent32))
        #title(paste('Tree at level ',i_level+1,sep=""))
        #plot(g_tree3,vertex.size=degree(g_new),layout=layout_as_tree(g_tree3,root = parent32,mode="all"))
        g_old <- g_new
      }
      
    }
    
    i_level=i_level+1
  } #end of for(i in v_jumps)
  # save Full_tree info
  write.table(Full_tree,file_tree,row.names=FALSE,col.names=c('p_ds','id_cluster','ID_points'))
  #assign tree to year
  nam <- paste0("g_tree")
  assign(nam, g_new)
  #let us save the graph
  write_graph(g_new, file_graph, format = "ncol")