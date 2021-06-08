#!/usr/bin/R

##--packages preparation
library('ggplot2')
library('tidyr')
##-environment setting
setwd("C:\\Users\\user\\OneDrive - Computational Medicine\\AI_diagnosis\\Renal_cancer_project\\figures")

##-load testset data table
testset <- read.csv('testset_dice_coeff_results.csv', header = TRUE, sep = ',') 
testset <- testset[,-1]
colnames(testset) <- c('kidney', 'tumor')
testset_sd_values <- apply(testset, 2, sd)
testset_mean_values <- apply(testset, 2, mean)

testset <- gather(testset, key = 'type', value = 'dice_coeff')
testset <- cbind(dataset = rep('Testing Set',nrow(testset)), testset)

##-load trainset data table
trainset <- read.csv('trainset_dice_coeff_results.csv', header = TRUE, sep = ',') 
trainset <- trainset[,-1]
colnames(trainset) <- c('kidney', 'tumor')
trainset_sd_values <- apply(trainset, 2, sd)
trainset_mean_values <- apply(trainset, 2, mean)
trainset <- gather(trainset, key = 'type', value = 'dice_coeff')
trainset <- cbind(dataset = rep('Training Set',nrow(trainset)), trainset)



#-merge
datatable <- rbind(trainset, testset)
datatable$dataset <- factor(datatable$dataset, labels = c('Training Set','Testing Set'))
datatable$type <- factor(datatable$type, labels = c('kidney','tumor'))
# SD of dice coeff
mean_values <- c(trainset_mean_values, testset_mean_values)
sd_values <- c(trainset_sd_values, testset_sd_values)

dice_anno <- data.frame(dataset = c( rep('Training Set',2), rep('Testing Set',2)),
                        type = c('kidney','tumor','kidney','tumor'),
                        y = c(1.05,1.05,1.05,1.05),
                        dice = c('0.97 (0.01)','0.92 (0.09)','0.96 (0.02)','0.88 (0.15)'))


##--draw plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(data = datatable, aes(x= type, y = dice_coeff))+
        geom_boxplot(aes(fill = type), width = 0.8, size = 0.7,outlier.shape = NA)+
        scale_fill_manual(values = c('#00BFC4', '#F8766D'))+#'#C23531', '#2F4554'
        geom_point(size = 2, position = position_jitter(0.3),alpha = 0.8)+
        geom_text(data = dice_anno, aes(x = type, y = y, label = dice), size = 15,show.legend = NA)+
        facet_wrap(~dataset)+
        labs(y = 'dice coefficient', x = 'Segmentation Accuracy')+
        scale_x_discrete(labels= c('kidney', 'tumor'))+
        #ylim(0,16)+
        theme_bw()+
        theme(plot.title = element_text(size = 45,hjust = 0.5, face = 'bold'),
              strip.text = element_text(size =  45),
              axis.text.x = element_text(size =45),
              axis.text.y = element_text(size =45),
              axis.title.x = element_text(size = 45),
              axis.title.y = element_text(size = 45),
              panel.grid.major.y = element_line(colour = 'gray',size = 0.7),
              legend.title = element_blank(),
              legend.text = element_text(size = 45),
              legend.background = element_blank(),
              legend.key = element_rect(fill = NA, colour = NA, size=1),
              legend.position = '')
ggsave("nnUNet_kidney_tumor_segmentation.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("nnUNet_kidney_tumor_segmentation.pdf", device = "pdf", width = 16, height = 12, dpi = 300)



