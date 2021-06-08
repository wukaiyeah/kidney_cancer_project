library('ggplot2')
library('tidyr')
library('pROC')


setwd("D:/AI_diagnosis/Renal_cancer_project/figures")

# load dataset
dataset <- read.csv('testset_subtype_stage_pred_proba.csv', header = TRUE, sep = ',')

# for subtype
subtype <- dataset[,1:2]
colnames(subtype) <- c('label', 'proba')

#define object to plot and calculate AUC
#rocobj <- roc(subtype$label, subtype$proba, smooth = TRUE, smooth.n = 100)
rocobj <- roc(subtype$label, subtype$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

auc <- data.frame(x = 0.8, y = 0.1, text = c('AUC = 0.82'))


#create ROC plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#61A0A8', size = 2.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 16,  show.legend = NA)+
  labs(title = 'Subtype ROC Curve',y = 'True Positive Rate', x = 'False Positive Rate')+
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
rocobj <- roc(stage$label, stage$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

auc <- data.frame(x = 0.8, y = 0.1, text = c('AUC = 0.80'))


#create ROC plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#D48265', size = 2.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 16,  show.legend = NA)+
  labs(title = 'Stage ROC Curve', y = 'True Positive Rate', x = 'False Positive Rate')+
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
rocobj <- roc(subtype$label, subtype$proba)
auc <- round(rocobj$auc, 4)

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

auc <- data.frame(x = 0.8, y = 0.1, text = c('AUC = 0.77'))


ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#91C7AE', size = 2.5)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_text(data = auc, aes(x = x, y = y, label = text), size = 16,  show.legend = NA)+
  labs(title = 'Grade ROC Curve', y = 'True Positive Rate', x = 'False Positive Rate')+
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

