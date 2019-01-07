# COMMUNES-TOPONYMIE projet personnel
setwd("~/communes-toponymie")
source("script_packages.R")
com = read.csv2("laposte_hexasmal_update.csv", stringsAsFactors = FALSE) %>%
  set_names(c("insee", "nom", "CP", "acheminement", "ligne5", "GPS")) %>%
  mutate(dpmt = substr(insee, 1, 2)) %>%
  tidyr::separate(GPS, c("lat","long"), sep=", ") %>% 
  mutate_at(vars(lat, long), as.numeric) %>%
  filter(!is.na(lat)) %>%
  select(nom, insee, dpmt, lat, long)
com <- com[!duplicated(com), ]
com['nom_brut']=com$nom
setwd("~/communes-toponymie/_carto")
# replace "ST" by "SAINT", suppression des "LE", des 
com$nom = gsub("^ST ", "SAINT ", com$nom)
com$nom = gsub("^STE ", "SAINTE ", com$nom)
com$nom = gsub(" ST ", " SAINT ", com$nom)
com$nom = gsub(" STE ", " SAINTE ", com$nom)
# ou sont les "SAINT" et "SAINTE"?
com_saints = com[grepl(" SAINTE? |^SAINTE?", com$nom), ]

DEPS <- rgdal::readOGR("departements-20140306-100m.shp")
DEPS <- subset(DEPS, !DEPS$code_insee %in% as.character(971:976))
#save(DEPS, file="DEPS.Rdata")
plot(DEPS); points(com$long, com$lat, pch=".") # certaines grosses communes ont ete fusionnees
par(mar=c(0,0,0,0))
plot(DEPS, xlim=c(-1,5), ylim=c(40,52)); points(com_saints$long, com_saints$lat, pch=".") # semble pas y avoir de repartition particuliere des communes avec "saint"
# on retire les saints qui perturbent le classement? idem pour les
# exemples de commuens avec plusieurs mots dedans: on va virer les prepositions inutiles...
com[grepl('[^ ]+ [^ ]+ [^ ]+', com$nom), ] %>% sample_n(50)
com$nom = gsub("^DES? |^L[EA]?S? |^SAINTE? ", "", com$nom)
com$nom = gsub(" D[EU]?S? | L[EA]?S? | SAINTE? | SUR | AUX? | EN | ET | SOUS ", " ", com$nom)
#save(com, file="com.Rdata")

######## REMPLACER ST PAR SAINT STE ...

# exemple de communes proches (alphabetique)
com %>% arrange(nom) %>% slice(1000:1050) %>% pull(nom)
# distance exemple
stringdist("ARDILLEUX", "ARDILLIERES", method="jaccard", q=4)
# normalisation de la mesure par la longueur du plus grand des deux? bof
lambda001 = function(str1, str2) stringdist(str1, str2, method="cosine", q=4)
# cosine & jaccard sont interessants, couplé avec q=3
# potentiellement une autre mesure avec inversions de lettres aussi (Levenshtein)
lambda002 = function(str1, str2){
  meas1 = stringdist::stringdist(a=str1, b=str2, method="cosine", q=3)
  meas2 = stringdist::stringdist(a=str1, b=str2, method="lv")/(nchar(str1)+nchar(str2))*2
  return((meas1+meas2)/2)  
}
com %>% mutate(d_city = stringdist("MONTIGNY LOING", nom, method="jaccard", q=4)) %>% arrange(d_city) %>% head(50)
com %>% mutate(d_city = lambda002("FERTE AUBIN", nom)) %>% arrange(d_city) %>% head(50)
com_f <- com %>% mutate(d_city = lambda002("WASHINGTON", nom)) %>% arrange(d_city) %>% head(100)

# melange de cosineQ3 et levenshtein idéal.

library(flexclust)
library(cluster)
# pam accepts dissimilarity matrix
library(proxy)
# compute dist matrix custom
mydist <- proxy::dist(x=com$nom[1:100], method=lambda002)
mydist <- stringdistmatrix(a=com$nom[1:100], method="cosine", q=3)

# Plot mes communes les plus proches en toponymie



stringdistmatFast <- function(test)
{
  m = diag(0, length(test))
  sapply(1:(length(test)-1), function(i)
  {
    m[,i] <<- c(rep(0,i), lambda002(test[i],test[(i+1):length(test)]))
  }) 
  
  `dimnames<-`(m + t(m), list(test,test))
}

# DISTANCE COMPUTATION AND CLUSTERING
# on prend 1/4 des communes au hasard pour traiter le clustering, comme ca on passe de 30 minutes à 2 minutes de calcul!
set.seed(1234)
com2 = com %>% sample_frac(0.15)
mydist = stringdistmatFast(com2$nom)
mydist[is.na(mydist)] <- 2
mydist2=as.dist(mydist)
clus <- pam(x=mydist, diss=TRUE, k=12, do.swap = FALSE)
#clus2 <- dbscan::dbscan(mydist2, eps=0.4, minPts = 5); table(clus2$cluster);
# medoids
clus$medoids
com2['clus']=clus$cluster
#com2['clus2']=clus2$cluster
# PLOT RESULT
plot(DEPS); 
com3 = com2 %>% filter(clus!=1)
points(com2$long, com2$lat, pch=".", col=gg_color_hue(12)[com2$clus], cex=3) # ajouter taille point selon ranking
split(com2, com2$clus) %>% lapply(function(x) sample_n(x, 5))
table(com2$clus)

# nomber cluser
pamk.best <- pamk(mydist2, diss=TRUE, krange=2:20)

# save
# save(clus, mydist, file="clus_cosine3q_lvnormaliz_sample0.5.Rdata")


# test sur limite max distmatrix
com2 = com %>% sample_frac(0.25)
mydist = stringdistmatFast(com2$nom)
mydist[is.na(mydist)] <- 1
mydist[mydist > 0.6] <- 1E3
mydist2=as.dist(mydist)
clus <- pam(x=mydist2, diss=TRUE, k=18, do.swap = FALSE)
com2['clus']=clus$cluster
table(com2$clus)
clus$medoids
split(com2, com2$clus) %>% lapply(function(x) sample_n(x, 8))
pamk.best <- pamk(mydist2, diss=TRUE, krange=seq(2,50,2), do.swap = FALSE)
plot.ts(pamk.best$crit)
com2 %>% filter(clus==3) %>% sample_n(10) %>% pull(nom)
for (i in 1:18){
com3 = com2 %>% filter(clus %in% i)
plot(DEPS, main=i); points(com3$long, com3$lat, pch=20, cex=0.8, col=com3$clus) # certaines grosses communes ont ete fusionnees
}
keep_clus=c(2,7,9,10,11,12,18)
com3 = com2 %>% filter(clus %in% keep_clus)
cols=c("black","red","green", "yellow","purple", "orange", "blue")
plot(DEPS); points(com3$long, com3$lat, pch=20, cex=1, col=cols[as.numeric(factor(com3$clus))]) # certaines grosses communes ont ete fusionnees
legend(x=-8.4, y=46, legend=clus$medoids[keep_clus], col=cols, pch=20)

predict.pam = function(mycity, kmax=10, n.out=3){
  temp = mycity  %>% 
    gsub("-", " ", .) %>%
    gsub("^DES? |^L[EA]?S? |^SAINTE? ", "", .) %>%
    gsub(" D[EU]?S? | L[EA]?S? | SAINTE? | SUR | AUX? | EN | ET | SOUS ", " ", .) %>%
    lambda002(com$nom) %>% 
    cbind.data.frame(com, "dist_new_city"=.) %>%
    arrange(dist_new_city) %>%
    head(kmax) %>%
    mutate(dist_new_city=1/dist_new_city) %>% 
    group_by(dpmt) %>% 
    filter(!is.infinite(dist_new_city)) %>%
    summarize(dist_new_city=sum(dist_new_city)) %>% 
    na.omit %>% 
    {sample(.$dpmt, size=1000, prob=.$dist_new_city, replace=TRUE)} %>% 
    table %>% 
    prop.table %>% 
    '*'(100) %>% 
    round(2) %>% 
    sort(decreasing=TRUE) 
  if (length(temp)==1){
    data.frame(.=names(temp), Freq=temp) %>%
      setNames(c("dpmt", "probability")) %>% 
      mutate(dpmt=as.character(dpmt)) %>%
      left_join(deps_names, by = "dpmt") %>% 
      select(-dpmt) %>% 
      head(n.out)
  } else {
    temp %>%
      data.frame %>%
      setNames(c("dpmt", "probability")) %>% 
      mutate(dpmt=as.character(dpmt)) %>%
      left_join(deps_names, by = "dpmt") %>% 
      select(-dpmt) %>% 
      head(n.out)
  }
}
predict.pam("PARIS")

test=sapply(com$nom[1:1000], function(x) predict.pam(x, n.out=1)$dpmt_long)
com4=com %>% head(1000)
com4['pred']=data.frame(dpmt_long=test) %>% left_join(deps_names) %>% .$dpmt
