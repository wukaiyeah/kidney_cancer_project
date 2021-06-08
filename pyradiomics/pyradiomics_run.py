import os
import glob

def prepare_files_dir(image_dir,mask_dir):
    assert os.path.exists(image_dir), 'Can not find dir'
    assert os.path.exists(mask_dir), 'Can not find dir'
    masks_dir = glob.glob(os.path.join(mask_dir, '*.nii.gz'))
    files_id = [mask_dir.split('/')[-1].replace('.nii.gz','') for mask_dir in masks_dir]
    images_dir = [os.path.join(image_dir, file_id + '_0000.nii.gz') for file_id in files_id]
    return images_dir, masks_dir

def write_input_csv(csv_dir, images_dir, masks_dir):
    with open(csv_dir,'w') as OUT:
        OUT.write('Image,Mask\n')
        for i in range(len(images_dir)):
            OUT.write(images_dir[i]+','+masks_dir[i]+'\n')

    
def run(csv_dir, para_dir, output_dir):
    cmd = 'pyradiomics %s --p %s --jobs %d -o %s -f csv' % ( csv_dir, para_dir, 4, output_dir)
    os.system(cmd)

def pyradiomics_run(cf):
    radiomics_dir = cf.radiomics_dir
    image_dir = cf.image_dir
    mask_dir = cf.mask_dir
    param1_dir = cf.param1_dir
    param2_dir = cf.param2_dir

    images_dir, masks_dir = prepare_files_dir(image_dir,mask_dir)
    print('Find %d files'%(len(images_dir)))

    csv_dir = os.path.join(radiomics_dir, 'images_dir_for_pyradiomics_input.csv')
    write_input_csv(csv_dir, images_dir, masks_dir)

    cf.radiomics_features1 = os.path.join(radiomics_dir, 'radiomics_features_label_1.csv')
    cf.radiomics_features2 = os.path.join(radiomics_dir, 'radiomics_features_label_2.csv')  
    
    run(csv_dir, param1_dir, cf.radiomics_features1)
    run(csv_dir, param2_dir, cf.radiomics_features2)
 
    return cf
    # pyradiomics <path/to/input> -o results.csv -f csv


if __name__ == '__main__':
    pass