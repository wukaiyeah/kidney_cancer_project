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
    
    # load images isomap features
    with open(images_isomap_features_dir,'rb') as IN:
        images_isomap_features_dict = pickle.load(IN)

    '''
    # load dpn features
    with open(dpn_features_dir,'rb') as IN:
        dpn_features_dict = pickle.load(IN)
    '''
    # load images ics features
    with open(images_ica_features_dir,'rb') as IN:
        images_ica_features_dict = pickle.load(IN)

    # load images lle features
    with open(images_lle_features_dir,'rb') as IN:
        images_lle_features_dict = pickle.load(IN)

    # load images tsne features
    with open(images_tsne_features_dir,'rb') as IN:
        images_tsne_features_dict = pickle.load(IN)


    # load tumor files split
    with open(tumor_cls_split_info, 'rb') as IN:
        tumor_cls_split_info = pickle.load(IN)
        training_files_id = tumor_cls_split_info['train_files']
        testing_files_id = tumor_cls_split_info['test_files']

    #total_files = training_files_id+testing_files_id
    #training_files_id, testing_files_id =  train_test_split(total_files, test_size=0.2, random_state=1234)
    training_files_id = prepare_files_id(training_cases, cf)
    testing_files_id = prepare_files_id(testing_cases, cf)
    # prepare feature array
    training_features = make_input_feature(training_files_id, features_dict)
    testing_features = make_input_feature(testing_files_id, features_dict)

    training_isomap_features = make_input_images_feature(training_files_id, images_isomap_features_dict)
    testing_isomap_features = make_input_images_feature(testing_files_id, images_isomap_features_dict)

    training_pca_features = make_input_images_feature(training_files_id, images_pca_features_dict)
    testing_pca_features = make_input_images_feature(testing_files_id, images_pca_features_dict)

    training_svd_features = make_input_images_feature(training_files_id, images_svd_features_dict)
    testing_svd_features = make_input_images_feature(testing_files_id, images_svd_features_dict)

    training_ica_features = make_input_images_feature(training_files_id, images_ica_features_dict)
    testing_ica_features = make_input_images_feature(testing_files_id, images_ica_features_dict)

    training_lle_features = make_input_images_feature(training_files_id, images_lle_features_dict)
    testing_lle_features = make_input_images_feature(testing_files_id, images_lle_features_dict)

    training_tsne_features = make_input_images_feature(training_files_id, images_tsne_features_dict)
    testing_tsne_features = make_input_images_feature(testing_files_id, images_tsne_features_dict)

    training_features = np.hstack((training_features, training_pca_features,training_svd_features))
    testing_features = np.hstack((testing_features,testing_pca_features, testing_svd_features))

    np.savez_compressed(os.path.join(base_dir, 'train_features_pyradiomics_images.npz'), data = training_features)
    np.savez_compressed(os.path.join(base_dir, 'testset_features_pyradiomics_images.npz'), data = testing_features)
    # prepare target array
    #print(testing_files_id)
    training_labels = make_target_labels(training_files_id, clinical_dict)
    testing_labels = make_target_labels(testing_files_id, clinical_dict)
    np.savez_compressed(os.path.join(base_dir, 'train_target.npz'), data = training_labels)
    np.savez_compressed(os.path.join(base_dir, 'test_target.npz'), data = testing_labels)
