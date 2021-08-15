#!/usr/bin/python
import os
import numpy as np
import pandas as pd
#from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score,precision_score,f1_score,recall_score,roc_auc_score, confusion_matrix
from xgboost import XGBClassifier
from mlxtend.evaluate import mcnemar_table, mcnemar
from imblearn.combine import SMOTEENN,SMOTETomek
from collections import Counter


if __name__ == '__main__':
    base_dir = '/media/wukai/Data01/RCC_classification/kidney_cancer_project/xgboost'
    train_table = pd.read_csv(os.path.join(base_dir,'train_features_pyradiomics_images.csv'), index_col=0, header=0)
    test_table =  pd.read_csv(os.path.join(base_dir, 'test_features_pyradiomics_images.csv'), index_col=0, header=0)
    clinic_info = pd.read_csv(os.path.join(base_dir, 'clinical_all_rcc_dict.csv'),index_col=0, header=0)
    
    #train_table = benign_sample_remove(train_table, clinic_info)
    #test_table = benign_sample_remove(test_table, clinic_info)
    
    # split feature and target
    train_feature = np.array(train_table.iloc[:,2:])
    train_stage_label = np.array(train_table.iloc[:,1])
    test_feature = np.array(test_table.iloc[:,2:])
    test_stage_label = np.array(test_table.iloc[:,1])

    smote_enn = SMOTEENN(random_state=0)
    train_feature,train_stage_label = smote_enn.fit_resample(train_feature,train_stage_label)
    test_feature,test_stage_label = smote_enn.fit_resample(test_feature,test_stage_label)

    # for tumor stage cls
    '''
    model = XGBClassifier( scale_pos_weight = 1.3,
                            #learning_rate = 0.10, 
                            n_estimators=200,
                            max_depth = 7,
                            subsample = 0.90,
                            reg_lambda = 5,
                            num_boost_round = 60,
                            min_child_weight = 0.8,
                            colsample_bytree=1)
                            '''

    eval_set = [(test_feature, test_stage_label)]
    model = XGBClassifier( scale_pos_weight = 1.3,
                            #learning_rate = 0.10, 
                            n_estimators=200,
                            max_depth = 7,
                            subsample = 0.90,
                            reg_lambda = 5,
                            num_boost_round = 100,
                            min_child_weight = 0.8,
                            colsample_bytree=1)
                            
    model.fit(train_feature, train_stage_label, early_stopping_rounds=100, eval_metric=['auc','rmsle'], eval_set=eval_set, verbose=True)
    y_pred = model.predict_proba(test_feature)
    y_pred_proba = y_pred[:,1] 
    y_pred_class = [0 if proba < 0.5 else 1 for proba in y_pred_proba ]


    accuracy = accuracy_score(test_stage_label, y_pred_class)
    print("Stage class accuracy: %.2f%%" % (accuracy * 100.0))
    Precision = precision_score(test_stage_label, y_pred_class, average='binary')
    print("Stage class precision: %.2f%%" % (Precision * 100.0))
    F1_score = f1_score(test_stage_label, y_pred_class, average='binary') 
    print('Stage F1 score:%.2f%%' %(F1_score*100.0))
    Recall_score = recall_score(test_stage_label, y_pred_class,  average='binary')
    print('Stage Recall score label:%.2f%%' %(Recall_score*100.0))
    Auc_score = roc_auc_score(test_stage_label, y_pred_proba)
    print('Stage auc score label:%.2f%%' %(Auc_score*100.0))
    print('Stage auc score label:%.2f%%' %(Auc_score*100.0))
    print(confusion_matrix(test_stage_label,y_pred_class ))

    test_pred_table = pd.concat((pd.DataFrame(test_stage_label), pd.DataFrame(y_pred_proba)), axis=1)
    test_pred_table.columns = ['truth','proba']
    test_pred_table.to_csv('stage_predict_proba_resampled_both.csv', index=0)


    # McNemer's test
    y_target = test_stage_label
    y_model1 = np.array(y_pred_class)
    y_model2 = np.ones_like(y_model1)
    tb = mcnemar_table(y_target=y_target, 
                   y_model1=y_model1, 
                   y_model2=y_model2)
    chi2, p = mcnemar(ary=tb)
    print('chi-squared:', chi2)
    print('McNemer p-value:', p)
    # save model to file
