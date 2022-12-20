% step 6 check the normalization result, the number of sucessful operations.

clear;
clc;

% initiate hctsa
configpath;
load('config.mat');

wait_time=1;
hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';
file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N.mat';

% the percentage of valid features
feature_thre = 0.8;
feature_thre_num = 7729 * feature_thre;

dataSummary = table();

for sub_ID_index = 1:length(sub_IDs)
    sub_ID = sub_IDs{sub_ID_index};
    

    % go through each session
    for i = 1:length(ses_IDs)
        ses_ID = ses_IDs{i};
        
        path_output = fullfile(hctsaFolder, sub_ID);
        
        
        % go through each run
        for run_ID = 1:run_num
            
            
            % generate filename and full path file
            filename_hctsa_mat_norm = strcat(sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat_norm);
            file_hctsa_mat_norm = fullfile(path_output,filename_hctsa_mat_norm);
            
            % check whether file exists
            if isfile(file_hctsa_mat_norm)

                fprintf('checking normalization of %s \n', filename_hctsa_mat_norm);
                
                % check the valid parcel num and feature num after
                % normalization
                
                % load the data, get the TS_DataMat, get its size
                % disp the parcel num or feature num if they are less than
                % the threshold
           
                data_norm = load(file_hctsa_mat_norm,'TS_DataMat');
                data_norm_ts_size = size(data_norm.TS_DataMat);
                num_ts = data_norm_ts_size(1);
                num_features =  data_norm_ts_size(2);
                prop_features = num_features/7729*100;

                row = {sub_ID, run_ID, num_ts, num_features, prop_features,filename_hctsa_mat_norm};
                T_temp=cell2table(row,'VariableNames',{'sub_ID','run_ID','n_parcel','n_features','prop_features','filename'});
                dataSummary=[dataSummary;T_temp];
                clear T_temp;

                fprintf(['  valid parcels: %d \n' ...
                         '  valid features: %d out of 7729 (%.1f%%)\n\n'],num_ts, num_features, prop_features);
            else
                fprintf('%s not exist \n!',file_hctsa_mat_norm);
                       
            end     
        end
    end
end

writetable(dataSummary,fullfile(CodeDir,'check_normalization.xlsx'));


