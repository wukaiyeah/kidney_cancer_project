#!/usr/bin/R
library('dplyr')
library('tibble')
library('Rtsne')
setwd('D:/AI_diagnosis/Renal_cancer_project/bioinfo')

# load dataset
datatable = read.table('images_genomic_features_table.txt', header = TRUE, sep = '\t')
features_table = datatable[,c(1,3,12,14,16:101)]
rownames(features_table) <- NULL
features_table <- column_to_rownames(features_table, var = 'case_id')

normalize <- function(values){
  min_value <- min(values)
  max_value <- max(values)
  return((values - min_value)/(max_value - min_value))
}
normalized_features_table <- t(apply(features_table,1,normalize))


normalized_features_table <- normalize_input(as.matrix(features_table))
set.seed(1234)
tsne_result<- Rtsne(normalized_features_table, dims = 2, initial_dims = 50,
      perplexity = 8)


plot(tsne_result$Y, asp=1,pch=20,
     xlab = "tSNE_1",ylab = "tSNE_2",main = "tSNE plot")
text(x = tsne_result$Y, y = NULL, labels = seq_along(x$x), adj = NULL,
     pos = NULL, offset = 0.5, vfont = NULL,
     cex = 1, col = NULL, font = NULL, ...)


