#!/usr/bin/R
library('dplyr')
library('tibble')
library('Rtsne')
library('pheatmap')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load dataset
datatable = read.table('images_genomic_features_table.txt', header = TRUE, sep = '\t')
features_table = datatable[,c(1,3,12,14,16:101)]
#features_table = datatable[,1:101]
rownames(features_table) <- NULL
features_table <- column_to_rownames(features_table, var = 'case_id')

remove_case1 <- c('TCGA-CZ-4865','TCGA-B0-4713','TCGA-DV-5565','TCGA-CJ-4920','TCGA-BP-5192','TCGA-B0-5697','TCGA-KM-8441','TCGA-BP-4965')
remove_case2 <- c('TCGA-B0-5697','TCGA-BP-5192','TCGA-CJ-4907','TCGA-B0-5085','TCGA-DW-5560','TCGA-BP-4965','TCGA-KN-8430')
remove_case3 <- c('TCGA-CZ-5462','TCGA-KM-8438')
remove_case4 <- c('TCGA-G7-A8LB','TCGA-B8-5162')
features_table <- features_table[-c(143,1,150,127,91,8,165.69),]
features_table <- features_table[-c(8,98,122,5,147,67,165),]
features_table <- features_table[-c(137,151),]
features_table <- features_table[-c(146,20),]

normalize <- function(values){
  min_value <- min(values)
  max_value <- max(values)
  return((values - min_value)/(max_value - min_value))
}



# EMT score 排序后再

anno <- datatable[,c(1,102)]
features_table <- inner_join(rownames_to_column(as.data.frame(features_table), var = 'case_id'), anno, by = 'case_id')
features_table <- column_to_rownames(features_table, var = 'case_id')
#features_table <- features_table[order(features_table$EMT_score),]

normalized_features_table <- t(apply(features_table[,-90],2,normalize))

anno <- data.frame(EMT_score = features_table$EMT_score)
rownames(anno) <- row.names(features_table)

#write.csv(normalized_features_table , 'feature_table_for_class.csv', row.names = TRUE)
EMT_label = c()
EMT_label[which(anno$EMT_score > 0.3)] = 1
EMT_label[which(anno$EMT_score <= 0.3)] = 0
anno$EMT_label <- EMT_label
#write.csv(anno, 'feature_label_for_class.csv', row.names = FALSE)
# sort features
shap_table <- read.csv('shap_values_emt_score_cls.csv', header = TRUE, row.names = 1)

mean_abs <- function(values){
  return(mean(abs(values)))
}

shap_mean_table <- apply(shap_table, 2, mean_abs)
shap_mean_table <- as.data.frame(shap_mean_table)
colnames(shap_mean_table) <- 'shap_mean'
shap_mean_table <- rownames_to_column(shap_mean_table, var = 'features')
shap_mean_table <- shap_mean_table[order(shap_mean_table$shap_mean,decreasing = TRUE),]
filterd_table <- shap_mean_table[which(shap_mean_table$shap_mean > 0),]

#normalized_features_table <- normalized_features_table[filterd_table$features,]


pdf('test.pdf',25,10)
pheatmap(normalized_features_table,
         #scale = 'row',
         annotation = anno,
         cluster_rows = TRUE,
         cluster_cols = TRUE)
dev.off()

## corr

# library(factoextra)
# #fviz_nbclust(normalized_features_table, kmeans, method = "wss")
# #利用k-mean是进行聚类
# km_result <- kmeans(normalized_features_table, 10, nstart = 24)
# fviz_cluster(km_result, data = normalized_features_table,
#              #palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
#              ellipse.type = "euclid",
#              star.plot = TRUE, 
#              repel = TRUE,
#              ggtheme = theme_minimal()
# )
# 
# 
# #---层次聚类
# result_dist <- dist(normalized_features_table, method = "euclidean")
# #产生层次结构
# result_hc <- hclust(d = result_dist, method = "ward.D2")
# fviz_dend(result_hc, k = 9, 
#           cex = 0.5, 
#           #k_colors = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
#           color_labels_by_k = TRUE, 
#           rect = TRUE          
# )
# features_order <- result_hc$labels[result_hc[["order"]]]
# cluster1 <- features_order[1:8]
# cluster2 <- features_order[9:18]
# cluster3 <- features_order[19:22]
# cluster4 <- features_order[23:39]
# cluster5 <- features_order[40:48]
# cluster6 <- features_order[49:62]
# cluster7 <- features_order[63:73]
# cluster8 <- features_order[74:79]
# cluster9 <- features_order[80:89]
# 
# 
# anno <- datatable[,c(1,102)]
# features_table <- inner_join(rownames_to_column(as.data.frame(features_table), var = 'case_id'), anno, by = 'case_id')
# features_table <- column_to_rownames(features_table, var = 'case_id')

normalized_features_table <- t(normalized_features_table)
normalized_features_table <- cbind(normalized_features_table, anno$EMT_score)
colnames(normalized_features_table)[90] <- 'EMT_score'


# for(i in 2:(length(filterd_table$features))){
#   #cluster_feature <- get(paste('cluster',i,sep =''))
#   cluster_feature <- filterd_table$features[1:i]
#   
#   features = cluster_feature[1]
#   for(j in 2:length(cluster_feature)){
#     features <- paste(features, cluster_feature[j], sep = '+')
#   }
#   result = lm(as.formula(paste('EMT_score',features,sep = '~')), data = as.data.frame(normalized_features_table))
#   print(summary(result)$r.squared)
# }



# 连续变量对离散
library('ltm')
for (i in 1:length(filterd_table$features)) {
  feature = filterd_table$features[i]
  
  cor<- biserial.cor(normalized_features_table[,feature], anno$EMT_label, use = c("all.obs", "complete.obs"), level = 1)
  print(cor)
}

