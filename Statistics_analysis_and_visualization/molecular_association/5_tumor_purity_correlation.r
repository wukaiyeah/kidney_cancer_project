#!/usr/bin/R
library('dplyr')
library('tibble')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load  EMT score file download from  'Pan-cancer survey of epithelial–mesenchymal transition markers across The Cancer Genome Atlas'
emt_score <- read.csv('EMT_score_TCGA.csv', header = TRUE, sep=',', quote = '')
purity_score <- emt_score[,c(2,26)]
case_id <- substr(emt_score$file_id, 1,12)
purity_score <- cbind(case_id, purity_score )
purity_score <- purity_score[,-2]
colnames(purity_score)[2] <- 'purity'

purity_score$purity <- as.numeric(gsub('NaN', 'NA',purity_score$purity))


# load features
# load features
features <- read.table('images_features_z_scores_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]

# merge
features_table <- inner_join(purity_score, features, by = 'case_id')
features_table$purity <- as.numeric(gsub('NaN', 'NA', features_table$purity))



# correlation calculate
cor_test <- function(feature){
  estimate <- cor.test(feature, features_table$purity, method = "pearson")$estimate
  return(estimate)
}

cor_coefficient <- apply(features_table[,3:102],2, cor_test)

print(sort(cor_coefficient, decreasing = TRUE))

