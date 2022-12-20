from genericpath import isfile
import os
from os.path import join as fullfile
import mat73 
import scipy.io as sio
import numpy as np
from joblib import Parallel, delayed
from sklearn.metrics import pairwise_distances
from function_classification_network_svm import choose_part_features

# get the dicrectory
wd = '/data3_node2/workingFolder/HCP_4run'
codeDir = fullfile(wd, 'code')
resultDir = fullfile(wd,'results')
hctsaFolder = fullfile(wd,'data/hctsa_timeseries')
hctsaFolder_fs = fullfile(wd,'data/hctsa_feature_similarity')

config_mat = mat73.loadmat(fullfile(codeDir,'config.mat'))
task = 'rest'
sub_IDs = config_mat['sub_IDs']
run_IDs = np.arange(4)+1
part_num = 4000

# default parameter
file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N.mat'
file_suffix_hctsa_mat_feature = '_demean_parcel_HCTSA_N_fs.mat'
file_suffix_hctsa_mat_feature_part = '_demean_parcel_HCTSA_N_fs_top%d.mat'%(part_num)

def run_feature_similarity(i):

    sub_ID = sub_IDs[i][0]
    path_input = fullfile(hctsaFolder, sub_ID)
    path_output= fullfile(hctsaFolder_fs, sub_ID)
    os.makedirs(path_output, exist_ok=True) 

    for run_ID in run_IDs:
       
        filename_hctsa_mat_norm = '%s_task-%s_run-%d%s'%(sub_ID,task,run_ID,file_suffix_hctsa_mat_norm)
        file_hctsa_mat_norm = fullfile(path_input,filename_hctsa_mat_norm)
        data_norm = mat73.loadmat(file_hctsa_mat_norm, verbose=False)
        TS_DataMat = np.array(data_norm['TS_DataMat'])
        TS_DataMat_part = choose_part_features(TS_DataMat,part_num)
        
        ######################
        #%% full feature similarity
        ######################
        filename_hctsa_mat_feature = '%s_task-%s_run-%d%s'%(sub_ID,task,run_ID,file_suffix_hctsa_mat_feature)
        file_hctsa_mat_feature = fullfile(path_output,filename_hctsa_mat_feature)
        if not os.path.isfile(file_hctsa_mat_feature):
            #%% Cosine similarity
            # calculate the cosine similarity
            # great cosine similarity, great dist_out value
            similarity_cosine = 1 - pairwise_distances(TS_DataMat, metric="cosine")

            #%% Pearson-R similarity
            # calculate the pearson r similarity
            similarity_r = np.corrcoef(TS_DataMat)
            # fill the diagonal with 0
            np.fill_diagonal(similarity_r, 0)
            # convert r to z
            similarity_z = np.arctanh(similarity_r)
        
            sio.savemat(file_hctsa_mat_feature, {'similarity_cosine': similarity_cosine, 'similarity_r':similarity_r, 'similarity_z':similarity_z}, appendmat=False)
            print('%d saved %s'%(i+1,filename_hctsa_mat_feature))


        ######################
        #%% part feature similarity
        ######################
        filename_hctsa_mat_feature_part = '%s_task-%s_run-%d%s'%(sub_ID,task,run_ID,file_suffix_hctsa_mat_feature_part)
        file_hctsa_mat_feature_part = fullfile(path_output,filename_hctsa_mat_feature_part)
        if not os.path.isfile(file_hctsa_mat_feature_part):
            #%% Cosine similarity
            # calculate the cosine similarity
            # great cosine similarity, great dist_out value
            similarity_cosine = 1 - pairwise_distances(TS_DataMat_part, metric="cosine")

            #%% Pearson-R similarity
            # calculate the pearson r similarity
            similarity_r = np.corrcoef(TS_DataMat_part)
            # fill the diagonal with 0
            np.fill_diagonal(similarity_r, 0)
            # convert r to z
            similarity_z = np.arctanh(similarity_r)
        
            sio.savemat(file_hctsa_mat_feature_part, {'similarity_cosine': similarity_cosine, 'similarity_r':similarity_r, 'similarity_z':similarity_z}, appendmat=False)
            print('%d saved %s'%(i+1,filename_hctsa_mat_feature_part))

if __name__ == '__main__':
    Parallel(n_jobs=20)(delayed(run_feature_similarity)(i) for i in range(len(sub_IDs)))
    #run_feature_similarity(1)
