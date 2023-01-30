import pandas as pd
import geopandas as gpd

#build mask
#ESRI
europe = gpd.read_file('/home/ucfnhbx/Scratch/data/esri.geojson')
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

mainlands.plot();
mainlands.to_file('/home/ucfnhbx/Scratch/data/mainlands.geojson', driver='GeoJSON')
mainland.plot();
mainland.to_file('/home/ucfnhbx/Scratch/data/mainland.geojson', driver='GeoJSON')
isles.plot();
isles.to_file('/home/ucfnhbx/Scratch/data/isles.geojson', driver='GeoJSON')

#build grid
EEAgrid = gpd.read_file('/home/ucfnhbx/Scratch/data/eea.zip', encoding='utf-8')
EEAgrid.to_file('/home/ucfnhbx/Scratch/data/eea.geojson', driver='GeoJSON')
grid_europ = gpd.clip(gdf=EEAgrid.to_crs("EPSG:4326"), mask=mainland, keep_geom_type=False) 
grid_europ.to_file('/home/ucfnhbx/Scratch/data/grid.geojson', driver='GeoJSON')

rows = grid_europ.iloc[3:4,:].index.values

