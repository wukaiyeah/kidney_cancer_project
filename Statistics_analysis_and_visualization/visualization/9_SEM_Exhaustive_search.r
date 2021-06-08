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


# feature list

features <- read.table('molecular_subtype_correlation_results.txt', header = TRUE, sep = '\t')
feature_list <- as.character(features[c(5, 10, 15, 20 ,25), 4])
feature_list <- unique(unlist(strsplit(feature_list, split = ',')))
feature_list <- paste('t',feature_list, sep = '_')



# multi-var corrlation
initial_selected_features <- 3
end_selected_features <- 4
all_features <- as.character(feature_list)
all_combination <- combn(all_features,initial_selected_features)


SEM <- function(input_list) {
  input_features <- paste(input_list, collapse = "+")
  model  <- paste('TextureFeature', input_features, sep = '=~')
  try({
    fit <- sem(model, data = datatable)
    result <- fitMeasures(fit, c('cfi','tli','rmsea','srmr','pvalue'))
    }, silent = TRUE)
  return(result)
}



#################

features <- c("t_shape_EL",   
               "t_shape_M2DC",        
               "t_shape_MV",        "t_shape_SA" ,   
               "t_firstorder_TE"    ,  "t_firstorder_10P" ,
               
               "t_glcm_ACR",        "t_glcm_CPM",        "t_glcm_CR",            
               "t_glcm_DA",          "t_glcm_JEG",        "t_glcm_ldn",          
               "t_gldm_DE",           "t_gldm_SDLGLE",       
               "t_glrlm_LGLRE",      "t_glszm_GLNUN",     "t_glszm_SAE",      
               "t_glszm_ZE"     )

input_features <- paste(features, collapse = "+")


model  <- paste(paste('TextureFeature', input_features, sep = '=~'), 
                #paste('TextureFeature2', input_features2, sep = '=~'),
                #paste('TextureFeature3', input_features3, sep = '=~'),
                sep = '\n')


fit <- sem(model, data = datatable)
fitMeasures(fit, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
mi <- modindices(fit)
mi <- mi[order(mi$mi, decreasing = TRUE),]

model2  <- paste(paste('TextureFeature', input_features, sep = '=~'), 
                #paste('TextureFeature2', input_features2, sep = '=~'),
                paste(paste(mi$lhs, mi$op, mi$rhs)[1:100], collapse = '\n'),
                sep = '\n')
fit2 <- sem(model2, data = datatable)
fitMeasures(fit2, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit2, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)

# Total model

model3 <- 
  paste(# measurement model
        paste('TextureFeature', input_features, sep = '=~'), 
        #paste('TextureFeature2', input_features2, sep = '=~'),
        'PathologicInfo =~ stage + grade',
        'MolecularSubtype =~ EMT_score + purity + subtype_miRNA + subtype_mRNA',
        # regressions
        'MolecularSubtype ~ TextureFeature',
        'PathologicInfo ~ TextureFeature',

        # Covariance
        paste(paste(mi$lhs, mi$op, mi$rhs)[1:100], collapse = '\n'),
        sep = '\n')

fit3 <- sem(model3, data = datatable)
fitMeasures(fit3, c('cfi','tli','rmsea','srmr','pvalue'))
summary(fit3, standardized = TRUE, fit.measures = TRUE, rsquare = TRUE)
# 路径图展示图
pdf('text.pdf')
semPaths(fit3, what = 'paths', whatLabels = 'stand',rotatio = 2)
dev.off()
