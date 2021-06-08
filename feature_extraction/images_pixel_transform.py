'''
image shape 64*64*64 (H,Y,X)
Using PCA to reduce dimension into 64*32 (H, feature)
reture a dict(.pkl) file
'''

import os
import numpy as np
import pickle
import glob
from multiprocessing import Pool
from functools import partial
from sklearn.decomposition import PCA, FastICA
from sklearn.manifold import Isomap, LocallyLinearEmbedding, TSNE

def pca_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('pca process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (64,-1))
    # pca
    pca = PCA(4).fit(image)
    image_feature = pca.transform(image)
    image_feature = np.reshape(image_feature, (1,-1))
    return {file_id:image_feature}

def svd_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('svd process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (64,-1))
    # pca
    U, S, Vh = np.linalg.svd(image)
    image_feature = np.reshape(S, (1,-1))
    return  {file_id:image_feature}

def isomap_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('isomap process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (64,-1))
    # isomap
    isomap = Isomap(n_components=4)
    image_feature = isomap.fit_transform(image)
    image_feature = np.reshape(image_feature, (1,-1))
    return  {file_id:image_feature}

def ica_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('ica process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (24,-1))
    # isomap
    ica = FastICA(n_components=3)
    image_feature = ica.fit_transform(image)
    image_feature = np.reshape(image_feature, (1,-1))
    return  {file_id:image_feature}

def lle_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('lle process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (24,-1))
    # isomap
    lle = LocallyLinearEmbedding(n_components=4)
    image_feature = lle.fit_transform(image)
    image_feature = np.reshape(image_feature, (1,-1))
    return  {file_id:image_feature}

def tsne_reduce_dimension(file_dir):
    assert os.path.exists(file_dir),'Can not find file in %s'%(file_dir)
    file_id = file_dir.split('/')[-1].replace('.npz','')
    print('TSNE process %s'%file_id)
    image = np.load(file_dir)['data']
    image = np.reshape(image, (64,-1))
    # isomap
    tsne = TSNE(n_components=3,verbose=1)
    image_feature = tsne.fit_transform(image)
    image_feature = np.reshape(image_feature, (1,-1))
    return  {file_id:image_feature}


if __name__ == '__main__':
    base_dir = '/share/Data01/wukai/rcc_classify/xgboost'
    images_source = '/share/service04/wukai/CT_image/testset/images_cropped_tumor'
    files_dir = glob.glob(os.path.join(images_source, '*.npz'))
    print('Need process %d files'%len(files_dir))
    files_id = [file_dir.split('/')[-1].replace('.npz','') for file_dir in files_dir]

    # multiple process

    with Pool(30) as pool:
        features_list = pool.map(partial(pca_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_pca_features = {}
    for features_dict in features_list:
        images_pca_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_pca_testset_tumor_features.pkl'), 'wb') as OUT:
        pickle.dump(images_pca_features, OUT)

    with Pool(30) as pool:
        features_list = pool.map(partial(svd_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_svd_features = {}
    for features_dict in features_list:
        images_svd_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_svd_testset_tumor_features.pkl'), 'wb') as OUT:
        pickle.dump(images_svd_features, OUT)
    '''
    with Pool(10) as pool:
        features_list = pool.map(partial(isomap_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_svd_features = {}
    for features_dict in features_list:
        images_svd_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_all_isomap_ori_features.pkl'), 'wb') as OUT:
        pickle.dump(images_svd_features, OUT)

    with Pool(10) as pool:
        features_list = pool.map(partial(ica_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_ica_features = {}
    for features_dict in features_list:
        images_ica_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_ica_ori_features.pkl'), 'wb') as OUT:
        pickle.dump(images_ica_features, OUT)


    with Pool(10) as pool:
        features_list = pool.map(partial(lle_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_lle_features = {}
    for features_dict in features_list:
        images_lle_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_lle_ori_features.pkl'), 'wb') as OUT:
        pickle.dump(images_lle_features, OUT)


    with Pool(30) as pool:
        features_list = pool.map(partial(tsne_reduce_dimension), files_dir) # 并行
        pool.close()
        pool.join()
    images_tsne_features = {}
    for features_dict in features_list:
        images_tsne_features.update(features_dict)
    with open(os.path.join(base_dir, 'images_tsne_tumor_features.pkl'), 'wb') as OUT:
        pickle.dump(images_tsne_features, OUT)
    '''
    print('Complete')

