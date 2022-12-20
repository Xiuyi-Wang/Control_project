% step 3 extract features using TS_Compute()
clear;clc;

% initiate hctsa
configpath;
load('config.mat');

wait_time=1;
hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';
%file_suffix_hctsa_mat_done = '_demean_parcel_HCTSA_done.mat';

% 
CoreNum=30;
if isempty(gcp('nocreate')) ; parpool(CoreNum); end

% list all the subjects

for sub_ID_index = 1:length(sub_IDs)
    sub_ID = sub_IDs{sub_ID_index};

    % go through each session
    for i = 1:length(ses_IDs)
        ses_ID = ses_IDs{i};
        
        % change directory
        path_output = fullfile(hctsaFolder,sub_ID);
        cd(path_output);
        
        % go through each run
        for run_ID = 1:run_num
            
            % log current session
            

            % generate filename and full path file
            filename_hctsa_mat = strcat(sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat);
            file_hctsa_mat = fullfile(path_output,filename_hctsa_mat);
            fprintf('checking data of %s ...\n', filename_hctsa_mat);
            
            % check whether file exists
            if isfile(file_hctsa_mat)
                
                % check whether all the data are nan
                data_hctsa = load(file_hctsa_mat);
                data_features = data_hctsa.TS_DataMat;

                % if not all elements are nan, suggesting it has run
                if ~all(isnan(data_features(:)))
                    disp('the run is finished')

                % otherwise, run it 
                else
                    % custom settings for running TS_Compute
                    % doParallel, ts_id_range, op_id_range, computeWhat,
                    % customeFile
                    diary on;
                    log_file = fullfile(LogDir,sprintf('hctsa_compute_%s_run-%d.log', sub_ID, run_ID));
                    diary(log_file);
                    
                    disp ('start extracting features')
                    pause(wait_time);
                    TS_Compute(true, [], [], 'missing', file_hctsa_mat, false);
                    
                    diary off;  
                end
                
            else
                disp (file_hctsa_mat)
                disp ('not exist')
                       
            end
              
        end
    end
end




