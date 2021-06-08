#!/usr/bin/R
library('dplyr')

setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load  EMT score file download from  'Pan-cancer survey of epithelial–mesenchymal transition markers across The Cancer Genome Atlas'
emt_score <- read.csv('EMT_score_TCGA.csv', header = TRUE, sep=',', quote = '')
emt_score <- emt_score[,c(2,24,25)]
case_id <- substr(emt_score$file_id, 1,12)
emt_score <- cbind(case_id, emt_score )

# load target_case id
target_case_id <- read.table('renal_tumor_case_id.txt', sep = '\t', header = TRUE)

emt_score <- inner_join(emt_score, target_case_id, by = 'case_id')
emt_score <- emt_score[,-2]
colnames(emt_score) <- c('case_id', 'Byers_EMT_score', 'Creighton_EMT_score')
write.table(emt_score, 'renal_cancer_emt_score.txt', sep = '\t', row.names = FALSE, quote = FALSE)

