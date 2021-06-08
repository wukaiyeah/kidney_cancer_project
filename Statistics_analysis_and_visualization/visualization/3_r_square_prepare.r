setwd('D:/AI_diagnosis/Renal_cancer_project/figures')

# for EMT score
load('emt_score.RData')
r_square = best_cor

feature_names = c()
for(i in 1:length(best_feature_combination)){
    feature_names = append(feature_names, paste(best_feature_combination[[i]], collapse = ','))
}

# for purity
feature10 <- read.csv('/home/wukai/Desktop/bioinfo/features_10_combin_purity_corrlation.csv', header = TRUE)
feature15 <- read.csv('/home/wukai/Desktop/bioinfo/features_15_combin_purity_corrlation.csv', header = TRUE)
feature20 <- read.csv('/home/wukai/Desktop/bioinfo/features_20_combin_purity_corrlation.csv', header = TRUE)
feature25 <- read.csv('/home/wukai/Desktop/bioinfo/features_25_combin_purity_corrlation.csv', header = TRUE)
feature30 <- read.csv('/home/wukai/Desktop/bioinfo/features_30_combin_purity_corrlation.csv', header = TRUE)
r_square = append(r_square,as.numeric(as.character(feature10[1,])))
r_square = append(r_square,as.numeric(as.character(feature15[1,])))
r_square = append(r_square,as.numeric(as.character(feature20[1,])))
r_square = append(r_square,as.numeric(as.character(feature25[1,])))
r_square = append(r_square,as.numeric(as.character(feature30[1,])))
feature_names = append(feature_names, paste(as.character(feature10[2:nrow(feature10),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature15[2:nrow(feature15),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature20[2:nrow(feature20),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature25[2:nrow(feature25),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature30[2:nrow(feature30),]), collapse = ','))

# for mRNA subtype
load('mRNA.RData')
r_square = append(r_square,best_cor)

for(i in 1:length(best_feature_combination)){
    feature_names = append(feature_names, paste(best_feature_combination[[i]], collapse = ','))
}

# for miRNA subtype
load('miRNA.RData')
r_square = append(r_square,best_cor)

for(i in 1:length(best_feature_combination)){
    feature_names = append(feature_names, paste(best_feature_combination[[i]], collapse = ','))
}


# for VHL muta
feature10 <- read.csv('/home/wukai/Desktop/bioinfo/features_10_combin_VHL_muta_corrlation.csv', header = TRUE)
feature15 <- read.csv('/home/wukai/Desktop/bioinfo/features_15_combin_VHL_muta_corrlation.csv', header = TRUE)
feature20 <- read.csv('/home/wukai/Desktop/bioinfo/features_20_combin_VHL_muta_corrlation.csv', header = TRUE)
feature25 <- read.csv('/home/wukai/Desktop/bioinfo/features_25_combin_VHL_muta_corrlation.csv', header = TRUE)
feature30 <- read.csv('/home/wukai/Desktop/bioinfo/features_30_combin_VHL_muta_corrlation.csv', header = TRUE)
r_square = append(r_square,as.numeric(as.character(feature10[1,])))
r_square = append(r_square,as.numeric(as.character(feature15[1,])))
r_square = append(r_square,as.numeric(as.character(feature20[1,])))
r_square = append(r_square,as.numeric(as.character(feature25[1,])))
r_square = append(r_square,as.numeric(as.character(feature30[1,])))
feature_names = append(feature_names, paste(as.character(feature10[2:nrow(feature10),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature15[2:nrow(feature15),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature20[2:nrow(feature20),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature25[2:nrow(feature25),]), collapse = ','))
feature_names = append(feature_names, paste(as.character(feature30[2:nrow(feature30),]), collapse = ','))



target = c(rep('EMT_subtype',5),rep('purity_subtype',5), rep('mRNA_subtype',5), rep('miRNA_subtype',5),rep('VHL_mut',5))
features_num = rep(c(10,15,20,25,30),5)
result = data.frame(target=target, r_square,features_num=features_num, features_names= feature_names)
write.table(result, 'molecular_subtype_correlation_results.txt',quote = FALSE, row.names = FALSE,sep = '\t')






