library('ggplot2')
library('tidyr')
library('dplyr')
library('tibble')
library('pROC')
library('latex2exp')
library('EvaluationMeasures')

setwd("/media/wukai/Data01/RCC_classification/kidney_cancer_project/xgboost/")
options(digits=4)

# for ccRCC vs. non-ccRCC prediction with resampled strategy
# load data
dataset <- read.csv('subtype_predict_proba_resampled.csv', header = TRUE, sep = ',')

#define object to plot and calculate AUC
rocobj <- pROC::roc(dataset$truth, dataset$proba)
auc_ci <- as.numeric(ci(rocobj))

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

#for 95% CI bootstrap line
ciobj <- ci.se(rocobj, specificities=seq(0, 1, 0.01),conf.level=0.95, boot.n=2000)
ciobj <- as.data.frame(ciobj)
ciobj$specificities <- 1 - as.numeric(row.names(ciobj))
colnames(ciobj) <- c('TPR_low', 'TPR','TPR_high', 'FPR')
rownames(ciobj) <- NULL
ci_table <- ciobj[order(ciobj$FPR),]
# 
box <- data.frame(x = c(0.33,0.33,1.01,1.01),
                  y = c(0.01,0.32,0.32,0.01))
rect = data.frame(x = c(0.34,0.34,0.39,0.39),
                  y = c(0.035,0.09,0.09,0.035))
line_table <- data.frame(x= c(0.34, 0.39),
                         y = c(0.14,0.14))

ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour = '#61A0A8', size = 3.5)+
  geom_ribbon(data = ci_table, aes(x = FPR, ymin = TPR_low, ymax = TPR_high),fill='#61A0A8',alpha = .2)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = '#61A0A8',alpha = .2)+
  annotate('text', x = 0.67, y = 0.21, label = c('Constructed with resampling strategy'),size = 13, color = '#666666')+
  annotate('text', x = 0.67, y = 0.28, label = c('ccRCC vs. non-ccRCC prediction'), size = 13)+
  annotate('text', x = 0.62, y = 0.065, label = c('95% confidence interval'), size = 13)+
  annotate('text', x =  0.70, y =0.14, label =  TeX('ROC curve (Area =  0.91$\\pm$0.05)'), size = 13)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#91C7AE', size = 3.5)+
  
  labs(y = 'Sensitivity', x = '1 - specificity')+
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

ggsave("subtype_roc_curve_ci_resampled.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)

##############################################################
# for T1/T2 vs. T3/T4 prediction with resampled strategy
# load data
dataset <- read.csv('stage_predict_proba_resampled.csv', header = TRUE, sep = ',')

#define object to plot and calculate AUC
rocobj <- pROC::roc(dataset$truth, dataset$proba)
auc_ci <- as.numeric(ci(rocobj))

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

#for 95% CI bootstrap line
ciobj <- ci.se(rocobj, specificities=seq(0, 1, 0.01),conf.level=0.95, boot.n=2000)
ciobj <- as.data.frame(ciobj)
ciobj$specificities <- 1 - as.numeric(row.names(ciobj))
colnames(ciobj) <- c('TPR_low', 'TPR','TPR_high', 'FPR')
rownames(ciobj) <- NULL
ci_table <- ciobj[order(ciobj$FPR),]
# 
box <- data.frame(x = c(0.33,0.33,1.01,1.01),
                  y = c(0.01,0.32,0.32,0.01))
rect = data.frame(x = c(0.34,0.34,0.39,0.39),
                  y = c(0.035,0.09,0.09,0.035))
line_table <- data.frame(x= c(0.34, 0.39),
                         y = c(0.14,0.14))

# '#91C7AE'
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour ='#D48265', size = 3.5)+
  geom_ribbon(data = ci_table, aes(x = FPR, ymin = TPR_low, ymax = TPR_high),fill='#D48265',alpha = .2)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = '#D48265',alpha = .2)+
  annotate('text', x = 0.67, y = 0.21, label = c('Constructed with resampling strategy'),size = 13, color = '#666666')+
  annotate('text', x = 0.67, y = 0.28, label = c('T1&T2 vs. T3&T4 prediction'), size = 13)+
  annotate('text', x = 0.62, y = 0.065, label = c('95% confidence interval'), size = 13)+
  annotate('text', x =  0.70, y =0.14, label =  TeX('ROC curve (Area =  0.85$\\pm$0.09)'), size = 13)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#D48265', size = 3.5)+
  
  labs(y = 'Sensitivity', x = '1 - specificity')+
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

ggsave("stage_roc_curve_ci_resampled.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)

##############################################################
# for G1/G2 vs. G3/G4 prediction with resampled strategy
# load data
dataset <- read.csv('grade_predict_proba_resampled.csv', header = TRUE, sep = ',')

#define object to plot and calculate AUC
rocobj <- pROC::roc(dataset$truth, dataset$proba)
auc_ci <- as.numeric(ci(rocobj))

roc_table <- data.frame(FPR = 1-rocobj$specificities, TPR = rocobj$sensitivities)
roc_table <- roc_table[order(roc_table$TPR),]

#for 95% CI bootstrap line
ciobj <- ci.se(rocobj, specificities=seq(0, 1, 0.01),conf.level=0.95, boot.n=2000)
ciobj <- as.data.frame(ciobj)
ciobj$specificities <- 1 - as.numeric(row.names(ciobj))
colnames(ciobj) <- c('TPR_low', 'TPR','TPR_high', 'FPR')
rownames(ciobj) <- NULL
ci_table <- ciobj[order(ciobj$FPR),]
# 
box <- data.frame(x = c(0.33,0.33,1.01,1.01),
                  y = c(0.01,0.32,0.32,0.01))
rect = data.frame(x = c(0.34,0.34,0.39,0.39),
                  y = c(0.035,0.09,0.09,0.035))
line_table <- data.frame(x= c(0.34, 0.39),
                         y = c(0.14,0.14))

# '#91C7AE'
ggplot(roc_table, aes(x = FPR, y = TPR))+
  geom_line(colour ='#91C7AE', size = 3.5)+
  geom_ribbon(data = ci_table, aes(x = FPR, ymin = TPR_low, ymax = TPR_high),fill='#91C7AE',alpha = .2)+
  geom_abline(slope = 1, intercept =0, linetype = 3, size = 0.7, show.legend = NA)+
  geom_polygon(data = box, aes(x=x , y=y), fill = 'white', color = '#666666',size = 1.5)+
  geom_polygon(data = rect, aes(x=x , y=y), fill = '#91C7AE',alpha = .2)+
  annotate('text', x = 0.67, y = 0.21, label = c('Constructed with resampling strategy'),size = 13, color = '#666666')+
  annotate('text', x = 0.67, y = 0.28, label = c('G1&G2 vs. G3&G4 prediction'), size = 13)+
  annotate('text', x = 0.62, y = 0.065, label = c('95% confidence interval'), size = 13)+
  annotate('text', x =  0.70, y =0.14, label =  TeX('ROC curve (Area =  0.79$\\pm$0.1)'), size = 13)+
  geom_line(data = line_table, aes(x = x, y = y),colour = '#91C7AE', size = 3.5)+
  
  labs(y = 'Sensitivity', x = '1 - specificity')+
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

ggsave("grade_roc_curve_ci_resampled.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
