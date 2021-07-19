#!/usr/bin/python
import os
import numpy as np
import pandas as pd
#from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score,precision_score,f1_score,recall_score,roc_auc_score, confusion_matrix
from xgboost import XGBClassifier
from mlxtend.evaluate import mcnemar_table, mcnemar
from imblearn.combine import SMOTEENN,SMOTETomek


if __name__ == '__main__':
    base_dir = '/media/wukai/Data01/RCC_classification/kidney_cancer_project/xgboost'
    train_label_dir = os.path.join(base_dir,'train_target.npz')
    train_feature_dir = os.path.join(base_dir,'train_features_pyradiomics_images.npz')
    test_label_dir = os.path.join(base_dir, 'test_target.npz')
    test_feature_dir = os.path.join(base_dir, 'testset_features_pyradiomics_images.npz')

    train_feature = np.load(train_feature_dir)['data']
    train_label = np.load(train_label_dir)['data']
    train_subtype_label = train_label[:,0]


    test_feature = np.load(test_feature_dir)['data']
    test_label = np.load(test_label_dir)['data']
    test_subtype_label = test_label[:,0]
    # for tumor subtype cls
    smote_enn = SMOTEENN(random_state=0)
    #test_feature,test_subtype_label = smote_enn.fit_resample(test_feature,test_subtype_label)


    model = XGBClassifier(scale_pos_weight = 0.30, 
                        min_child_weight = 0.9,
                        #learning_rate = 0.01,
                        n_estimators=100,
                        num_boost_round = 300,
                        gamma = 0.04,
                        #max_depth = 6,
                        reg_lambda = 1.1,
                        subsample = 0.8, # the best
                        colsample_bytree = 1 # the best
                            )
    '''
    model = XGBClassifier(scale_pos_weight = 0.30, # the best
                        min_child_weight = 0.9,
                        n_estimators=300,
                        num_boost_round = 300,
                        gamma = 0.04,
                        reg_lambda = 1.1,
                        subsample = 0.8, # the best
                        colsample_bytree = 1 # the best
                            )
    '''
    eval_set = [(test_feature, test_subtype_label)]
    model.fit(train_feature, train_subtype_label, early_stopping_rounds=200, eval_metric=['auc','logloss','error'], eval_set=eval_set, verbose=True)
    #'logloss',,'error'
    y_pred = model.predict_proba(test_feature)
    y_pred_proba = y_pred[:,1] 
    y_pred_class = [0 if proba < 0.5 else 1 for proba in y_pred_proba ]
    #print(y_pred_proba)
    #print(y_pred_class)
    #print(test_subtype_label)
    accuracy = accuracy_score(test_subtype_label, y_pred_class)
    print("Subtype class accuracy: %.2f%%" % (accuracy * 100.0))
    Precision = precision_score(test_subtype_label, y_pred_class, average='binary')
    print("Subtype class precision: %.2f%%" % (Precision * 100.0))
    F1_score = f1_score(test_subtype_label, y_pred_class, average='binary') 
    print('Subtype F1 score:%.2f%%' %(F1_score*100.0))
    Recall_score = recall_score(test_subtype_label, y_pred_class, average='binary')
    print('Subtype Recall score label:%.2f%%' %(Recall_score*100.0))
    Auc_score = roc_auc_score(test_subtype_label, y_pred_proba)
    print('Subtype auc score label:%.2f%%' %(Auc_score))
    print(confusion_matrix(test_subtype_label,y_pred_class ))
    # McNemer's test
    y_target = test_subtype_label
    y_model1 = np.array(y_pred_class)
    y_model2 = np.ones_like(y_model1)
    tb = mcnemar_table(y_target=y_target, 
                   y_model1=y_model1, 
                   y_model2=y_model2)
    chi2, p = mcnemar(ary=tb)
    print('chi-squared:', chi2)
    print('McNemer p-value:', p)
    # save model to file
    

