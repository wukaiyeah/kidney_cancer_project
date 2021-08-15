#!/usr/bin/python
import os
import numpy as np
import pandas as pd
from sklearn.metrics import accuracy_score,precision_score,f1_score,recall_score,roc_auc_score, confusion_matrix
from xgboost import XGBClassifier
from mlxtend.evaluate import mcnemar_table, mcnemar
from collections import Counter
from sklearn.datasets import make_classification
from imblearn.combine import SMOTEENN,SMOTETomek

if __name__ == '__main__':
    base_dir = '/media/wukai/Data01/RCC_classification/kidney_cancer_project/xgboost'
    train_feature = pd.read_csv(os.path.join(base_dir, 'train_features_pyradiomics_images.csv'), header = 0, index_col=0)
    test_feature = pd.read_csv(os.path.join(base_dir, 'test_features_pyradiomics_images.csv'), header = 0, index_col=0)

    train_x = train_feature.iloc[:,2:]
    train_y = train_feature.iloc[:,0]
    test_x = test_feature.iloc[:,2:]
    test_y = test_feature.iloc[:,0]
    # resample
    smote_enn = SMOTEENN(random_state=0)
    train_x,train_y = smote_enn.fit_resample(train_x,train_y)
    test_x,test_y = smote_enn.fit_resample(test_x,test_y )
    # for tumor subtype cls

    model = XGBClassifier(scale_pos_weight = 0.9, # the best0.3
                        min_child_weight = 0.9,
                        #learning_rate = 0.01,
                        n_estimators=300,
                        num_boost_round = 300,
                        gamma = 0.04,
                        #max_depth = 6,
                        reg_lambda = 1.1,
                        subsample = 0.8, # the best
                        colsample_bytree = 1 # the best
                            )

    eval_set = [(test_x, test_y)]
    model.fit(train_x,train_y, early_stopping_rounds=200, eval_metric=['auc','rmsle'], eval_set=eval_set, verbose=True)
    #'logloss',,'error'
    test_y_pred = model.predict_proba(test_x)
    test_y_pred_proba = test_y_pred[:,1] 
    test_y_pred = [0 if proba < 0.5 else 1 for proba in test_y_pred_proba ]
    #print(y_pred_proba)
    #print(test_y_pred)
    #print(test_y)
    accuracy = accuracy_score(test_y, test_y_pred)
    print("Subtype class accuracy: %.2f%%" % (accuracy * 100.0))
    Precision = precision_score(test_y, test_y_pred, average='binary')
    print("Subtype class precision: %.2f%%" % (Precision * 100.0))
    F1_score = f1_score(test_y, test_y_pred, average='binary') 
    print('Subtype F1 score:%.2f%%' %(F1_score*100.0))
    Recall_score = recall_score(test_y, test_y_pred, average='binary')
    print('Subtype Recall score label:%.2f%%' %(Recall_score*100.0))
    Auc_score = roc_auc_score(test_y, test_y_pred_proba)
    print('Subtype auc score label:%.2f%%' %(Auc_score*100.0))
    print(confusion_matrix(test_y,test_y_pred ))
    
    test_pred_table = pd.concat((test_y, pd.DataFrame(test_y_pred_proba)), axis=1)
    test_pred_table.columns = ['truth','proba']
    test_pred_table.to_csv('subtype_predict_proba_resampled_both.csv', index=0)
    # McNemer's test
    y_target = test_y
    y_model1 = np.array(test_y_pred)
    y_model2 = np.ones_like(y_model1)
    tb = mcnemar_table(y_target=y_target, 
                   y_model1=y_model1, 
                   y_model2=y_model2)
    print(tb)
    chi2, p = mcnemar(ary=tb)
    print('chi-squared:', chi2)
    print('McNemer p-value:', p)
