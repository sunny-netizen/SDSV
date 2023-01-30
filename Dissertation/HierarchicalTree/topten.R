library(dplyr)
oneroot <- read.csv('oneroot.csv')
topten <- oneroot %>% 
  group_by(height) %>%
  dplyr::mutate(lccrank = order(order(size1, decreasing = TRUE)))%>%
  dplyr::arrange(desc(size1), .by_group = TRUE) %>%
  dplyr::mutate(lccrank = ifelse(lccrank > 8, 9, lccrank))
topten
head(topten, 20)
write.csv(topten, "topten.csv")