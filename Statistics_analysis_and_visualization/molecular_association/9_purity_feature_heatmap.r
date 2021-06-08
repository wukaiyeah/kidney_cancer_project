#!/usr/bin/R
library('dplyr')
library('tibble')
library('pheatmap')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load features
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:202)]

# change feature names
feature_names <- read.table('images_features_name_alias.txt',header = TRUE, sep = '\t')
feature_names <- as.character(feature_names$alias)
feature_names <- append(paste('t',feature_names, sep = '_'),paste('r',feature_names, sep = '_'))
colnames(features)[2:201] <- feature_names

# load EMT score
emt_score <- read.table('renal_cancer_emt_score.txt', header = TRUE, sep = '\t')

# merge
features_table <- inner_join(emt_score, features, by = 'case_id')

##-----cluster
# sort
features_table <- features_table[order(features_table$Creighton_EMT_score),]
features_table <- features_table[,-c(2,3)]
rownames(features_table) <- NULL
features_table <- column_to_rownames(features_table, var = 'case_id')
# trans
features_table <- t(features_table)

normalize <- function(values){
  min_value <- min(values)
  max_value <- max(values)
  return((values - min_value)/(max_value - min_value))
}
normalized_features_table <- t(apply(features_table,1,normalize))


pheatmap(normalized_features_table,
         #scale = 'row',
         cluster_rows = TRUE,
         cluster_cols = FALSE)



 