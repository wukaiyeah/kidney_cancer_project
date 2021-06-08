#!/usr/bin/R
library('dplyr')
library('tibble')
library('corrplot')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load features
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]

# change feature names
feature_names <- read.table('images_features_name_alias.txt',header = TRUE, sep = '\t')
feature_names <- as.character(feature_names$alias)
#feature_names <- append(paste('t',feature_names, sep = '_'),paste('r',feature_names, sep = '_'))
colnames(features)[2:101] <- feature_names
rownames(features) <- NULL
features <- column_to_rownames(features, var = 'case_id')
features <- as.matrix(features)
features <- features[,c(2,11,13,15:100)]


# cormatrix
corr_matrix <- cor(features)
# inverse of matrix
inverse_corr_matrix <- solve(corr_matrix)
# 

