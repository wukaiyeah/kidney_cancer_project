library('ggplot2')
library('tidyr')
library('dplyr')
library('tibble')
library('pROC')
library('EvaluationMeasures')
##---doctor cls FPR TPR calculate
setwd("D:/AI_diagnosis/Renal_cancer_project/figures")
options(digits=2)



fpr_tpr <- function(values){
  FPR <- EvaluationMeasures.FPR(Real = subtype_cls$subtype, Predicted = values)
  TPR <- EvaluationMeasures.TPR(Real = subtype_cls$subtype, Predicted = values)
  return(c(FPR, TPR))
}
# tpr_fpr <- function(values){
#   truth <- subtype_cls$subtype
#   tp <- sum(values[which(values == 1)] == truth[which(values == 1)])
#   fn <- sum(values[which(values == 0)] != truth[which(values == 0)])
#   tn <- sum(values[which(values == 0)] == truth[which(values == 0)])
#   fp <- sum(values[which(values == 1)] != truth[which(values == 1)])
#   tpr <-  tp / (tp + fn)
#   fpr = fp / (fp + tn)
# }



##--load clinical 
clinical <- read.csv('clinical_info_all_cases.csv', header = TRUE)
clinical <- clinical[,c(1,5,3)]
truth_subtype <- clinical[,c(1,2)]
truth_stage <- clinical[,c(1,3)]
##-load subtype
doc_subtype <- read.csv('../expert_cls/doctor_subtype_cls_result.csv',header = TRUE)
colnames(doc_subtype) <- c('case_id', 'doctor_1','doctor_2','doctor_3','doctor_4')
subtype_cls <- left_join(doc_subtype, truth_subtype, by = 'case_id')
subtype_cls <- column_to_rownames(subtype_cls, var = 'case_id')

doc_subtype_eval <- t(as.data.frame(apply(subtype_cls[,-5],2,fpr_tpr )))
doc_subtype_eval <- rownames_to_column(as.data.frame(doc_subtype_eval), var = 'source')
doc_subtype_eval <- cbind(c(rep('subtype',4)),doc_subtype_eval)
colnames(doc_subtype_eval) <- c('type','source','FPR','TPR')
doc_subtype_eval$source <- gsub('_','', doc_subtype_eval$source)



##-load stage
doc_stage <- read.csv('../expert_cls/doctor_stage_cls_result.csv',header = TRUE)
colnames(doc_stage) <- c('case_id', 'doctor_1','doctor_2','doctor_3','doctor_4')
stage_cls <- left_join(doc_stage, truth_stage, by = 'case_id')
stage_cls <- column_to_rownames(stage_cls, var = 'case_id')
doc_stage_eval <- t(as.data.frame(apply(stage_cls[,-5],2,fpr_tpr )))
doc_stage_eval <- rownames_to_column(as.data.frame(doc_stage_eval), var = 'source')
doc_stage_eval <- cbind(c(rep('stage',4)),doc_stage_eval)
colnames(doc_stage_eval) <- c('type','source','FPR','TPR')
doc_stage_eval$source <- gsub('_','', doc_stage_eval$source)
##--ROC curve with doctor

# load dataset
dataset <- read.csv('testset_subtype_stage_pred_proba.csv', header = TRUE, sep = ',')

# for subtype
subtype <- dataset[,1:2]
colnames(subtype) <- c('label', 'proba')

#define object to plot and calculate AUC
#rocobj <- roc(subtype$label, subtype$proba, smooth = TRUE, smooth.n = 100)
rocobj <- pROC::roc(subtype$label, subtype$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]
# 
auc <- data.frame(x = 0.75, y = 0.062, text = c('ROC curve (Area = 0.83)'))
box <- data.frame(x = c(0.45,0.45,1,1),
                  y = c(0.01,0.12,0.12,0.01))
line_table <- data.frame(x= c(0.46, 0.51),
                         y = c(0.062,0.062))
#create ROC plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#61A0A8', size = 3.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_point(data = doc_subtype_eval, aes(x = FPR, y = TPR, color = source),size = 15, shape = 18)+
  #scale_colour_manual(values = c('#C23531', '#2F4554','#CA8622','#BDA29A'))+
  geom_text(data = doc_subtype_eval, aes(x = FPR, y = TPR, label = source),size = 13, color = 'black',vjust = 1.6)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 13,  show.legend = NA)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#61A0A8', size = 3.5)+
  
  labs(title = 'Histologic Subtype ROC Curve', y = 'Sensitivity', x = '1 - specificity')+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = '')


ggsave("subtype_roc_curve.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("subtype_roc_curve.pdf", device = "pdf", width = 16, height = 12, dpi = 300)


# for stage
stage <- dataset[,3:4]
colnames(stage) <- c('label', 'proba')

#define object to plot and calculate AUC
#rocobj <- roc(stage$label, stage$proba, smooth = TRUE, smooth.n = 100)
rocobj <- pROC::roc(stage$label, stage$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

auc <- data.frame(x = 0.75, y = 0.062, text = c('ROC curve (Area = 0.80)'))
box <- data.frame(x = c(0.45,0.45,1,1),
                  y = c(0.01,0.12,0.12,0.01))
line_table <- data.frame(x= c(0.46, 0.51),
                   y = c(0.062,0.062))
#create ROC plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#D48265', size = 3.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_point(data = doc_stage_eval, aes(x = FPR, y = TPR, color = source),size = 15, shape = 18)+
  scale_fill_manual(values = c('#C23531', '#2F4554','#61A0A8','#D48265','#91C7AE'))+
  geom_text(data = doc_stage_eval, aes(x = FPR, y = TPR, label = source),size = 13, color = 'black',vjust = 1.6)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 13,  show.legend = NA)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#D48265', size = 3.5)+
  
  labs(title = 'Pathologic Stage ROC Curve',  y = 'Sensitivity', x = '1 - specificity')+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = '')

ggsave("stage_roc_curve.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("stage_roc_curve.pdf", device = "pdf", width = 16, height = 12, dpi = 300)



# for grade
# load dataset
dataset <- read.csv('testset_grade_pred_proba.csv', header = TRUE, sep = ',')

# for subtype
subtype <- dataset[,1:2]
colnames(subtype) <- c('label', 'proba')

#define object to plot and calculate AUC
#rocobj <- roc(subtype$label, subtype$proba, smooth = TRUE, smooth.n = 100)
rocobj <- pROC::roc(subtype$label, subtype$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

auc <- data.frame(x = 0.75, y = 0.062, text = c('ROC curve (Area = 0.77)'))
box <- data.frame(x = c(0.45,0.45,1,1),
                  y = c(0.01,0.12,0.12,0.01))
line_table <- data.frame(x= c(0.46, 0.51),
                         y = c(0.062,0.062))
# '#91C7AE'
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#91C7AE', size = 3.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 13,  show.legend = NA)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#91C7AE', size = 3.5)+
  
  labs(title = 'Pathologic Grade ROC Curve',  y = 'Sensitivity', x = '1 - specificity')+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = '')

ggsave("grade_roc_curve.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("grade_roc_curve.pdf", device = "pdf", width = 16, height = 12, dpi = 300)

