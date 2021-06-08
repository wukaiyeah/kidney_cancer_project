#!/usr/bin/R
##---This script aims to conduct univariate Cox analysis
##--packages preparation
# install.packages('survival')
library('survival')
# BiocManager::install('survminer')
library('survminer') # for drawing
library('dplyr')
library('tibble')
##--environment setting
setwd("D:/AI_diagnosis/Renal_cancer_project/bioinfo")
##--load images feature file
features <- read.table('images_features_table.txt', header = TRUE, sep = '\t')
case_id = gsub('_.*', '',as.character(features$sample_id))
features = cbind(case_id, features)
# 去重复
features <- features[!duplicated(features$case_id),]
features <- features[,c(1,3:202)]
##--load survival data
surv_info <- read.table('renal_cancer_survival_info.txt', header = TRUE, sep = '\t')

# set survival month >0 && <100 
#clinical <- clinical[which(clinical$overall.survival.months > 0),]
#clinical <- clinical[which(clinical$overall.survival.months < 100),]
#clinical <- na.omit(clinical)

##--join expr with clincial table 
feat_surv <- left_join(surv_info, features, by = 'case_id')
feat_surv <- na.omit(feat_surv ) # omit NA lines


##--process survival analysis
surv.time <- feat_surv$months
surv.event <- feat_surv$status

# fitting survival curve


# drawling plot
Cox.analysis <- function(feature){
  cox.result <- coxph(Surv(time = surv.time, surv.event)~ feature, data = feat_surv)
  cox.summary <- summary(cox.result)
  Coef <- cox.summary$coefficients[1, 1]
  HR <- cox.summary$coefficients[1, 2]
  P.val <- cox.summary$coefficients[1, 5]
  Upper <- cox.summary$conf.int[1, 4]
  Lower <- cox.summary$conf.int[1, 3]
  cox <- c(Coef, HR, Upper, Lower, P.val)
  return(cox)
}

cox.result <- apply(feat_surv[,4:length(colnames(feat_surv))], 2, Cox.analysis)
cox.result <- as.data.frame(t(cox.result))
colnames(cox.result) <- c('Cox.coef', 'Cox.HR', 'Cox.Upper', 'Cox.Lower', 'Cox.pval')
cox.result$Cox.adjP <- p.adjust(cox.result$Cox.pval, method = "fdr")

write.table(feat_surv , 'renal_tumor_images_features_surv_info.txt', sep='\t', quote = FALSE, row.names = FALSE)


## save file
write.table(rownames_to_column(cox.result,var = 'feature'), 'cox_analysis_result.txt', sep='\t', quote = FALSE, row.names = FALSE)
