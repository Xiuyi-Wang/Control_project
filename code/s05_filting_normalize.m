% step5  filter and normalize the HCTSA.mat data for each run
clear;
clc;

% initiate hctsa
configpath;
load('config.mat');

wait_time=1;
hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';
file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N.mat';

CoreNum=30;
if isempty(gcp('nocreate')) ; parpool(CoreNum); end

parfor sub_ID_index = 1:length(sub_IDs)
    sub_ID = sub_IDs{sub_ID_index};
    
    % go through each session
    for i = 1:length(ses_IDs)

        % change directory
        ses_ID = ses_IDs{i};
        path_output = fullfile(hctsaFolder,sub_ID);
        cd(path_output);

         
        % go through each run
        for run_ID = 1:run_num
            
            % generate filename and full path file
            filename_hctsa_mat = strcat(sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat);
            file_hctsa_mat = fullfile(path_output,filename_hctsa_mat);
            
            filename_hctsa_mat_norm = strcat(sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat_norm);
            file_hctsa_mat_norm = fullfile(path_output,filename_hctsa_mat_norm);
            
            if isfile(file_hctsa_mat_norm)
                fprintf('normalization has run before \n %s',file_hctsa_mat_norm );     
            else
                % check whether file exists
                if isfile(file_hctsa_mat)

                    % custom settings for running TS_Compute
                    % doParallel, ts_id_range, op_id_range, computeWhat,
                    % customeFile
                    disp ('start filting and normalizing')

                    %pause(wait_time);

                    % Filtering and normalizing
                    % involves filtering out operations or time series that produced 
                    % many errors or special-valued outputs, and then normalizing of the output of all operations
                    % Columns with approximately constant values are also filtered out.

                    TS_Normalize('mixedSigmoid',[0.9,1.0],file_hctsa_mat);


                else
                    disp (file_hctsa_mat)
                    disp ('not exist')

                end    
            end
        end
    end
end




