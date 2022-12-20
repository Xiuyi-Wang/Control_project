import os
from os.path import join as fullfile
import numpy as np
import pandas as pd
from mat73 import loadmat
from scipy.io import savemat
from scipy.stats import pearsonr
from function_classification_network_svm import load_normalized_feature_vectors, svm_classify_kfold, choose_part_features
from joblib import Parallel, delayed
import time

# default parameter
rerun = False #whether to skip if the subject has been run before
task = 'rest'
kmethod = 'linear'


file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N_combined.mat'
file_suffix_full_feature_mat= '_confusionmatrix_full_features.mat'
file_suffix_part_feature_mat= '_confusionmatrix_part_features.mat'

# get teh dicrectory
codeDir = os.getcwd()
print(codeDir)
wd = os.path.dirname(codeDir)
hctsaFolder = fullfile(wd,'data/hctsa_timeseries')
file_label= fullfile(codeDir,'labels.xlsx')

config_mat = loadmat(fullfile(codeDir,'config.mat'), verbose=False)
sub_IDs = config_mat['sub_IDs']

# run for each subject and save the confusion matrix
Error=['']
def run_classify_subject(i):
    time.sleep(1)
    sub_ID=sub_IDs[i][0]
    file_data =  fullfile(hctsaFolder, sub_ID, '%s_task-%s%s'%(sub_ID, task, file_suffix_hctsa_mat_norm))
    file_full_features_mat = fullfile(hctsaFolder, sub_ID, '%s_task-%s%s'%(sub_ID, task, file_suffix_full_feature_mat))
    file_part_features_mat = fullfile(hctsaFolder, sub_ID, '%s_task-%s%s'%(sub_ID, task, file_suffix_part_feature_mat))
    try:
        if not os.path.isfile(file_data):
            raise FileNotFoundError(file_data)
        else:
            
            # step 1: load the data
            data, labels = load_normalized_feature_vectors(file_data, file_label)
            

            # step 2: run the classification using all the features
            if os.path.isfile(file_full_features_mat) and not rerun: 
                print('%d %s: full confusion matrix existed'%(i, sub_ID))
                #svm_classification_full = loadmat(file_full_features_mat)
                #cm_all_features=svm_classification_full['cm_all_features']
                #print('mean accuracy: %f'%(svm_classification_full['accuracy_all_features']))
            else:
                print('%d %s: saving full confusion matrix'%(i, sub_ID)) 
                accuracy_all_features, f1_all_features, cm_all_features = svm_classify_kfold(data, labels, kernel=kmethod)
                #cm_all_features.to_excel(file_full_features_mat, index=False, header=None)
                savemat(file_full_features_mat, mdict={'accuracy_all_features':accuracy_all_features, 
                                                'f1_all_features':f1_all_features,
                                                'cm_all_features':cm_all_features.values})
                                            


            # step 3: run the class ification using part of the features
            if os.path.isfile(file_part_features_mat) and not rerun:
                print('%d %s: part confusion matrix existed'%(i, sub_ID))
                #svm_classification_part = loadmat(file_part_features_mat)
                #cm_part_features=svm_classification_part['cm_part_features']
                #print('mean accuracy: %f'%(svm_classification_part['accuracy_part_features']))
            else:
                print('%d %s: saving part confusion matrix'%(i, sub_ID)) 
                data_part = np.array(choose_part_features(data, feature_part_num=4000))
                accuracy_part_features, f1_part_features, cm_part_features = svm_classify_kfold(data_part, labels, kernel=kmethod)
                #cm_all_features.to_excel(file_full_features_mat, index=False, header=None)
                savemat(file_part_features_mat, mdict={'accuracy_part_features':accuracy_part_features, 
                                                'f1_part_features':f1_part_features,
                                                'cm_part_features':cm_part_features.values})
                

            #%% step 4: check the confusion matrices have high correlation when using all the features or part of the features
            """
            cm_all_features_vector = cm_all_features.values.flatten()
            cm_part_features_vector = cm_part_features.values.flatten()
            
            r, p = pearsonr(cm_all_features_vector,cm_part_features_vector)

            print('check the confusion matrix between full and part features:...')
            print('r=%.2f, p=%.3f'%(r, p))
            """
    except ValueError as e:
        Error.append(e)
        print('%d %s: %s'%(i, sub_ID, e))
    
    if len(Error)>1:
        print(Error[1:])

Parallel(n_jobs=10)(delayed(run_classify_subject)(i) for i in range(0, len(sub_IDs)))
#for i in range(100, len(sub_IDs)):
    #run_classify_subject(i) 