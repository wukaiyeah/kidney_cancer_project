library('ggplot2')
library('tibble')
library('dplyr')

setwd("D:/AI_diagnosis/Renal_cancer_project/figures")
datatable <- data.frame(type = c('VHL_mut','miRNA','mRNA','purity','EMT'), 
                        accuracy = c(0.6296,0.8333,0.64,0.7419,0.7742))

datatable <- datatable[order(datatable$accuracy,decreasing = TRUE),]
#datatable$type <- factor(datatable$type, labels = datatable$type)
# plot 
ggplot(data = datatable, 
       aes(x= type, y = accuracy, fill = type))+
  geom_bar(stat = 'identity',
           width = 0.45,
           size = 1)+
  scale_fill_manual(values = c('#C23531', '#2F4554','#61A0A8','#D48265','#91C7AE'))+
  labs(title = '', 
       y = 'Molecular Subtype Classification Accuracy', 
       x = NULL)+
  ylim(0.0,1.0)+
  theme_bw()+
  theme(plot.title = element_text(size = 45,hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =45),
        axis.title.x = element_text(size = 45),
        axis.title.y = element_text(size = 45),
        #panel.grid.major.x = element_line(colour = 'gray',size = 0.7),
        legend.title = element_blank(),
        legend.text = element_text(size = 45),
        legend.background = element_blank(),
        # legend.key = element_rect(fill = NA, colour = NA, size=1),
        legend.position = 'none')+
  coord_flip()
ggsave("molecular_subtype_classification_accuracy.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("molecular_subtype_classification_accuracy.pdf", device = "pdf", width = 16, height = 12, dpi = 300)



