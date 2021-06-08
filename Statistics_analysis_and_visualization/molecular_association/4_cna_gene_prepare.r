#!/usr/bin/R
library('dplyr')
library('tibble')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# for TCGA-KIRC
kirc_table <- read.table('./kirc_tcga/data_CNA.txt', header = TRUE, sep = '\t')
kirc_table <- kirc_table[,-2]
# for TCGA-KIRP
kirp_table <- read.table('./kirp_tcga/data_CNA.txt',header = TRUE, sep = '\t')
kirp_table <- kirp_table[,-2]
# for TCGA-KICH
kich_table <- read.table('./kich_tcga/data_CNA.txt',header = TRUE, sep = '\t')
kich_table <- kich_table[,-2]
# merge
datatable <- inner_join(kirc_table, kirp_table, by = 'Hugo_Symbol')
datatable <- inner_join(datatable, kich_table, by = 'Hugo_Symbol')

sum_abs_cal <- function(cnv){
  cnv_score <- sum(abs(cnv))
  return(cnv_score)
}

datatable <- datatable[,-1]
cnv_score <- apply(datatable, 2, sum_abs_cal)
cnv_score <- as.data.frame(cnv_score)
cnv_score <- rownames_to_column(cnv_score, var = 'case_id')
cnv_score$case_id <- substr(gsub('\\.', '-',cnv_score$case_id), 1,12)
write.table(cnv_score, 'renal_tumor_cnv_score.txt', row.names = FALSE, quote = FALSE, sep = '\t')


# load features
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]

# merge
features_table <- inner_join(cnv_score, features, by = 'case_id')

# correlation calculate
cor_test <- function(feature){
  estimate <- cor.test(feature, log10(features_table$cnv_score), method = "pearson")$estimate
  return(estimate)
}

cor_coefficient <- apply(features_table[,3:102],2, cor_test)

print(sort(cor_coefficient, decreasing = TRUE))



