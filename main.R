library(data.table)
library(cluster)
library(factoextra)
library(showtext)

setwd('/home/rstudio/workspace/multivariate_paper')

# Set up fonts for Korean text
font_add("noto", "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc")
showtext_auto()

data <- read.csv('./등록인구_20241202104941.csv', head=TRUE)

colnames(data) <- c('합계','구','세대','성합계','남자','여자','한국인합계',
                    '한국인남자','한국인여자','등록외국인합계','외국인남자','외국인여자',
                    '세대당인구','65세이상고령자')

data <- data[-c(1,2,3),] # row deletion
data <- data[,-1]  # col 1 deletion
write.csv(data, file="cleaned_hn.csv")
data <- data[,-c(2,3,4,5,6,9,12,13)] # Delete unnecessary cols


# data$ID <- seq(1,nrow(data))
# 
# data <- merge.data.frame(data[,c(1,6)],sapply(data[,c(2,3,4,5,6)], as.numeric),by='ID')

# Select features for clustering
features <- data[, c("한국인남자", "한국인여자", "외국인남자", "외국인여자")]

# Convert the selected features to numeric (in case they are not already)
features <- sapply(features, as.numeric)

# Normalize the data
scaled_data <- scale(features)

# Determine the optimal number of clusters using a scree plot
# fviz_nbclust(scaled_data, kmeans, method = "wss")
# Perform PCA on the scaled data
pca_result <- prcomp(scaled_data, center = TRUE, scale. = TRUE)

# Scree plot for principal components
fviz_eig(pca_result, addlabels = TRUE, ylim = c(0, 100), 
         main = "Scree Plot: Principal Components")

# K-means clustering
set.seed(42)
kmeans_result <- kmeans(scaled_data, centers = 4, nstart = 25)
data$kmeans_cluster <- kmeans_result$cluster

# Hierarchical clustering
hc <- hclust(dist(scaled_data), method = "ward.D2")

# Visualize dendrogram
plot(hc, labels = data$구, main = "Hierarchical Clustering Dendrogram", 
     xlab = "Districts", sub = "", cex = 0.8)

# Visualize k-means clustering
fviz_cluster(kmeans_result, data = scaled_data, geom = "point", 
             label = data$구, ellipse = TRUE, main = "K-means Clustering")

# Display results
print(data[, c("구", "kmeans_cluster")])