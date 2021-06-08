# path analysis example
library("lavaan")
library('semPlot')

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


## feature list
# for molecular subtype
features <- read.table('molecular_subtype_correlation_results.txt', header = TRUE, sep = '\t')
feature_list <- as.character(features[c(5, 10, 15, 20 ,25), 4])
feature_list <- unique(unlist(strsplit(feature_list, split = ',')))
feature_list <- paste('t',feature_list, sep = '_')
# for histologic subtype
#grade_features<- as.character(shap_mean_table$features) # need another script to import variable
#stage_features<- as.character(shap_mean_table$features) # need another script to import variable
#feature_list2 <-  unique(append(grade_features, stage_features))


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

feature_list <- c(  "t_firstorder_VR",   "t_firstorder_10P",    't_firstorder_TE',   
                  "t_glszm_GLNUN",       "t_glcm_ACR",        "t_glszm_LGLZE" ,   
                  "t_glszm_GLNU",      "t_gldm_DE",          "t_gldm_SDLGLE",    
                   "t_glszm_SAE" ,     "t_glcm_CR"  )

feature_list2 <- c("svd_0",            "svd_19" ,    "pca_80" ,         
                   "r_shape_LAL",      "r_glszm_LAHGLE",   "r_shape_M2DR",    
                   "r_glrlm_SRLGLE",   "r_shape_SP",       "r_shape_M2DS",    
                   "r_glszm_GLNU",     "r_shape_SA" ,     
                   "r_glszm_GLNUN" )



input_features <- paste(feature_list, collapse = "+")
input_features2 <- paste(feature_list2, collapse = "+")

model  <- paste(paste('TextureFeature', input_features, sep = '=~'),
                paste('TextureFeature2', input_features2, sep = '=~'),
                sep = '\n')


fit <- sem(model, data = datatable,check.gradient = FALSE)
fitMeasures(fit, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
mi <- modindices(fit)
mi <- mi[order(mi$mi, decreasing = TRUE),]

model2  <- paste(paste('TextureFeature', input_features, sep = '=~'), 
                 paste('TextureFeature2', input_features2, sep = '=~'), 
                 paste(paste(mi$lhs, mi$op, mi$rhs)[1:100], collapse = '\n'),
                 sep = '\n')
fit2 <- sem(model2, data = datatable, check.gradient = FALSE)
fitMeasures(fit2, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit2, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)

# Total model
model3 <- 
  paste(# measurement model
    paste('TextureFeature', input_features, sep = '=~'), 
    paste('TextureFeature2', input_features2, sep = '=~'),
    'PathologicInfo =~ stage + grade',
    'MolecularSubtype =~ EMT_score + purity + subtype_miRNA + subtype_mRNA',

    # regressions
    'PathologicInfo ~ TextureFeature',
    'MolecularSubtype ~ TextureFeature',
    'PathologicInfo ~ TextureFeature2',
    'MolecularSubtype ~ TextureFeature2',

    
    # Covariance
    paste(paste(mi$lhs, mi$op, mi$rhs)[1:100], collapse = '\n'),
    sep = '\n')

fit3 <- sem(model3, data = datatable,check.gradient = FALSE)
fitMeasures(fit3, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit3, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
# 路径图展示图
pdf('semPath0.pdf')
semPaths(fit3, what = 'paths', whatLabels = 'stand',layout = "tree2")
dev.off()
