library(sf)
library(ggplot2)
library(magrittr)
library(spatstat)



mainland <- st_read("/home/ucfnhbx/Scratch/data/mainland.geojson") %>%
  st_transform(., crs =3035)
ggplot()+ geom_sf(data = mainland)
ggsave("/home/ucfnhbx/Scratch/osm/gridfor/plots/mainland.png")

grid <- st_read("/home/ucfnhbx/Scratch/data/grid.geojson")
ggplot()+ geom_sf(data = grid, aes(geometry = geometry), color = "black", fill = "white")
ggsave("/home/ucfnhbx/Scratch/osm/gridfor/plots/grid.png")

nodes <- read.csv("/home/ucfnhbx/Scratch/osm/gridfor/nodes.csv") %>% 
  st_as_sf(coords = c("x", "y"), crs= 4326) %>%
  st_transform(., crs =3035)
#nodecoords <- as.data.frame(st_coordinates(nodes))

eea <- st_read('/home/ucfnhbx/Scratch/data/eea.geojson', crs=3035)
ggplot() + 
  geom_sf(data=mainland, aes(geometry = geometry), color = "black", fill = "white", size = 0.1, alpha = 1 ) + 
  geom_sf(data=eea, aes(geometry = geometry), fill= NA, size = 0.1)
ggsave("/home/ucfnhbx/Scratch/osm/gridfor/plots/eea.png")

window <- as.owin(mainland)
nodessp <- nodes %>% as(., 'Spatial')
nodes.ppp <- ppp(x=nodessp@coords[,1], y=nodessp@coords[,2], window=window)
png("/home/ucfnhbx/Scratch/osm/gridfor/plots/nodesppp.png")
nodes.ppp %>% plot()
dev.off()
png("/home/ucfnhbx/Scratch/osm/gridfor/plots/nodesdensity.png")
nodes.ppp %>% density() %>% plot()
dev.off()

ggplot()+
  #theme_light()+
  geom_sf(data=mainland, aes(geometry = geometry), color = "black", fill = "white", size = 0.1, alpha = 1 ) +
  geom_sf(data=nodes, aes(geometry=geometry), alpha=0.1, color="magenta", size = 0.1) +
  #geom_sf(data=eea, aes(geometry = geometry) , color = "black", size = 0.1, alpha = 1 )
  #geom_hex(data=head(nodes, 10000), aes(), bins=70)
ggsave("/home/ucfnhbx/Scratch/osm/gridfor/plots/allnodes.png")


