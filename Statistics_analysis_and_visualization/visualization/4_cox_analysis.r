#!/usr/bin/R
##---This script aims to conduct univariate Cox analysis
##--packages preparation
# install.packages('survival')
library('survival')
# BiocManager::install('survminer')
library('survminer') # for drawing
library('dplyr')
library('survcomp')
library('tibble')
##--environment setting
setwd("D:/AI_diagnosis/Renal_cancer_project/figures")

##--load survival data
surv_info <- read.table('renal_tumor_images_features_surv_info.txt', header = TRUE, sep = '\t')

# set survival month >0 && <100 
#clinical <- clinical[which(clinical$overall.survival.months > 0),]
#clinical <- clinical[which(clinical$overall.survival.months < 100),]
#clinical <- na.omit(clinical)

##--process survival analysis
surv.time <- surv_info$months
surv.event <- surv_info$status

features = c('kidney_original_glszm_LargeAreaLowGrayLevelEmphasis', 'tumor_original_firstorder_TotalEnergy',
             'tumor_original_glcm_ClusterTendency','tumor_original_shape_MeshVolume')

result <- survcomp::hazard.ratio(surv_info$kidney_original_glszm_LargeAreaLowGrayLevelEmphasis, surv.time = surv.time, surv.event = surv.event,
                      alpha = 0.05,
                      method.test = c("wald"))

HR <- result$hazard.ratio
print(HR)




# fitting survival curve


# # drawling plot
# Cox.analysis <- function(feature){
#   cox.result <- coxph(Surv(time = surv.time, surv.event)~ feature, data = surv_info)
#   cox.summary <- summary(cox.result)
#   Coef <- cox.summary$coefficients[1, 1]
#   HR <- cox.summary$coefficients[1, 2]
#   P.val <- cox.summary$coefficients[1, 5]
#   Upper <- cox.summary$conf.int[1, 4]
#   Lower <- cox.summary$conf.int[1, 3]
#   cox <- c(Coef, HR, Upper, Lower, P.val)
#   return(cox)
# }
# 
# cox.result <- apply(surv_info[,4:length(colnames(surv_info))], 2, Cox.analysis)
# cox.result <- as.data.frame(t(cox.result))
# colnames(cox.result) <- c('Cox.coef', 'Cox.HR', 'Cox.Upper', 'Cox.Lower', 'Cox.pval')
# cox.result$Cox.adjP <- p.adjust(cox.result$Cox.pval, method = "fdr")
# write.table(feat_surv , 'renal_tumor_images_features_surv_info.txt', sep='\t', quote = FALSE, row.names = FALSE)
# #--filter
# cox_result_sig <- cox.result[which(cox.result$Cox.pval < 0.05),]
# cox_result_sig <- cox_result_sig[order(cox_result_sig$Cox.HR, decreasing = TRUE),]




## save file
write.table(rownames_to_column(cox_result_sig,var = 'feature'), 'cox_analysis_result.txt', sep='\t', quote = FALSE, row.names = FALSE)
