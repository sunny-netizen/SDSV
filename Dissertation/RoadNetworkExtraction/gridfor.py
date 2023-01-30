import time
import logging
import argparse
import pandas as pd
import geopandas as gpd
import osmnx as ox
import networkx as nx

file_grid = '/home/ucfnhbx/Scratch/data/grid.geojson'
file_EL = '/home/ucfnhbx/Scratch/osm/gridfor/i900/EL_'
file_nodes = '/home/ucfnhbx/Scratch/osm/gridfor/i900/nodes_'
file_edges = '/home/ucfnhbx/Scratch/osm/gridfor/i900/edges_'

#parser = argparse.ArgumentParser('testPy')
#parser.add_argument('-min', type=int, nargs=1)
#parser.add_argument('-max', type=int, nargs=1)
#args = parser.parse_args()
gmin = 900 #args.min[0]
gmax = 1000 #args.max[0]

grid_europ = gpd.read_file(file_grid)
rows = grid_europ.iloc[gmin:gmax,:].index.values

#download
start_time = time.time() 
for index in rows:
    grid=grid_europ.iloc[[index]]
    gridn = grid.CellCode.values[0]
    logging.info("Thread %s: locked for G", gridn)
    print("index=",index, "grid=",gridn)
    polygon=grid.values[0][3]
    
    try:
        G = ox.graph_from_polygon(polygon=polygon, network_type='drive', simplify=True, retain_all=True, 
                                 truncate_by_edge=True, clean_periphery=True, custom_filter=None)
        print("try ",gridn," finished in %s seconds ---" % (time.time() - start_time))
    except:
        logging.info("Thread %s: empty", gridn)
        print("except ",gridn," finished in %s seconds ---" % (time.time() - start_time))
    else: 
        # from loaded graph, generate an edgelist file and save locally
        logging.info("Thread %s: edgelist-ing", gridn)
        nx.write_edgelist(G, file_EL+str(gridn)+'.edgelist')

        # save csvs of nodes and edges. 1x time as graph_from_bbox
        logging.info("Thread %s: gdf-ing", gridn)
        gdf_nodes, gdf_edges = ox.graph_to_gdfs(G)
        gdf_nodes.to_csv(file_nodes+str(gridn)+'.csv')
        gdf_edges.to_csv(file_edges+str(gridn)+'.csv')
        logging.info("Thread %s: gdfs finishing", grid)
        print("else ",gridn," finished in %s seconds ---" % (time.time() - start_time))
        
    finally:
        #https://stackoverflow.com/questions/16771822/python-thread-exception-cause-stop-the-process
        #signals to queue job is done
        print("done ",gridn," finished in %s seconds ---" % (time.time() - start_time))
    logging.info("Thread %s: done", gridn) 
