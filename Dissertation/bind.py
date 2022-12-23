import os
import glob
import matplotlib.pyplot as plt
import pandas as pd
os.chdir("/home/ucfnhbx/Scratch/osm/gridfor")
print(os.getcwd())

#names of files
extension = 'csv'
edge_names = [i for i in glob.glob('i*/edges_*.{}'.format(extension))]
node_names = [i for i in glob.glob('i*/nodes_*.{}'.format(extension))]
#edge_names = glob.glob("/home/ucfnhbx/Scratch/complete/osm/gridfor/i100/edges_*.csv"))
#node_names = glob.glob("/home/ucfnhbx/Scratch/complete/osm/gridfor/i100/nodes_*.csv"))
print(edge_names)
print(node_names)

#combine all files in the list
edge_csv = pd.concat([pd.read_csv(f, usecols=['u', 'v', 'osmid', 'length', 'geometry']) for f in edge_names ])
edgelist_csv = pd.concat([pd.read_csv(f, usecols=['u', 'v', 'length']) for f in edge_names ])
node_csv = pd.concat([pd.read_csv(f, usecols=['osmid', 'x', 'y', 'geometry']) for f in node_names ])

#export to csv
edge_csv.to_csv( "edges.csv", index=False, encoding='utf-8-sig')
edgelist_csv.to_csv( "edgelist.csv", index=False, encoding='utf-8-sig')
node_csv.to_csv( "nodes.csv", index=False, encoding='utf-8-sig')


#https://www.freecodecamp.org/news/how-to-combine-multiple-csv-files-with-8-lines-of-code-265183e0854/
#node_csv = gpd.read_file("nodes.csv")
fig = plt.figure() #figsize=(30, 18)
ax = node_csv.plot() #figsize=(30,18), edgecolor='black'
fig.savefig("intersections.png")
