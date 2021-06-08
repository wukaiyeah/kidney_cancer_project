library('dplyr')
library('tibble')


setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# for TCGA-KIRC
surv_info = read.table('./kirc_tcga/data_bcr_clinical_data_patient.txt',header = TRUE, sep = '\t')
surv_info = cbind(surv_info['PATIENT_ID'], surv_info["OS_STATUS"], surv_info["OS_MONTHS"])
colnames(surv_info) <- c('case_id', 'status', 'months')

surv_info$status <- gsub('0:LIVING',1,surv_info$status)
surv_info$status <- gsub('1:DECEASED',2,surv_info$status)
surv_info$status <- as.numeric(surv_info$status)

kirc_surv_info<- surv_info

# for TCGA-KICH
surv_info = read.table('./kich_tcga/data_clinical_patient.txt',header = TRUE, sep = '\t')
surv_info = cbind(surv_info['PATIENT_ID'], surv_info["OS_STATUS"], surv_info["OS_MONTHS"])
colnames(surv_info) <- c('case_id', 'status', 'months')

surv_info$status <- gsub('0:LIVING',1,surv_info$status)
surv_info$status <- gsub('1:DECEASED',2,surv_info$status)
surv_info$status <- as.numeric(surv_info$status)
kich_surv_info<- surv_info

# for TCGA-KIRP
surv_info = read.table('./kirp_tcga/data_bcr_clinical_data_patient.txt',header = TRUE, sep = '\t')
surv_info = cbind(surv_info['PATIENT_ID'], surv_info["OS_STATUS"], surv_info["OS_MONTHS"])
colnames(surv_info) <- c('case_id', 'status', 'months')

surv_info$status <- gsub('0:LIVING',1,surv_info$status)
surv_info$status <- gsub('1:DECEASED',2,surv_info$status)
surv_info$status <- as.numeric(surv_info$status)
surv_info$months <- as.numeric(gsub('[Not Available]',NA,surv_info$months))

kirp_surv_info<- surv_info

# for KITS19
kits_surv_info<-  read.table('./kits19/kits_survival_info.txt', header = TRUE, sep = '\t')
# for CCRCC 
ccrcc_surv_info<-  read.table('./ccrcc/ccrcc_survival_info.txt', header = TRUE, sep = '\t')

surv_info <- rbind(kirc_surv_info, kich_surv_info, kirp_surv_info,kits_surv_info,ccrcc_surv_info)
write.table(surv_info, 'renal_cancer_survival_info.txt', sep ='\t', quote = FALSE, row.names = FALSE)

