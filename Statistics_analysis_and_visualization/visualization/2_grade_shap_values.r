library('ggplot2')
library('tibble')
library('dplyr')

setwd("D:/AI_diagnosis/Renal_cancer_project/figures")
# load feature table
#features_table <- read.csv('xgboost_train_features.csv', sep = ',', header = TRUE)
# make feature colnames
features_names <- read.csv('pyradiomics_feature_names.csv',header = TRUE, sep = ',')
features_names <- as.character(features_names$alias)
colnames <- paste('t',features_names,sep = '_')
#colnames <- append(colnames,  paste('r',features_names,sep = '_'))
colnames <- append(colnames, paste('svd', seq(0,23,1),sep = '_'))
colnames <- append(colnames, paste('pca',seq(0,95,1),sep = '_'))
#colnames(features_table) <- colnames

# load subtype shap values
shap_table <- read.csv('xgboost_grade_shap_values.csv', sep = ',', header = TRUE)
colnames(shap_table) <- colnames

# draw bar plot 
mean_abs <- function(values){
    return(mean(abs(values)))
}

shap_mean_table <- apply(shap_table, 2, mean_abs)
shap_mean_table <- as.data.frame(shap_mean_table)
colnames(shap_mean_table) <- 'shap_mean'
shap_mean_table <- rownames_to_column(shap_mean_table, var = 'features')

shap_mean_table <- shap_mean_table[order(shap_mean_table$shap_mean,decreasing = TRUE),]
shap_mean_table <- shap_mean_table[1:20,] # top 20 features
shap_mean_table$features <- factor(shap_mean_table$features, levels  = shap_mean_table$features[seq(20,1,-1)])

#windowsFonts(CA=windowsFont("Calibri"))

ggplot(data = shap_mean_table, 
       aes(x= features, y = shap_mean, color = features))+
    geom_bar(stat = 'identity',
             color= '#91C7AE',
             fill = '#91C7AE',
             width = 0.7,
             size = 1.2)+
    labs(title = '', 
         y = 'Mean(|SHAP value|)', 
         x = NULL)+
    #ylim(0,65)+
    theme_bw()+
    theme(plot.title = element_text(size = 45,hjust = 0.5),
          axis.text.x = element_text(size =40),
          axis.text.y = element_text(size =40),
          axis.title.x = element_text(size = 40),
          axis.title.y = element_text(size = 45),
          panel.grid.major.x = element_line(colour = 'gray',size = 0.7),
          legend.title = element_blank(),
          legend.text = element_text(size = 45),
          legend.background = element_blank(),
          # legend.key = element_rect(fill = NA, colour = NA, size=1),
          legend.position = 'none')+
    coord_flip()
ggsave("grade_cls_shap_values_mean.jpg", device = "jpeg", width = 16, height = 12, dpi = 300)
ggsave("grade_cls_shap_values_mean.pdf", device = "pdf", width = 16, height = 12, dpi = 300)



