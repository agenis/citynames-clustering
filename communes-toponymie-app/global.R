# PACKAGES
library(shiny)
library(dplyr)
library(stringdist)
#library(maptools)
library(rgdal)
library(cluster)

load(file="deps_names.Rdata")
load(file="com.Rdata")
DEPS <- rgdal::readOGR("departements-20140306-100m.shp")
DEPS <- subset(DEPS, !DEPS$code_insee %in% as.character(971:976))

par(mar=c(0,0,0,0))

# functions
metric_3gram = function(str1, str2){
  meas1 = stringdist::stringdist(a=str1, b=str2, method="cosine", q=3)
  return(meas1)  
}
metric_4gram = function(str1, str2){
  meas1 = stringdist::stringdist(a=str1, b=str2, method="cosine", q=4)
  return(meas1)  
}
metric_lv = function(str1, str2){
  meas2 = stringdist::stringdist(a=str1, b=str2, method="lv")/(nchar(str1)+nchar(str2))*2
  return(meas2)  
}
metric_mixed = function(str1, str2){
  meas1 = stringdist::stringdist(a=str1, b=str2, method="cosine", q=3)
  meas2 = stringdist::stringdist(a=str1, b=str2, method="lv")/(nchar(str1)+nchar(str2))*2
  return((meas1+meas2)/2)  
}



# plotting
plotfunc = function(com_f){
  par(mar=c(0,0,0,0))
  plot(DEPS, xlim=c(-1,5), ylim=c(40,52))
  col_vec = adjustcolor(c("red", rep("blue", nrow(com_f)-1)), alpha.f = 0.75)
  cex_vec = pmax(0.1, pmin(3, 0.3*com_f$d_city^-2))
  pch_vec = c(18, rep(20, nrow(com_f)-1))
  points(com_f$long, com_f$lat, pch=pch_vec, col=col_vec, cex=cex_vec)
}

