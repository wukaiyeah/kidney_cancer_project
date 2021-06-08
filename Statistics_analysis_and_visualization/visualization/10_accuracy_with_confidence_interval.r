# binomial confidence interval and draw figure
setwd("C:\\Users\\user\\OneDrive - Computational Medicine\\AI_diagnosis\\Renal_cancer_project\\figures")
options(digits=4)
CI_90 = 1.64
CI_95 = 1.96
CI_98 = 2.33
CI_99 = 2.58
# load datatable

datatable <- read.table('accuracy_model_and_doctor_statistics.txt', header = TRUE, sep = '\t')

# function
n = 88
CI <- function(accuracy){
    interval <- CI_95 * sqrt((accuracy * (1-accuracy)) /n)
    return(interval)
}
datatable$confidence_interval <- CI(datatable$accuarcy)
# 95% confidence interval






# compare modal with doctor
acc1_model <- c(rep(0.8636, 4))
acc1_doctor <- datatable$accuarcy[2:5]

acc2_model <- c(rep(0.8273, 4))
acc2_doctor <- datatable$accuarcy[7:10]
# t test 
t.test(acc1_model, acc1_doctor, var.equal = FALSE, alternative = 'two.sided')
# result: t'=2.2, P = 0.1
t.test(acc2_model, acc2_doctor, var.equal = FALSE, alternative = 'two.sided')
# result: t' = 1.8, P = 0.2