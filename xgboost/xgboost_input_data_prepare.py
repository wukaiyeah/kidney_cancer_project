import os
import json
import pandas as pd
import numpy as np
import glob
import pickle
from sklearn.model_selection import train_test_split
import sys
sys.path.append('/share/Data01/wukai/rcc_classify')

def prepare_files_id(cases_id, files_id):
    target_files_id = [file_id for file_id in files_id if file_id.split('_')[0] in cases_id] 
    return sorted(target_files_id)

def make_input_feature(files_id, features_dict):
    features_list = []
    for file_id in files_id:
        features_tumor = features_dict[file_id]['tumor']
        features_kidney = features_dict[file_id]['kidney']
        features_list.append(features_tumor + features_kidney)
    features_array = np.array(features_list)
    return features_array


def make_input_images_feature(files_id, features_dict):
    features_list = []
    for file_id in files_id:
        features_list.append(features_dict[file_id])
    features_array = np.vstack(features_list)
    return features_array


def make_target_labels(files_id, clinical_dict):
    target_labels = []
    for file_id in files_id:
        case_id = file_id.split('_')[0]
        subtype = clinical_dict[case_id]['subtype']
        stage = clinical_dict[case_id]['stage']
        target_labels.append([subtype,stage])
    return np.array(target_labels)



if __name__ == "__main__":
    base_dir = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost'
    clinical_dir = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/clinical_all_rcc_dict.pkl'
    training_cases_info = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/dataset_cases_split.pkl'
    tumor_cls_split_info = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/tumor_cls_split.pkl'
    pyradiomics_result_dir = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/pyradiomics_enhanced_result.json'
    images_pca_features_dir = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/images_pca_ori_features.pkl'
    images_svd_features_dir = '/home/wukai/Desktop/RCC_classification/kidney_cancer_project/xgboost/images_svd_ori_features.pkl'

    # load training cases
    with open(training_cases_info, 'rb') as IN:
        training_cases_info = pickle.load(IN)
        training_cases = training_cases_info['training']
        testing_cases = training_cases_info['testing']

    # load clinical info
    with open(clinical_dir, 'rb') as IN:
        clinical_dict = pickle.load(IN)

    # load pyradiomics result
    with open(pyradiomics_result_dir,'r') as IN:
        features_dict = json.load(IN)

    # load images pca features
    with open(images_pca_features_dir,'rb') as IN:
        images_pca_features_dict = pickle.load(IN)

    # load images pca features
    with open(images_svd_features_dir,'rb') as IN:
        images_svd_features_dict = pickle.load(IN)
  

    #total_files = training_files_id+testing_files_id
    #training_files_id, testing_files_id =  train_test_split(total_files, test_size=0.2, random_state=1234)
    training_files_id = prepare_files_id(training_cases, list(images_pca_features_dict.keys()))
    testing_files_id = prepare_files_id(testing_cases, list(images_pca_features_dict.keys()))
    # prepare feature array
    training_features = make_input_feature(training_files_id, features_dict)
    testing_features = make_input_feature(testing_files_id, features_dict)

    training_pca_features = make_input_images_feature(training_files_id, images_pca_features_dict)
    testing_pca_features = make_input_images_feature(testing_files_id, images_pca_features_dict)

    training_svd_features = make_input_images_feature(training_files_id, images_svd_features_dict)
    testing_svd_features = make_input_images_feature(testing_files_id, images_svd_features_dict)

    training_labels = make_target_labels(training_files_id, clinical_dict) #  ['subtype','stage']
    testing_labels = make_target_labels(testing_files_id, clinical_dict)

    training_features = np.hstack((training_labels,training_features, training_pca_features,training_svd_features))
    testing_features = np.hstack((testing_labels, testing_features,testing_pca_features, testing_svd_features))


    training_table = pd.DataFrame(training_features)
    training_table.index = training_files_id
    testing_table = pd.DataFrame(testing_features)
    testing_table.index = testing_files_id

    colnames = ['subtype_label', 'stage_label'] + \
                [name.replace('original','tumor') for name in features_dict['feature_names']] + \
                [name.replace('original','kidney') for name in features_dict['feature_names']] + \
                ['pac_'+str(id) for id in range(256)] + \
                ['svd_'+str(id) for id in range(64)]
    training_table.columns = colnames        
    testing_table.columns = colnames

    training_table.to_csv(os.path.join(base_dir, 'train_features_pyradiomics_images.csv'),index=True)
    testing_table.to_csv(os.path.join(base_dir, 'testset_features_pyradiomics_images.csv'),index=True)
