import os
import json
import pandas as pd
import numpy as np
import glob
import pickle
from sklearn.model_selection import train_test_split
import sys
sys.path.append('/share/Data01/wukai/rcc_classify')
from config import config 

def prepare_files_id(cases_id, cf):
    files_dir = glob.glob(os.path.join(cf.cropped_dir,'*.npz'))
    files_id = [file_dir.split('/')[-1].replace('.npz','') for file_dir in files_dir]
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
    cf = config()
    base_dir = '/share/Data01/wukai/rcc_classify/xgboost'
    clinical_dir = '/share/Data01/wukai/rcc_classify/clinical_all_rcc_dict.pkl'
    training_cases_info = '/share/Data01/wukai/rcc_classify/dataset_cases_split.pkl'
    tumor_cls_split_info = '/share/Data01/wukai/rcc_classify/tumor_cls_split.pkl'
    pyradiomics_result_dir = '/share/Data01/wukai/rcc_classify/xgboost/pyradiomics_enhanced_result.json'
    images_pca_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_pca_ori_features.pkl'
    images_svd_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_svd_ori_features.pkl'
    images_isomap_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_isomap_ori_features.pkl'
    images_ica_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_ica_ori_features.pkl'
    images_lle_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_lle_ori_features.pkl'
    images_tsne_features_dir = '/share/Data01/wukai/rcc_classify/xgboost/images_tsne_ori_features.pkl'
    dpn_features_dir = '/share/Data01/wukai/rcc_classify/dpn26_params47_pca_features.pkl'
    # load training cases
    with open(training_cases_info, 'rb') as IN:
        training_cases_info = pickle.load(IN)
        training_cases = training_cases_info['training']
        testing_cases = training_cases_info['testing']

    # load pyradiomics result
    with open(pyradiomics_result_dir,'r') as IN:
        features_dict = json.load(IN)

    # load images pca features
    with open(images_pca_features_dir,'rb') as IN:
        images_pca_features_dict = pickle.load(IN)

    # load images pca features
    with open(images_svd_features_dir,'rb') as IN:
        images_svd_features_dict = pickle.load(IN)

    # load tumor files split
    with open(tumor_cls_split_info, 'rb') as IN:
        tumor_cls_split_info = pickle.load(IN)
        training_files_id = tumor_cls_split_info['train_files']
        testing_files_id = tumor_cls_split_info['test_files']


    cases_id = training_cases + testing_cases
    files_id = prepare_files_id(cases_id, cf)

    # prepare feature array
    training_features = make_input_feature(files_id, features_dict)
    training_pca_features = make_input_images_feature(files_id, images_pca_features_dict)
    training_svd_features = make_input_images_feature(files_id, images_svd_features_dict)
    training_features = np.hstack((training_features, training_svd_features, training_pca_features))

    features_names = ['sample_id'] + ['tumor_%s'%i for i in features_dict['feature_names']] + ['kidney_%s'%i for i in features_dict['feature_names']] +['svd_%d'%i for i in range(64)]+['pca_%d'%i for i in range(256)]
    with open('images_features_table.txt','w') as IN:
        IN.write('\t'.join(features_names)+'\n')
        for i, file_id in enumerate(files_id):
            IN.write(file_id+'\t')
            IN.write('\t'.join([str(i) for i in training_features[i].tolist()])+'\n')
    




    print('ok')