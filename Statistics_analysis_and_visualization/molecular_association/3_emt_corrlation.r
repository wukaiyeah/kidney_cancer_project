#!/usr/bin/R
library('dplyr')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load features
features <- read.table('images_features_z_scores_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
#features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]

# load EMT score
emt_score <- read.table('renal_cancer_emt_score.txt', header = TRUE, sep = '\t')

# merge
features_table <- inner_join(emt_score, features, by = 'case_id')

# correlation calculate
cor_test <- function(feature){
  estimate <- cor.test(feature, features_table$Byers_EMT_score, method = "pearson")$estimate
  return(estimate)
}

cor_coefficient <- apply(features_table[,4:103],2, cor_test)

print(sort(cor_coefficient, decreasing = TRUE))

