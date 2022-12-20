# Control project


## 1. extract features and normalization using hctsa in Matlab

- `s01_demean_data.m`. Demean the .ptseries.nii data 
- `s02_load_data_init_hctsa_mat.m`. Initiate the `hctsa` mat file
- `s03_extract_feature_loop.m`. Extract the excessive features.
- `s04_add_group_label.m`. Assign group labels to data for each subject each run.
- `s05_filting_normalize.m`. Filtering and normalizing for each subject each run
- `s06_check_normalization_output.m`, check the output of normalization
- `s07_combine_hctsa_norm_files_for_each_participant.m`, combined the 4 runs of each participant.


## 2. classification
- `s08_1_classify_across_networks_each_subj_each_session_save_cm.py`. Compute using sklearn-svm linear classification
- `s08_2_check_copy_confusion_matrix.py`. Check and copy

## 3. calculate feature similarity
- `s9_check_copy_confusion_matrix.py`