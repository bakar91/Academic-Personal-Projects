library(ggplotgui)
library(cluster)
library(factoextra)
library(stringr)

#File Import & Name Identifier
chem<-read.csv("chem.csv", header=T)
chem$Ceramic.Name<-str_c(chem$Ceramic.Name,"-",chem$Part)
head(chem)
tail(chem)
summary(chem)
chem$Ceramic.Name<-str_c(chem$Ceramic.Name,"-",chem$Part)
chem1<-chem[c(-1,-2,-3)]
chem1

#Normalization of the Data
normalise<-function(df)
{
  return(((df-min(df))/(max(df)-min(df))*(1-0))+0)
}
chem1_nn<-as.data.frame(lapply(chem1,normalise))
chem1_n<-chem1_nn
rownames(chem1_n) <- chem[,1]
chem1_n

#Optimal clusters
fviz_nbclust(chem1, kmeans, method = "gap_stat")
fviz_nbclust(chem1_n, kmeans, method = "wss")
fviz_nbclust(chem1_n, kmeans, method = "silhouette")

#Clustering
ck_3<-kmeans(chem1_n,3)
ck_2<-kmeans(chem1_n,2)

#Cluster Plotting
clusplot(chem1, ck_3$cluster, color=TRUE, shade=TRUE, lines=0)
clusplot(chem1, ck_2$cluster, color=TRUE, shade=TRUE, lines=0)
fviz_cluster(ck_3,chem1_n,labelsize = 8)
fviz_cluster(ck_2,chem1_n,labelsize = 8)
fviz_cluster(ck_3,chem1_n,ellipse.type = "norm",labelsize = 8)
fviz_cluster(ck_2,chem1_n,ellipse.type = "norm",labelsize = 8)


