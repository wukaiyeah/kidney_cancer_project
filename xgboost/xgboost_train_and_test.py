#!/usr/bin/python
import os
import random
import numpy as np
import pandas as pd
import xgboost as xgb
import pickle
import matplotlib.pyplot as plt
#from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score,precision_score,f1_score,recall_score,roc_auc_score
from xgboost import XGBClassifier
from xgboost import plot_importance
from sklearn.model_selection import GridSearchCV
import shap


if __name__ == '__main__':
    base_dir = '/home/wukai/Desktop/RCC_classification/xgboost'
    train_label_dir = os.path.join(base_dir,'train_target.npz')
    train_feature_dir = os.path.join(base_dir,'train_features_pyradiomics_images.npz')
    test_label_dir = os.path.join(base_dir, 'test_target.npz')
    test_feature_dir = os.path.join(base_dir, 'testset_features_pyradiomics_images.npz')

    train_feature = np.load(train_feature_dir)['data']
    train_label = np.load(train_label_dir)['data']
    train_subtype_label = train_label[:,0]
    train_stage_label = train_label[:,1]

    test_feature = np.load(test_feature_dir)['data']
    test_label = np.load(test_label_dir)['data']
    test_subtype_label = test_label[:,0]
    test_stage_label = test_label[:,1]


    # for tumor subtype cls
    '''
    # for tuning
    param_test = {'scale_pos_weight' : [0.8],
                'min_child_weight': [rate*0.1 for rate in range(1,10)] + [rate for rate in range(1,10)]}
    gsearch = GridSearchCV(estimator=XGBClassifier( subsample = 1, # the best
                                                    colsample_bytree = 1),
                            param_grid=param_test, scoring='roc_auc', n_jobs=10, cv = 5)
    gsearch.fit(train_feature, train_subtype_label) 
    print(gsearch.best_estimator_)
    print(gsearch.best_params_)
    print(gsearch.best_score_)
    '''

    model = XGBClassifier(scale_pos_weight = 0.80, # the best
                        min_child_weight = 0.9,
                        #learning_rate = 0.06,
                        n_estimators=300,
                        num_boost_round = 300,
                        gamma = 0.04,
                        #max_depth = 6,
                        reg_lambda = 1.1,
                        subsample = 0.8, # the best
                        colsample_bytree = 1 # the best
                            )
    '''
    model = XGBClassifier(scale_pos_weight = 0.80, # the best
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
    model.fit(train_feature, train_subtype_label, early_stopping_rounds=200, eval_metric=['auc'], eval_set=eval_set, verbose=True)
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
    print('Subtype auc score label:%.2f%%' %(Auc_score*100.0))
    
    # save model to file
    pickle.dump(model, open(os.path.join(base_dir,'tumor_subtype_predict_model.pkl'), 'wb'))

    result = pd.DataFrame()
    result['subtype_label'] = test_subtype_label
    result['subtype_proba'] = y_pred_proba

    # model explain
    # make train features table into pandas DataFrame
    '''
    train_feature_table = pd.DataFrame(train_feature)
    # input colnames
    alias = list(pd.read_csv('/home/wukai/Desktop/xgboost/images_features_name_alias.txt',sep = '\t')['alias'])
    colnames = ['t_'+name for name in alias] + ['r_'+name for name in alias] + ['svd_%i'%i for i in range(64)] + ['pca_%i'%i for i in range(256)]

    train_feature_table.columns = colnames

    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(train_feature_table)
    pd.DataFrame(shap_values).to_csv('/home/wukai/Desktop/xgboost/xgboost_subtype_shap_values.csv', sep = ',', index= False)

    shap.summary_plot(shap_values, train_feature_table, show = False, max_display = 20, plot_size = (16.,12.),title='XGBoost Subtype')
    plt.savefig('./subtype_cls_shap_beeswarm.pdf', bbox_inches='tight')
    plt.close()
    '''
    # for tumor stage cls

    eval_set = [(test_feature, test_stage_label)]
    model = XGBClassifier(
                            scale_pos_weight = 0.7,
                            #learning_rate = 0.10, 
                            n_estimators=200,
                            max_depth = 7,
                            subsample = 0.70,
                            reg_lambda = 5,
                            num_boost_round = 60,
                            min_child_weight = 0.8,
                            colsample_bytree=1)
    model.fit(train_feature, train_stage_label, early_stopping_rounds=100, eval_metric=['auc','logloss','error'], eval_set=eval_set, verbose=True)
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

    pickle.dump(model, open(os.path.join(base_dir,'tumor_stage_predict_model.pkl'), 'wb'))

    # write output
    result['stage_label'] = test_stage_label
    result['stage_proba'] = y_pred_proba

    # write output file
    result.to_csv('/home/wukai/Desktop/xgboost/testset_subtype_stage_pred_proba.csv',index=False,sep=',')


    # model explain
    # make train features table into pandas DataFrame
    train_feature_table = pd.DataFrame(train_feature)
    # input colnames

    train_feature_table.columns = colnames

    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(train_feature_table)
    pd.DataFrame(shap_values).to_csv('/home/wukai/Desktop/xgboost/xgboost_stage_shap_values.csv', sep = ',', index= False)
    shap.summary_plot(shap_values, train_feature_table, show = False, max_display = 20, plot_size = (16.,12.),title='XGBoost Subtype')
    plt.savefig('./stage_cls_shap_beeswarm.pdf', bbox_inches='tight')
    plt.close()
    #pd.DataFrame(train_feature).to_csv('/share/Data01/wukai/rcc_classify/xgboost/xgboost_train_features.csv', sep = ',', index= False)

    print('OK')


