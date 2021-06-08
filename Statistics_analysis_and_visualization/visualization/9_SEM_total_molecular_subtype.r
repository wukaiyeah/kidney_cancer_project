# path analysis example
library("lavaan")
library('semPlot')
library('tibble')

# refer to:
# http://www.understandingdata.net/2017/03/22/cfa-in-lavaan/
# set working directory
setwd('D:/AI_diagnosis/Renal_cancer_project/figures')

# load & prepare datatable
datatable <- read.csv('features_input_for_SEM.csv', sep = ',', header =  TRUE)
# normalized features
SCALE <- function(values){
  result <- scale(values, center = TRUE, scale = TRUE)
  return(as.numeric(result))
}
datatable[,c(2:522)] <- apply(datatable[,c(2:522)],2,SCALE)
subtype_stage <- c()
subtype_stage[which(datatable$stage <= 2)] = 0
subtype_stage[which(datatable$stage > 2)] = 1
subtype_grade <- c()
subtype_grade[which(datatable$grade <= 2)] = 0
subtype_grade[which(datatable$grade > 2)] = 1
datatable$subtype_stage <- subtype_stage
datatable$subtype_grade <- subtype_grade


## feature list
# for molecular features
mean_abs <- function(values){
  return(mean(abs(values)))
}

mRNA_shap <- read.csv('shap_values_mRNA_subtype.csv',header = TRUE, sep = ',')
mRNA_shap <- apply(mRNA_shap, 2, mean_abs)
mRNA_shap <- as.data.frame(mRNA_shap)
mRNA_shap <- rownames_to_column(mRNA_shap, var = 'features')
mRNA_shap <- mRNA_shap[order(mRNA_shap$mRNA_shap, decreasing = TRUE),]
mRNA_shap <- mRNA_shap[1:20,] # top 20 features
mRNA_features <- mRNA_shap$features

miRNA_shap <- read.csv('shap_values_miRNA_subtype.csv',header = TRUE, sep = ',')
miRNA_shap <- apply(miRNA_shap, 2, mean_abs)
miRNA_shap <- as.data.frame(miRNA_shap)
miRNA_shap <- rownames_to_column(miRNA_shap, var = 'features')
miRNA_shap <- miRNA_shap[order(miRNA_shap$miRNA_shap, decreasing = TRUE),]
miRNA_shap <- miRNA_shap[1:20,] # top 20 features
miRNA_features <- miRNA_shap$features

emt_shap <- read.csv('shap_values_emt_subtype.csv',header = TRUE, sep = ',')
emt_shap <- apply(emt_shap, 2, mean_abs)
emt_shap <- as.data.frame(emt_shap)
emt_shap <- rownames_to_column(emt_shap, var = 'features')
emt_shap <- emt_shap[order(emt_shap$emt_shap, decreasing = TRUE),]
emt_shap <- emt_shap[1:20,] # top 20 features
emt_features <- emt_shap$features

purity_shap <- read.csv('shap_values_purity_subtype.csv',header = TRUE, sep = ',')
purity_shap <- apply(purity_shap, 2, mean_abs)
purity_shap <- as.data.frame(purity_shap)
purity_shap <- rownames_to_column(purity_shap, var = 'features')
purity_shap <- purity_shap[order(purity_shap$purity_shap, decreasing = TRUE),]
purity_shap <- purity_shap[1:20,] # top 20 features
purity_features <- purity_shap$features
# merge features
molecular_features <- sort(unique(c(mRNA_features, miRNA_features, emt_features, purity_features)))

# for histologic subtype
grade_shap <- read.csv('xgboost_grade_shap_values.csv', sep = ',', header = TRUE)
features_names <- read.csv('pyradiomics_feature_names.csv',header = TRUE, sep = ',')
features_names <- as.character(features_names$alias)
colnames <- paste('t',features_names,sep = '_')
colnames <- append(colnames, paste('svd', seq(0,23,1),sep = '_'))
colnames <- append(colnames, paste('pca',seq(0,95,1),sep = '_'))
colnames(grade_shap) <- colnames
grade_shap <- apply(grade_shap, 2, mean_abs)
grade_shap <- as.data.frame(grade_shap)
grade_shap <- rownames_to_column(grade_shap, var = 'features')
grade_shap <- grade_shap[order(grade_shap$grade_shap, decreasing = TRUE),]
grade_shap <- grade_shap[1:20,] # top 20 features
grade_features <- grade_shap$features

stage_shap <- read.csv('xgboost_stage_shap_values.csv', sep = ',', header = TRUE)
colnames(stage_shap) <- colnames(datatable)[2:521]
stage_shap <- apply(stage_shap, 2, mean_abs)
stage_shap <- as.data.frame(stage_shap)
stage_shap <- rownames_to_column(stage_shap, var = 'features')
stage_shap <- stage_shap[order(stage_shap$stage_shap, decreasing = TRUE),]
stage_shap <- stage_shap[1:20,] # top 20 features
stage_features <- stage_shap$features
# merge
histologic_feature <-  unique(c(grade_features, stage_features))


# multi corrlation
# initial_selected_features <- 3
# end_selected_features <- 4
# all_features <- as.character(feature_list)
# all_combination <- combn(all_features,initial_selected_features)
# 
# SEM <- function(input_list) {
#   input_features <- paste(input_list, collapse = "+")
#   model  <- paste('TextureFeature', input_features, sep = '=~')
#   try({
#     fit <- sem(model, data = datatable)
#     result <- fitMeasures(fit, c('cfi','tli','rmsea','srmr','pvalue'))
#   }, silent = TRUE)
#   return(result)
# }



#################
feature_list <- unique(c(molecular_features, histologic_feature))
feature_list <- c( "pca_100","pca_198",      "pca_202",   "pca_226",          
                   "r_firstorder_VR",    "r_glrlm_GLNU",    
                   "r_glrlm_GLNUN",    "r_glrlm_SRLGLE",   "r_glszm_GLNU",     "r_glszm_GLNUN",   
                   "r_glszm_LAHGLE",   "r_glszm_LALGLE",   "r_glszm_ZE",       "r_shape_FL",      
                   "r_shape_LAL",      "r_shape_M2DR",     "r_shape_M2DS",     "r_shape_MiAL",    
                   "r_shape_SA",       "r_shape_SP",       "r_shape_SVR",      "svd_0",           
                   "svd_10",           "svd_15",                 
                   "svd_2",            "svd_42",           "svd_48",           "svd_56",          
                   "t_firstorder_IQR",      
                   "t_glcm_CR",       "t_glcm_lmc2",     
                   "t_gldm_DE",        "t_glrlm_HGLRE",    "t_glrlm_RE",      
                   "t_glszm_LAHGLE")




# filter features by remove the strong covariance relation
# feature_list <- c( "pca_100",
#                    "pca_198",
#                    "r_firstorder_VR",
#                    "r_glrlm_GLNUN",    "r_glszm_LALGLE",   "r_glszm_ZE",
#                    "r_shape_M2DS",     "r_shape_SP",       "svd_10",           "svd_2",
#                    "svd_42",           "svd_48",           "svd_56",
#                    "t_glrlm_HGLRE",    "t_glszm_LAHGLE",   "t_glszm_LALGLE",
#                    "t_shape_FL",       "t_shape_LAL",
#                     "svd_0",
#                     "t_glcm_CR",
#                     "t_gldm_DE",
#                     "r_shape_LAL",
#                     "r_glszm_LAHGLE",   "r_shape_M2DR",    "r_glrlm_SRLGLE",
#                    "r_glszm_GLNU",      "r_shape_SA",
#                    "r_glrlm_GLNU")

input_features <- paste(feature_list, collapse = "+")


model  <- paste(paste('TextureFeature', input_features, sep = '=~'),sep = '\n')


fit <- sem(model, data = datatable,check.gradient = FALSE)
fitMeasures(fit, c('cfi','tli','rmsea','srmr'))
summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
mi <- modindices(fit)
mi <- mi[order(mi$mi, decreasing = TRUE),]
mi <- mi[which(mi$mi >= 2),]

model2  <- paste(paste('TextureFeature', input_features, sep = '=~'), 
  paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
  sep = '\n')
fit2 <- sem(model2, data = datatable, check.gradient = FALSE)
fitMeasures(fit2, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit2, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)

# Total model
model3 <- 
  paste(# measurement model
    paste('TextureFeature', input_features, sep = '=~'), 
    'PathologicInfo =~ subtype_stage + subtype_grade',
    'MolecularSubtype =~ EMT_score + purity + subtype_miRNA+subtype_mRNA',
    
    # regressions
    'PathologicInfo ~ TextureFeature',
    'TextureFeature ~ MolecularSubtype',
  
    # Covariance
    paste(paste(mi$lhs, mi$op, mi$rhs), collapse = '\n'),
    sep = '\n')

fit3 <- sem(model3, data = datatable,check.gradient = FALSE)
fitMeasures(fit3, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit3, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
# 路径图展示图
pdf('textw-set.pdf')
semPaths(fit3, what = 'paths', whatLabels = 'stand',layout = "spring")
dev.off()
