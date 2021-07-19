'''
调整nifti文件，将出问题的image与label文件的所有信息重新矫正
'''
import json
import os
import pandas as pd
import pickle
import glob
import shutil
import SimpleITK as sitk
import numpy as np

def check_meta(image_sitk, mask_sitk,file_name):
    if image_sitk.GetSize() != mask_sitk.GetSize():
        print('%s Size Not Pair!'%file_name)
        return file_name
    if image_sitk.GetOrigin() != mask_sitk.GetOrigin():
        print('%s Origin Not Pair!'%file_name)
        return file_name
    if image_sitk.GetSpacing() != mask_sitk.GetSpacing():
        print('%s Spacing Not Pair!'%file_name)
        return file_name
    if image_sitk.GetDirection() != mask_sitk.GetDirection():
        print('%s Direction Not Pair!'%file_name)
        return file_name

def correct_meta(image_sitk, mask_sitk):
    origin = image_sitk.GetOrigin()
    spacing = image_sitk.GetSpacing()
    direction = image_sitk.GetDirection()
    
    mask_sitk.SetOrigin(origin)
    mask_sitk.SetSpacing(spacing)
    mask_sitk.SetDirection(direction)
    return mask_sitk

if __name__ == '__main__':
    base_dir = '/share/Data01/wukai/rcc_classify/xgboost'
    csv_file = '/share/Data01/wukai/rcc_classify/xgboost/file_dir.csv'
    files_dir_table = pd.read_csv(csv_file)
    images_dir = files_dir_table['Image'].tolist()
    masks_dir = files_dir_table['Mask'].tolist()
    files_name = [image_dir.split('/')[-1] for image_dir in images_dir]
    '''
    mask_file_wrong_list = []
    for i,image_dir in enumerate(images_dir):
        mask_dir = masks_dir[i]
        assert os.path.exists(image_dir), 'Can not find file %s in images dir'%(files_name[i])
        assert os.path.exists(mask_dir), 'Can not find file %s in labels dir'%(files_name[i])

        image_sitk = sitk.ReadImage(image_dir)
        mask_sitk = sitk.ReadImage(mask_dir)
        mask_file_wrong_list.append(check_meta(image_sitk, mask_sitk,files_name[i]))
    print(mask_file_wrong_list)
    '''
    mask_file_wrong_list = ['C3L-00812_5_0000.nii.gz', 'C3L-01958_10_0000.nii.gz', 'TCGA-BP-4173_0_0000.nii.gz', 'C3N-03018_0_0000.nii.gz']
    wrong_images_dir = [image_dir for image_dir in images_dir if image_dir.split('/')[-1] in mask_file_wrong_list]
    wrong_masks_dir = [mask_dir for mask_dir in masks_dir if mask_dir.split('/')[-1].replace('.nii.gz','_0000.nii.gz') in mask_file_wrong_list]

    for i,image_dir in enumerate(wrong_images_dir):
        mask_dir = wrong_masks_dir[i]
        mask_name = mask_dir.split('/')[-1]
        assert os.path.exists(image_dir), 'Can not find file %s in images dir'%(files_name[i])
        assert os.path.exists(mask_dir), 'Can not find file %s in labels dir'%(files_name[i])
        image_sitk = sitk.ReadImage(image_dir)
        mask_sitk = sitk.ReadImage(mask_dir)
        new_mask_sitk = correct_meta(image_sitk, mask_sitk)
        sitk.WriteImage(new_mask_sitk, os.path.join(base_dir, mask_name))
