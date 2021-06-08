#!/usr/bin/R
##--packages preparation
library('ggplot2')
library('dplyr')
library('tibble')
##-environment setting
setwd("C:\\Users\\user\\OneDrive - Computational Medicine\\AI_diagnosis\\Renal_cancer_project\\figures")
options(digits=2)
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
cls_accuracy <- function(values){
  accuracy <- sum(values == subtype_cls$subtype)/nrow(subtype_cls)
  return(accuracy)
}

cls_num <- function(values){
  right_num <- sum(values == subtype_cls$subtype)
  return(right_num)
}

accuarcy_subtype <- apply(subtype_cls[,-5], 2, cls_accuracy)
accuarcy_subtype <- as.data.frame(accuarcy_subtype)
accuarcy_subtype <- rownames_to_column(accuarcy_subtype, var = 'source')
accuarcy_subtype <- rbind(c('model',0.8636),accuarcy_subtype)

accuarcy_subtype <- cbind(accuarcy_subtype, rep('histologic subtype',5))
colnames(accuarcy_subtype) <- c('source','accuarcy','class')

##-load stage
doc_stage <- read.csv('../expert_cls/doctor_stage_cls_result.csv',header = TRUE)
colnames(doc_stage) <- c('case_id', 'doctor_1','doctor_2','doctor_3','doctor_4')
stage_cls <- left_join(doc_stage, truth_stage, by = 'case_id')
stage_cls <- column_to_rownames(stage_cls, var = 'case_id')
cls_accuracy <- function(values){
  accuracy <- sum(values == stage_cls$stage)/nrow(stage_cls)
  return(accuracy)
}
accuarcy_stage <- apply(stage_cls[,-5], 2, cls_accuracy)
accuarcy_stage <- as.data.frame(accuarcy_stage)
accuarcy_stage <- rownames_to_column(accuarcy_stage, var = 'source')
accuarcy_stage <- rbind(c('model',0.8273),accuarcy_stage)

accuarcy_stage <- cbind(accuarcy_stage, rep('pathologic stage',5))
colnames(accuarcy_stage) <- c('source','accuarcy','class')

datatable <- rbind(accuarcy_subtype, accuarcy_stage)

datatable$accuarcy <- round(as.numeric(datatable$accuarcy),2)
datatable$source <- gsub('_','',datatable$source)


#datatable$source <- factor(datatable$source, labels = c('model','doctor_1','doctor_2','doctor_3','doctor_4'))
write.table(datatable, 'accuracy_model_and_doctor_statistics.txt', sep = '\t', quote = FALSE, row.names = FALSE)
##--draw plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(data = datatable, aes(x= source, y = accuarcy,fill = source))+
  geom_bar(stat="identity",width = 0.65,position = position_dodge(0.65))+
  geom_text(aes(label=accuarcy, y=accuarcy),  vjust=0, size = 12)+
  scale_fill_manual(values = c('#61A0A8','#61A0A8','#61A0A8','#61A0A8','#D48265'))+
  labs(title = '',y = 'Accuracy', x= NA)+
  facet_wrap(~class)+
  ylim(0.0,0.87)+
  theme_bw()+
  theme(plot.title = element_text(size = 55,hjust = 0.5, face = 'bold'),
        strip.text = element_text(size =  45),
        axis.text.x = element_text(size =45, angle = 45, hjust = 1.1, vjust = 1.1),
        axis.text.y = element_text(size =45),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 45),
        panel.grid.major.y = element_line(colour = 'gray',size = 0.7),
        legend.title = element_blank(),
        legend.text = element_text(size = 30),
        legend.background = element_blank(),
        legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = 'NA'
  )
ggsave("doctors_cls_accuray.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("doctors_cls_accuray.pdf", device = "pdf", width = 16, height = 12, dpi = 300)


write.csv(rownames_to_column(subtype_cls, var = 'case_id'), 'doctor_subtype_cls_result.csv', quote = FALSE, row.names = FALSE)
write.csv(rownames_to_column(stage_cls, var = 'case_id'), 'doctor_stage_cls_result.csv', quote = FALSE, row.names = FALSE)

