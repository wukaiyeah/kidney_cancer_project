#!/usr/bin/R

##--packages preparation
library('ggplot2')
library('tidyr')
##-environment setting
setwd("D:/AI_diagnosis/Renal_cancer_project/figures")

##-load data table
datatable <- read.table('molecular_subtype_correlation_results.txt',header = TRUE, sep = '\t')
datatable <- datatable[,1:3]
datatable$target <- gsub('_subtype','',datatable$target)
datatable$features_num <- paste(datatable$features_num,'features')
datatable$target <- factor(datatable$target, labels = as.character(unique(datatable$target)))

##--draw plot
#windowsFonts(CA=windowsFont("Calibri"))
ggplot(data = datatable, aes(x= target, y = r_square, fill = features_num))+
    geom_bar(stat="identity",position = position_dodge(0.9))+
    scale_fill_manual(values = c('#C23531', '#2F4554','#61A0A8','#D48265','#91C7AE'))+
    labs(title = '',y = 'R-square', x = 'Molecular Subtype')+
    #ylim(0,1)+
    theme_bw()+
    theme(plot.title = element_text(size = 55,hjust = 0.5, face = 'bold'),
          #strip.text = element_text(size =  30),
          axis.text.x = element_text(size =45),
          axis.text.y = element_text(size =45),
          axis.title.x = element_text(size = 45),
          axis.title.y = element_text(size = 45),
          #panel.grid.major.y = element_line(colour = 'gray',size = 0.7),
          legend.title = element_blank(),
          legend.text = element_text(size = 35),
          legend.background = element_blank(),
          legend.key = element_rect(fill = NA, colour = NA, size=1),
          legend.position = c(0.9,0.85)
          )
ggsave("molecular_subtype_correlation_result.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("molecular_subtype_correlation_result.pdf", device = "pdf", width = 16, height = 12, dpi = 300)



