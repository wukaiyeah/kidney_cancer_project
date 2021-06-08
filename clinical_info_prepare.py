import os
import numpy as np
import pickle
import json
import pandas as pd
from config import config

def prepare_ccrcc(CCRCC_clinical_dir,stage_trans, all_cases_id):
    clinical = json.load(open(CCRCC_clinical_dir,'r'))

    cases_info = {}
    for info in clinical:
        if 'pathologic_staging_primary_tumor_pT' in info.keys():
            case_id = info['case_id']
            if case_id in all_cases_id:
                stage = info['pathologic_staging_primary_tumor_pT']
                subtype_name = 'clear_cell_rcc'
                subtype = 1

                vital = -1
                if info.get('vital_status_at_12months_follow_up') == 'Deceased':
                    vital = 1
                elif info.get('vital_status_at_24months_follow_up') == 'Deceased':
                    vital = 1
                elif info.get('vital_status_at_36months_follow_up') == 'Deceased':
                    vital = 1
                elif info.get('vital_status_at_36months_follow_up') == 'Living':
                    vital = 0

                if stage in stage_trans.keys():
                    cases_info[case_id]= {'case_id': case_id,
                                        'source':'CPTAC-CCRCC',
                                        'stage':stage_trans[stage],
                                        'stage_name': stage,
                                        'subtype':subtype,
                                        'subtype_name':subtype_name,
                                        'prognosis': vital
                                        }
    return cases_info

def prepare_kits19(kits19_clinical_dir, stage_trans, all_cases_id):
    clinical = json.load(open(kits19_clinical_dir,'r'))
    cases_info = {}
    for info in clinical:
        info['case_id'] = info['case_id'].replace('_','')# 原始的case_id中有下划线_,删除与file_id一致

        # 将非三大类肾癌种类全转为other
        if info['tumor_histologic_subtype'] == 'clear_cell_rcc':
            subtype = 1
        else:
            subtype = 0

        if 'pathology_t_stage' in info.keys():
            case_id = info['case_id']
            if case_id in all_cases_id:
                stage = info['pathology_t_stage']

                vital = -1 # unknown
                if int(info.get('vital_days_after_surgery')) >= 1000: # 3 years
                    vital = 0 # living


                cases_info[case_id]= {'case_id': case_id,
                                    'source':'KITS19',
                                    'stage':stage_trans[stage],
                                    'stage_name': stage,
                                    'subtype':subtype,
                                    'subtype_name':info['tumor_histologic_subtype'],
                                    'prognosis': vital
                                    }
    return cases_info

def prepare_kirc(KIRC_clinical_dir, stage_trans, all_cases_id):
    clinical = pd.read_csv(KIRC_clinical_dir, sep = '\t', header = 0)
    clinical = clinical.drop_duplicates(['case_id']) #去重
    cases_info = {}
    for case_id in clinical['submitter_id']:
        if case_id in all_cases_id:
            stage = list(clinical[clinical['submitter_id'] == case_id]['ajcc_pathologic_t'])[0]
            subtype_name = 'clear_cell_rcc'
            subtype = 1

            vital_status = list(clinical[clinical['submitter_id'] == case_id]['vital_status'])[0]
            days_to_last_follow_up = days_to_last_follow_up = list(clinical[clinical['submitter_id'] == case_id]['days_to_last_follow_up'])[0]

            vital = -1 # unknown
            if days_to_last_follow_up != '--':
                if vital_status == 'Alive' and int(days_to_last_follow_up) >= 1000: # 5 years
                    vital = 0 # living
                elif vital_status == 'Dead' and int(days_to_last_follow_up) < 1000:
                    vital = 1 # deceased

            if stage in stage_trans.keys():
                cases_info[case_id]= {'case_id': case_id,
                                    'source':'TCGA-KIRC',
                                    'stage':stage_trans[stage],
                                    'stage_name': stage,
                                    'subtype': subtype,
                                    'subtype_name':subtype_name,
                                    'prognosis': vital
                                    }
    return cases_info

def prepare_kirp(KIRP_clinical_dir, stage_trans, all_cases_id):
    clinical = pd.read_csv(KIRP_clinical_dir, sep = '\t', header = 0)
    clinical = clinical.drop_duplicates(['bcr_patient_uuid']) #去重
    cases_info = {}
    for case_id in clinical['bcr_patient_barcode']:
        if case_id in all_cases_id:
            stage = list(clinical[clinical['bcr_patient_barcode'] == case_id]['pathologic_T'])[0]
            subtype_name = 'papillary'
            subtype = 0

            vital_status = list(clinical[clinical['bcr_patient_barcode'] == case_id]['vital_status'])[0]
            days_to_last_followup = list(clinical[clinical['bcr_patient_barcode'] == case_id]['days_to_last_followup'])[0]
            days_to_death = list(clinical[clinical['bcr_patient_barcode'] == case_id]['days_to_death'])[0]
            vital = -1 # unknown
            if vital_status == 'Alive' and int(days_to_last_followup) >= 1000: # 5 years
                vital = 0 # living
            elif vital_status == 'Dead' and int(days_to_death) < 1000:
                vital = 1 # deceased


            if stage in stage_trans.keys():
                cases_info[case_id]= {'case_id': case_id,
                                    'source':'TCGA-KIRP',
                                    'stage':stage_trans[stage],
                                    'stage_name': stage,
                                    'subtype':subtype,
                                    'subtype_name':subtype_name,
                                    'prognosis': vital
                                    }
    return cases_info

def prepare_kich(KICH_clinical_dir, stage_trans, all_cases_id):
    clinical = pd.read_csv(KICH_clinical_dir, sep = '\t', header = 0)
    clinical = clinical.drop_duplicates(['Patient ID']) #去重
    cases_info = {}
    for case_id in clinical['Patient ID']:
        if case_id in all_cases_id:
            stage = list(clinical[clinical['Patient ID'] == case_id]['American Joint Committee on Cancer Tumor Stage Code'])[0]
            subtype_name = 'chromophobe'
            subtype = 0

            overall_survival = list(clinical[clinical['Patient ID'] == case_id]['Overall Survival (Months)'])[0]
            overall_survival_status = list(clinical[clinical['Patient ID'] == case_id]["Patient's Vital Status"])[0]
            vital = -1 # unknown
            if not np.isnan(overall_survival):
                if overall_survival_status == 'Alive' and int(overall_survival) >= 36: # 3 years
                    vital = 0 # living
                elif overall_survival_status == 'Dead' and int(overall_survival) < 36:
                    vital = 1 # deceased


            if stage in stage_trans.keys():
                cases_info[case_id]= {'case_id': case_id,
                                    'source':'TCGA-KICH',
                                    'stage':stage_trans[stage],
                                    'stage_name': stage,
                                    'subtype':subtype,
                                    'subtype_name':subtype_name,
                                    'prognosis': vital
                                    }
    return cases_info



if __name__ == '__main__':
    cf = config()
    CCRCC_clinical_dir = '/share/service04/wukai/CT_image/CPTAC-CCRCC/clinical/CCRCC.json' 
    kits19_clinical_dir = '/share/Data01/wukai/Task001_KITS19/kits.json'
    KIRC_clinical_dir = '/share/service04/wukai/CT_image/TCGA-KIRC/clinical/clinical.tsv'
    KIRP_clinical_dir = '/share/service04/wukai/CT_image/TCGA-KIRP/clinical/clinical_patient_tcga_kirp.tsv'
    KICH_clinical_dir = '/share/service04/wukai/CT_image/TCGA-KICH/clinical/kich_tcga_pub_clinical_data.tsv'
    all_cases_id_dir = '/share/Data01/wukai/rcc_classify/all_cases_id.txt'

    all_cases_id = []
    with open(all_cases_id_dir, 'r') as FILE:
        for case_id in FILE.readlines():
            all_cases_id.append(case_id.strip())
        

    stage_trans =  {'0':-1,
                    '1':0, '1a':0,'1b':0,'1c':0,'T1':0,'T1a':0,'T1b':0,'T1c':0,'pT1':0,'pT1a':0,'pT1b':0,'pT1c':0,
                    '2':1, '2a':1,'2b':1,'2c':1,'T2':1,'T2a':1,'T2b':1,'T2c':1,'pT2':1,'pT2a':1,'pT2b':1,'pT2c':1,
                    '3':2, '3a':2,'3b':2,'3c':2,'T3':2,'T3a':2,'T3b':2,'T3c':2,'pT3':2,'pT3a':2,'pT3b':2,'pT3c':2,
                    '4':3, '4a':3,'4b':3,'4c':3,'T4':3,'T4a':3,'T4b':3,'T4c':3,'pT4':3,'pT4a':3,'pT4b':3,'pT4c':3}


    ccrcc_dict = prepare_ccrcc(CCRCC_clinical_dir, stage_trans, all_cases_id)
    kits19_dict = prepare_kits19(kits19_clinical_dir, stage_trans, all_cases_id)
    kirc_dict = prepare_kirc(KIRC_clinical_dir, stage_trans, all_cases_id)
    kirp_dict = prepare_kirp(KIRP_clinical_dir, stage_trans, all_cases_id)
    kich_dict = prepare_kich(KICH_clinical_dir, stage_trans, all_cases_id)
    
    clinical_rcc_dict = {}
    for clinical_dict in [ccrcc_dict, kits19_dict, kirc_dict, kirp_dict, kich_dict]:
        clinical_rcc_dict.update(clinical_dict)


    with open(os.path.join('/share/Data01/wukai/rcc_classify', 'clinical_all_rcc_dict.pkl'),'wb') as OUT:
        pickle.dump(clinical_rcc_dict, OUT)

    clinical_table = pd.DataFrame(list(clinical_rcc_dict.values()), dtype = int)
    clinical_table.to_csv('/share/Data01/wukai/rcc_classify/clinical_all_rcc_dict.csv', sep=',',index=False)