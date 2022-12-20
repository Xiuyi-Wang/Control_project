## check the file mat for each subject and copy to the **hctsa_timeseriese_cm** folder

import os
from os.path import join as fullfile
from mat73 import loadmat

# general parameter
task = 'rest'
file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N_combined.mat'
file_suffix_full_feature_mat= '_confusionmatrix_full_features.mat'
file_suffix_part_feature_mat= '_confusionmatrix_part_features.mat'


# get the dicrectory
codeDir = os.getcwd()
print(codeDir)
wd = os.path.dirname(codeDir)
hctsaFolder = fullfile(wd,'data/hctsa_timeseries')
hctsaFolder_cm  = fullfile(wd,'data/hctsa_timeseries_classification')
file_label= fullfile(codeDir,'labels.xlsx')


config_mat = loadmat(fullfile(codeDir,'config.mat'))
sub_IDs = config_mat['sub_IDs']


for i in range(100,len(sub_IDs)):


    sub_ID = sub_IDs[i][0]
    print('%d %s'%(i, sub_ID))
    file_full_features_mat = fullfile(hctsaFolder, sub_ID, '%s_task-%s%s'%(sub_ID, task, file_suffix_full_feature_mat))
    file_part_features_mat = fullfile(hctsaFolder, sub_ID, '%s_task-%s%s'%(sub_ID, task, file_suffix_part_feature_mat))

    outputFolder = fullfile(hctsaFolder_cm, sub_ID)
    if not os.path.isdir(outputFolder):
        os.makedirs(outputFolder)
    
    if os.path.isfile(file_full_features_mat):
        os.system('cp -an %s %s'%(file_full_features_mat, outputFolder))
    else:
        print('%d full cm not exised: %s'%(i,  file_full_features_mat))
    
    if os.path.isfile(file_part_features_mat):
        os.system('cp -af %s %s'%(file_part_features_mat, outputFolder))
    else:
        print('%d part cm not exised: %s'%(i, file_part_features_mat))
    
