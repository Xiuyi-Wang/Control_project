%step 4 add group label to each time series
clear;
clc;

% initiate hctsa
configpath;
load('config.mat');

wait_time=1;
hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';
file_suffix_hctsa_mat_done = '_demean_parcel_HCTSA_done.mat';


CoreNum=20;
if isempty(gcp('nocreate')) ; parpool(CoreNum); end

% list all the subjects
parfor sub_ID_index = 101:length(sub_IDs)
    sub_ID = sub_IDs{sub_ID_index};
    for i = 1:length(ses_IDs)
        ses_ID = ses_IDs{i};
        path_output = fullfile(hctsaFolder,sub_ID);
        % change directory
        cd(path_output);
            
        % go through each run
        for run_ID = 1:run_num
            
            % generate filename and full path file
            filename_hctsa_mat = strcat(sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat);
            file_hctsa_mat = fullfile(path_output,filename_hctsa_mat);
            fprintf('checking data of %s ...\n', filename_hctsa_mat);
            % check whether file exists
            if isfile(file_hctsa_mat)
                disp ('start assigning group labels to data')
     
                TS_LabelGroups(file_hctsa_mat, {'Aud', 'ContA', 'ContB', 'ContC', 'DefaultA', 'DefaultB', 'DefaultC', 'DorsAttnA', 'DorsAttnB', 'Language', 'SalVenAttnA', 'SalVenAttnB', 'SomMotA', 'SomMotB', 'VisualA', 'VisualB', 'VisualC'});
            
            else
                disp (file_hctsa_mat)
                disp ('not exist')        
            end     
        end
    end
end




