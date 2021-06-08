#!/usr/bin/R
library('dplyr')
library('tibble')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')


# load EMT score
emt_score <- read.table('renal_cancer_emt_score.txt', header = TRUE, sep = '\t')
emt_score <- emt_score[,c(1,3)]
EMT_label = c()
EMT_label[which(emt_score$Creighton_EMT_score > 0)]  <- 'high'
EMT_label[which(emt_score$Creighton_EMT_score <= 0)]  <- 'low'

emt_score <- cbind(emt_score, EMT_label)
#emt_score <- emt_score[,c(1,3)]
colnames(emt_score) <- c('case_id', 'EMT_score', 'EMT_label')

# load tumor purity
emt_score <- read.csv('EMT_score_TCGA.csv', header = TRUE, sep=',', quote = '')
purity_score <- emt_score[,c(2,26)]
case_id <- substr(emt_score$file_id, 1,12)
purity_score <- cbind(case_id, purity_score )
purity_score <- purity_score[,-2]
colnames(purity_score)[2] <- 'purity'
purity_score <- na.omit(purity_score)
purity_label = c()
purity_label[which(purity_score$purity > 0.6)] <- 'high'
purity_label[which(purity_score$purity <= 0.6)] <- 'low'
purity_score <- cbind(purity_score, purity_label)


# load somatic SNP
SNP <- read.table('renal_cancer_somatic_mutaion_count.txt', header = TRUE, sep = '\t')
case_id <- substr(SNP$file_id, 1,12)
SNP_num <- cbind(case_id, SNP)
SNP_num <- SNP_num[,-2]
colnames(SNP_num)[2] <- 'snp_num'

snp_label <- c()
snp_label[which(SNP_num$snp_num > 60)] <- 'high'
snp_label[which(SNP_num$snp_num <= 60)] <- 'low'
snp_num <- cbind(SNP_num, snp_label)
# load CNV
cnv_count <- read.table('renal_tumor_cnv_score.txt', sep = '\t', header = TRUE)
CNV_label <- c()
CNV_label[which(cnv_count$cnv_score > 4000)] <- 'high'
CNV_label[which(cnv_count$cnv_score <= 4000)] <- 'low'
cnv_num <- cbind(cnv_count, CNV_label)
colnames(cnv_num) <- c('case_id', 'cnv_num', 'cnv_label')

# load features_table
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:102)]
feature_names <- read.table('images_features_name_alias.txt',header = TRUE, sep = '\t')
feature_names <- as.character(feature_names$alias)
colnames(features)[2:101] <- feature_names

features_table <- inner_join(features, emt_score, by = 'case_id')
features_table <- inner_join(features_table, purity_score, by = 'case_id')
features_table <- inner_join(features_table, snp_num, by = 'case_id')
features_table <- inner_join(features_table, cnv_num, by = 'case_id')


write.table(features_table, 'images_genomic_features_table.txt', sep = '\t', quote = FALSE, row.names = FALSE)



