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
    train_label_dir = os.path.join(base_dir,'train_grade_target.npz')
    train_feature_dir = os.path.join(base_dir,'train_features_grade_pyradiomics_images.npz')
    test_label_dir = os.path.join(base_dir, 'test_grade_target.npz')
    test_feature_dir = os.path.join(base_dir, 'testset_features_grade_pyradiomics_images.npz')

    train_feature = np.load(train_feature_dir)['data']
    train_label = np.load(train_label_dir)['data']

    test_feature = np.load(test_feature_dir)['data']
    test_label = np.load(test_label_dir)['data']

    '''
    #x_train,x_test,y_train,y_test = train_test_split(feature, label, test_size = 0.1)  
    dtrain = xgb.DMatrix(train_feature, train_label)
    dtest  = xgb.DMatrix(test_feature, train_label)

    param = {'objective':'multi:softmax',
            'learning_rate':0.001,
            "eval_metric":"mlogloss",
            'eta':0.1,
            'max_depth':3,
            'nthread':2,
            'num_class':3,
            'seed':1234}
    # use softmax multi-class classification
    cv_res= xgb.cv(param, dtrain, early_stopping_rounds=100,nfold=5,show_stdv=True)
    print('Best number of trees = {}'.format(cv_res.shape[0]))
    print(cv_res)
    '''


    # for tumor subtype cls
    model = XGBClassifier(learning_rate = 0.08, 
                            scale_pos_weight = 0.86,
                            n_estimators=300,
                            max_depth = 8,
                            subsample = 0.74,
                            reg_lambda = 1.1,
                            num_boost_round = 100,
                            min_child_weight = 1,
                            colsample_bytree=1)
    '''
    model = XGBClassifier(learning_rate = 0.08, 
                            scale_pos_weight = 0.86,
                            n_estimators=300,
                            max_depth = 8,
                            subsample = 0.74,
                            reg_lambda = 1.1,
                            num_boost_round = 100,
                            min_child_weight = 1,
                            colsample_bytree=1)
    '''
    eval_set = [(test_feature, test_label)]
    model.fit(train_feature, train_label, early_stopping_rounds=100, eval_metric=['auc'], eval_set=eval_set, verbose=True)

    y_pred = model.predict_proba(test_feature)
    y_pred_proba = y_pred[:,1] 
    y_pred_class = [0 if proba < 0.5 else 1 for proba in y_pred_proba ]

    accuracy = accuracy_score(test_label, y_pred_class)
    print("Subtype class accuracy: %.2f%%" % (accuracy * 100.0))
    Precision = precision_score(test_label, y_pred_class, average='binary')
    print("Subtype class precision: %.2f%%" % (Precision * 100.0))
    F1_score = f1_score(test_label, y_pred_class, average='binary') 
    print('Subtype F1 score:%.2f%%' %(F1_score*100.0))
    Recall_score = recall_score(test_label, y_pred_class, average='binary')
    print('Subtype Recall score label:%.2f%%' %(Recall_score*100.0))
    Auc_score = roc_auc_score(test_label, y_pred_proba)
    print('Subtype auc score label:%.2f%%' %(Auc_score*100.0))
    print(confusion_matrix(test_label,y_pred_class ))
    # McNemer's test
    y_target = test_label
    y_model1 = np.array(y_pred_class)
    y_model2 = np.ones_like(y_model1)
    tb = mcnemar_table(y_target=y_target, 
                   y_model1=y_model1, 
                   y_model2=y_model2)
    chi2, p = mcnemar(ary=tb,exact=True)
    print('chi-squared:', chi2)
    print('McNemer p-value:', p)
    print('complete')
    # save model to file

