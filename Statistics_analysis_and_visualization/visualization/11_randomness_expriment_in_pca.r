library('ggplot2')
library('tidyr')
setwd('/home/wukai/Desktop/RCC_classification/kidney_cancer_project')
# load
pca_res = read.csv('pca_randomness_test.csv',header = TRUE, sep = ',')
# draw
ggplot(data = pca_res, aes(x = PC2, y = PC1))+
  geom_point(color = '#C23531',size = 3, alpha = 0.5)+
  theme_bw()+
  theme(plot.title = element_text(size = 55, hjust = 0.5),
        axis.text.x = element_text(size =45),
        axis.text.y = element_text(size =30),
        axis.title.x = element_text(size = 45, color = '#2F4554'),
        axis.title.y = element_text(size = 45, color = '#2F4554'),
        legend.title = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.text = element_text(size = 25, color = '#2F4554', hjust = 0.5),
        legend.background = element_rect(fill = NA, color = '#2F4554', size = 1.2),
        legend.key = element_rect(fill = NA, colour = NA),
        legend.position = c(0.15,0.81))
ggsave('randomness_exper_pca.pdf', device = 'pdf', width = 16, height = 12, dpi = 300)
