#!/usr/bin/R
library('dplyr')
library('tibble')
library('pheatmap')
library('TCGAbiolinks')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')


subtypes <- PanCancerAtlas_subtypes()

# load images feature table
features_table <- read.table('images_features_table.txt', header=TRUE, sep = '\t')
cases_id <- features_table$sample_id
case_id = gsub('_.*', '',as.character(cases_id))
# filter tcgabiolinks subtype
subtypes_info <- subtypes[which(substr(subtypes$pan.samplesID,1,12) %in% case_id),]
subtypes_info$pan.samplesID <- substr(subtypes_info$pan.samplesID,1,12)
#write.table(as.data.frame(subtypes_info), 'tcgabiolinks_rcc_subtype_info.txt',row.names = FALSE, quote = FALSE, sep = '\t',)
subtypes_info <- subtypes_info[grep('KIRC',subtypes_info$Subtype_Selected),]
subtypes_info <- subtypes_info[-grep('NA',subtypes_info$Subtype_Selected),] # rm 未分组
subtypes_info <- as.data.frame(subtypes_info)[,c(1,10)]
colnames(subtypes_info) <- c('case_id', 'TCGAsubtype')

# load features
features_table <-  read.table('images_features_table.txt', header = TRUE, sep = '\t')
cases_id <- features_table$sample_id
features_table <- cbind(case_id, features_table)
features_table <- features_table[,c(1,3:102)]
feature_names <- read.table('images_features_name_alias.txt', header = TRUE, sep = '\t')
colnames(features_table)[2:101] <- as.character(feature_names$alias)
# rm duplicate
features_table <- features_table[!duplicated(features_table$case_id),]
# filter sample
features_table <- inner_join(features_table, subtypes_info, by = 'case_id')
features_table <- column_to_rownames(features_table, var = 'case_id')
features_table <- features_table[,-101]
features_table <- t(features_table)
anno <- column_to_rownames(subtypes_info, var = 'case_id')
label <- c()
label[which(anno$TCGAsubtype == 'KIRC.1')] = 0
label[which(anno$TCGAsubtype == 'KIRC.2')] = 0
label[which(anno$TCGAsubtype == 'KIRC.3')] = 1
label[which(anno$TCGAsubtype == 'KIRC.4')] = 1
anno <- cbind(anno, label)

normalize <- function(values){
  min_value <- min(values)
  max_value <- max(values)
  return((values - min_value)/(max_value - min_value))
}
features_table <- features_table[,-131]

normalized_features_table <- t(apply(features_table,1,normalize))

normalized_features_table <- normalized_features_table[,-131]
pdf('tcgabiolinks_rcc_subtype_heatmap.pdf',15,10)
pheatmap(normalized_features_table, 
         annotation = anno,
         #scale = 'row',
         cluster_rows = TRUE,
         cluster_cols = TRUE,)
dev.off()
