library('dplyr')

# for ccrcc
data1 <-read.table('D:/AI_diagnosis/Renal_cancer_project/bioinfo/ccrcc/ccrcc_info.txt',header = TRUE, sep = '\t')
# for TCGA-KIRC
data2 <- read.csv('D:/AI_diagnosis/Renal_cancer_project/bioinfo/kirc_tcga/data_bcr_clinical_data_patient.txt', header = TRUE, sep = '\t')
data2 <- data2[,c(2,41,9,4,19,5)]
data2 <- data2[5:nrow(data2),]
colnames(data2) <- c('case_id', 'age', 'sex', 'subtype', 'stage', 'grade')

# for TCGA-KICH
data3 <- read.csv('D:/AI_diagnosis/Renal_cancer_project/bioinfo/kich_tcga/data_clinical_patient.txt', header = TRUE, sep = '\t')
data3 <- data3[5:nrow(data3), c(1,36,7,17,17,17)]
colnames(data3) <- c('case_id', 'age', 'sex', 'subtype', 'stage', 'grade')
data3$subtype <- rep('chromophobe', nrow(data3))
data3$grade <- rep('None', nrow(data3))

# for TCGA-KIRP
data4 <- read.csv('D:/AI_diagnosis/Renal_cancer_project/bioinfo/kirp_tcga/data_bcr_clinical_data_patient.txt', header = TRUE, sep = '\t')
data4 <- data4[5:nrow(data4), c(2,16,8,4,21,21)]
colnames(data4) <- c('case_id', 'age', 'sex', 'subtype', 'stage', 'grade')
data4$grade <- rep('None', nrow(data4))
data4$stage <- as.vector(data4$stage)
data4$stage[which(data4$stage == '[Not Available]')] = 'None'

# for KITS19
data5 <- read.table('D:/AI_diagnosis/Renal_cancer_project/bioinfo/kits19/kits_info.txt',header = TRUE, sep = '\t')

# merge
datatable <- rbind(data5, data1, data2, data3, data4)


# initial case
total_case <- read.table('D:/AI_diagnosis/Renal_cancer_project/bioinfo/initial_cases_id.txt',header = FALSE)
colnames(total_case) <- 'case_id'

# merge
datatable <- left_join(total_case, datatable, by = 'case_id')
write.table(datatable, 'D:/AI_diagnosis/Renal_cancer_project/bioinfo/initial_cases_clinical_info.txt', sep = '\t', quote = FALSE, row.names = FALSE)
