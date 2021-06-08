#!/usr/bin/R
library('dplyr')
library('tibble')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load features
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')

features <- features[,1:201]

z_score_norm <- function(values){
  mean_value <- mean(values)
  sd_value <- sd(values)
  z_score <- (values-mean_value)/sd_value
  return(z_score)
}

z_score <- apply(features[,2:dim(features)[2]], 2, z_score_norm)
rownames(z_score) <- as.vector(features$sample_id)

write.table(rownames_to_column(as.data.frame(z_score), var = 'sample_id'),'images_features_z_scores_table.txt', row.names = FALSE, quote = FALSE, sep = '\t')
