## prepare dataset for structural equatuon modeling input
library('dplyr')
library('tibble')
library('limma')
# set working directory
setwd('D:/kidney_project/figures')
# prepare datatable
image_feature <- read.table('D:/kidney_project/bioinfo/images_features_table.txt', sep = '\t', header = TRUE)
# remove duplicate
case_id <- c()
for(i in 1:nrow(image_feature)){
  case_id <- append(case_id, strsplit(as.character(image_feature$sample_id), '_')[[i]][1])
}

# image_feature <- limma::avedups(image_feature, ID = case_id) # avrage
image_feature <- image_feature[!duplicated(case_id),]
image_feature <- image_feature[,-1]
case_id <- case_id[!duplicated(case_id)]
rownames(image_feature) <- case_id
image_feature <- rownames_to_column(image_feature, var = 'case_id')
name_alias <- read.table('images_features_name_alias.txt', header = TRUE, sep = '\t')

colnames(image_feature)[2:201] <- c(paste('t',as.character(name_alias$alias), sep = '_'),paste('r',as.character(name_alias$alias), sep = '_'))
# input other table
emt_table <- read.csv('features_table_for_emt_cls.csv', header = TRUE, sep = ',')
emt_table <- emt_table[,c(1, 102, 103)]

mut_table <- read.csv('features_table_for_mutation_class.csv', header = TRUE, sep = ',')
mut_table <- mut_table[,c(1, 102)]

purity_table <- read.csv('features_table_for_purity_cls.csv', header = TRUE, sep = ',')
purity_table <- purity_table[,c(1, 102,103)]

miRNA_table <- read.csv('features_table_for_sutype_miRNA_cls.csv', header = TRUE, sep = ',')
miRNA_table <- miRNA_table[,c(1, 102)]

mRNA_table <- read.csv('features_table_for_sutype_mRNA_cls.csv', header = TRUE, sep = ',')
mRNA_table <- mRNA_table[,c(1, 102)]

# merge
image_feature <- inner_join(image_feature, emt_table, by = 'case_id')
image_feature <- inner_join(image_feature, purity_table, by = 'case_id')
image_feature <- inner_join(image_feature, miRNA_table, by = 'case_id')
image_feature <- inner_join(image_feature, mRNA_table, by = 'case_id')
image_feature <- inner_join(image_feature, mut_table, by = 'case_id')

# merge stage & grade
clinical <- read.csv('include_patient_clinical.csv', header = TRUE, sep = ',')
clinical <- clinical[,c(1,5,6)]
clinical$stage <- as.character(clinical$stage)
clinical$grade <- as.character(clinical$grade)
clinical <- clinical[which(clinical$grade != 'None'),]


clinical$grade[grep('1',clinical$grade)] <- 1
clinical$grade[grep('2',clinical$grade)] <- 2
clinical$grade[grep('3',clinical$grade)] <- 3
clinical$grade[grep('4',clinical$grade)] <- 4

clinical$stage[grep('1',clinical$stage)] <- 1
clinical$stage[grep('2',clinical$stage)] <- 2
clinical$stage[grep('3',clinical$stage)] <- 3
clinical$stage[grep('4',clinical$stage)] <- 4

image_feature <- inner_join(image_feature, clinical, by = 'case_id')

