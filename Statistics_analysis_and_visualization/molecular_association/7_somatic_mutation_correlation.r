#!/usr/bin/R
library('dplyr')
library('tibble')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load  EMT score file download from  'Pan-cancer survey of epithelial–mesenchymal transition markers across The Cancer Genome Atlas'
datatable <- read.table('renal_cancer_somatic_mutaion_count.txt', header = TRUE, sep='\t', quote = '')

case_id <- substr(datatable$file_id, 1,12)
datatable <- cbind(case_id, datatable)
datatable <- datatable[,-2]

# load features
# load features
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
#features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]

# merge
features_table <- inner_join(datatable, features, by = 'case_id')


# correlation calculate
cor_test <- function(feature){
  estimate <- cor.test(feature, features_table$count, method = "pearson")$estimate
  return(estimate)
}

cor_coefficient <- apply(features_table[,3:102],2, cor_test)
print(sort(cor_coefficient, decreasing = TRUE))


