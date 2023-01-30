#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import time
import pandas as pd
import geopandas as gpd
import osmnx as ox
import networkx as nx
import threading
import logging
import concurrent.futures
import matplotlib.pyplot as plt
import itertools as it


# ## Mainland Europe

# In[2]:


# all of europe
# https://hub.arcgis.com/datasets/esri::world-continents/explore?filters=eyJDT05USU5FTlQiOlsiRXVyb3BlIl19&location=-0.592498%2C179.999994%2C2.03
europe = gpd.read_file('Data/Europe.geojson')
#europe.total_bounds
#europe.crs


# In[9]:


multipolygon = europe.geometry[0]
polygons = list(europe.geometry[0])

sizes = []
for polygon in multipolygon:
    sizes.append(polygon.area)
    
landsize = pd.DataFrame(polygons)
landsize['size'] = sizes
landsize = landsize.sort_values('size', ascending=False)
landsize = gpd.GeoDataFrame(landsize, geometry=0, crs='EPSG:4326')
mainlands = landsize.iloc[[0,1,5],:]
mainland = landsize.iloc[[0],:] #max(multipolygon, key=lambda a: a.area)
isles = landsize.iloc[[1,5],:]


# In[68]:


# plot mainland Europe polygon

#mainland.to_crs("EPSG:3035").centroid
fig, ax = plt.subplots(figsize=(12, 10))
#mainland.to_crs("EPSG:3035").envelope.plot(ax=ax, color='gold')
europe.to_crs("EPSG:3035").plot(ax=ax, color = 'white', edgecolor='black')
mainland.to_crs("EPSG:3035").plot(ax=ax, color = 'lightgreen', edgecolor='darkgreen', linewidth=3)
#grid[0:400].to_crs("EPSG:3035").plot(ax=ax, color='red')

# save plot
plt.savefig("Figs/plot_mainland.png")


# In[8]:


#mainlands.plot();
#mainlands.to_file('Data/mainlands.geojson', driver='GeoJSON')
()
mainland.plot();
mainland.to_file('Data/mainland.geojson', driver='GeoJSON')
#isles.plot();
#isles.to_file('Data/isles.geojson', driver='GeoJSON')


# ## EEA grid

# In[17]:


# https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2
EEAgrid = gpd.read_file('Data/Europe.zip')
#EEAgrid.to_file('Data/eea.geojson', driver='GeoJSON')
# origin is at bottom left


# In[43]:


# dimensions of grid
print(EEAgrid.crs)
print(EEAgrid.shape)


# In[19]:


# examine grids ordering: grids in df start from top left
EEAgrid[EEAgrid.EofOrigin == EEAgrid.EofOrigin.max()] # E83 grids across
EEAgrid[EEAgrid.NofOrigin == EEAgrid.NofOrigin.max()] # N74 grids down
EEAgrid.head()

#vert = EEAgrid.dissolve(by=['EofOrigin'])
#horiz = EEAgrid.dissolve(by=['NofOrigin'])
#horiz.iloc[[-1],:].plot()


# In[20]:


# clip grid to mainland Europe in epsg 3035 for accuracy, then save as epsg 4326 for OSMnx input
grid_europ = gpd.clip(gdf=EEAgrid, mask=mainland.to_crs("EPSG:3035"), keep_geom_type=False).to_crs("EPSG:4326")


# In[24]:


#examine one grid 
#multipolygons grid_europ.loc[[1887]].plot()

#examine one row
#grid_europ.iloc[[0],:]

#examine data
#grid_europ.head()


# In[ ]:


#save clipped grid
#grid_europ.to_file('Data/grid.geojson', driver='GeoJSON')
#grid_europ.crs


# In[69]:


#plot clipped grid
fig, ax = plt.subplots(figsize=(12, 10))
EEAgrid.plot(ax=ax, edgecolor='darkgreen', facecolor="none" );
#europe.to_crs("EPSG:3035").plot(ax=ax, edgecolor='black', facecolor="none");
mainland.to_crs("EPSG:3035").plot(ax=ax, facecolor="none", edgecolor='darkgreen', linewidth=3)
plt.savefig("Figs/plot_EEA.png")


# In[ ]:


fig, ax = plt.subplots(figsize=(12, 10))
mainland.plot(ax=ax, facecolor="none", edgecolor='darkgreen', linewidth=3)
grid_europ.plot(ax=ax, edgecolor='green', facecolor="none");
#include in plot one grid of a different color
#grid_europ.iloc[[4]].plot(ax=ax, color='red', edgecolor='blue');
plt.savefig("Figs/plot_grids.png")

