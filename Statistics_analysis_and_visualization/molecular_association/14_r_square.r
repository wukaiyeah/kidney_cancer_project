#!/usr/bin/R
library('dplyr')
library('tibble')
#library('Rtsne')
library('rsq')
library('pheatmap')
library('parallel')
setwd('/home/wukai/Desktop/bioinfo')

# load dataset
datatable = read.table('features_table_for_mutation_class.csv', header = TRUE, sep = ',', row.names = 1)


#write.csv(normalized_features_table , 'feature_table_for_class.csv', row.names = TRUE)
#write.csv(anno, 'feature_label_for_class.csv', row.names = FALSE)

# sort features
shap_table <- read.csv('shap_values_VHL_mut_cls.csv', header = TRUE, row.names = 1)

mean_abs <- function(values){
  return(mean(abs(values)))
}

shap_mean_table <- apply(shap_table, 2, mean_abs)
shap_mean_table <- as.data.frame(shap_mean_table)
colnames(shap_mean_table) <- 'shap_mean'
shap_mean_table <- rownames_to_column(shap_mean_table, var = 'features')
shap_mean_table <- shap_mean_table[order(shap_mean_table$shap_mean,decreasing = TRUE),]
filterd_table <- shap_mean_table[,c(1:50)]
#filterd_table <- shap_mean_table[which(shap_mean_table$shap_mean > 0),]

#normalized_features_table <- normalized_features_table[filterd_table$features,]


# multi-var corrlation
normalized_features_table <- datatable

initial_selected_features <- 2
end_selected_features <- 15
all_features <- as.character(filterd_table$features)
all_combination <- combn(all_features,initial_selected_features)
all_correlation <- rep(0,ncol(all_combination))


#combination_matrix <- matrix(data = "0",nrow=end_selected_features,ncol = ncol(all_combination))
# for (i in 1:ncol(all_combination)) {
#     max <- -1
#     features <- paste(all_combination[,i][1],all_combination[,i][2],sep = '+')
#     result <- glm(as.formula(paste('purity_label', features,sep = '~')), family = binomial(link = "cauchit"), data = as.data.frame(normalized_features_table))
#     
#     if(rsq(result)>max){
#         max<-rsq(result)
#         max_combine <- all_combination[,i]
#     }
# }

feature_ascend <- function(x) {
  #max_combine <- all_combination[,i]
  max_combine <- x
  max <- -1
  while (length(max_combine)<end_selected_features) {
    left_features <- setdiff(all_features, max_combine)
    max_input <- paste(max_combine, collapse = "+")
    for (j in 1:length(left_features)) {
      input_features <- paste(max_input, left_features[j], sep = "+")
      result2 <- glm(as.formula(paste('VHL_label', input_features,sep = '~')),control=list(maxit=4), family = binomial(link = "cauchit"), data = as.data.frame(normalized_features_table))
      current_cor <- rsq(result2)
      if(current_cor>max){
        max<-current_cor
        max_current_feature <- left_features[j]
      }
    }
    max_combine <- union(max_combine,max_current_feature)
  }
  #all_correlation[i] <- max
  #combination_matrix[,i] <- max_combine
  out <- c(max,max_combine)
  return(out)
}
clnum<-detectCores()
cl <- makeCluster(getOption("cl.cores", clnum))
clusterExport(cl,c("end_selected_features","all_features","normalized_features_table","rsq"),envir = environment())

input_combination <- list()
for (k in 1:ncol(all_combination)) {
  input_combination[[k]] <- as.character(all_combination[,k])
}

res2 <- parLapply(cl, input_combination,feature_ascend)
stopCluster(cl)

for(m in 1:length(res2)){
  input_combination[[m]] <- res2[[m]][2:16]
}

res2 <- read.csv('features_15_combin_VHL_muta_corrlation.csv',header = TRUE,sep = ',')

res <- list()
for(i in 2:length(input_combination)){
  print(i)
  res[[i]] <- feature_ascend(input_combination[[i]])
}

max_cor<-0
max_index <- 1
for (l in 1:length(res2)) {
  if(as.numeric(res2[[l]][1]>max_cor)){
    max_cor<- as.numeric(res2[[l]][1])
    max_index <- l
  }
}
write.csv(as.data.frame(res[[max_index]]), 'features_15_combin_VHL_muta_corrlation.csv',quote = FALSE, row.names = FALSE)
