library('dplyr')
library('tibble')


setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# for TCGA-KIRC
grade_info = read.table('./kirc_tcga/data_bcr_clinical_data_patient.txt',header = TRUE, sep = '\t')
grade_info = cbind(grade_info['PATIENT_ID'], grade_info["GRADE"])
colnames(grade_info) <- c('case_id', 'grade')

grade_info$grade_label[grade_info$grade == 'G1'] = 1
grade_info$grade_label[grade_info$grade == 'G2'] = 1
grade_info$grade_label[grade_info$grade == 'G3'] = 0
grade_info$grade_label[grade_info$grade == 'G4'] = 0

kirc_grade_info<- grade_info


# for KITS19
kits_grade_info<-  read.table('./kits19/kits_grade_info.txt', header = TRUE, sep = '\t')
# for CCRCC 
ccrcc_grade_info<-  read.table('./ccrcc/ccrcc_grade_info.txt', header = TRUE, sep = '\t')

grade_info <- rbind(kirc_grade_info,kits_grade_info,ccrcc_grade_info)
grade_info <- na.omit(grade_info)

renal_case <- read.table('renal_tumor_case_id.txt', header = TRUE, sep = '\t')
grade_info <- left_join(renal_case, grade_info, by = 'case_id')
grade_info <- na.omit(grade_info)
write.table(grade_info, 'renal_cancer_grade_info.txt', sep ='\t', quote = FALSE, row.names = FALSE)

