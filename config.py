class config():
    def __init__(self):
        self.base_dir = '/home/wukai/Desktop/RCC_classification'
        self.image_dir = '/home/wukai/Desktop/RCC_classification/CT_images/images'
        self.mask_dir = '/home/wukai/Desktop/RCC_classification/CT_images/labels'
        
        self.resample_dir = '/home/wukai/Desktop/RCC_classification//CT_images/images_resampled'
        self.normalized_dir = '/home/wukai/Desktop/RCC_classification/CT_images/images_normalized'
        self.cropped_dir = '/home/wukai/Desktop/RCC_classification/CT_images/images_cropped'

        self.clinical_file = '/share/Data01/wukai/rcc_classify/clinical_all_rcc_dict.pkl'

        # radiomics 
        self.radiomics_dir = '/home/wukai/Desktop/RCC_classification/pyradiomics'
        self.param1_dir = '/home/wukai/Desktop/RCC_classification/pyradiomics/PyradiomicsSettings/Params.yaml'
        self.param2_dir = '/home/wukai/Desktop/RCC_classification/pyradiomics/PyradiomicsSettings/Params_label2.yaml'


        self.process_num = 2
        self.target_spacing = [2.5,2.5,2.5] # [H,Y,X]
        self.tumor_size_threshold = 48*24*24
        self.crop_size = [64,64,64]

