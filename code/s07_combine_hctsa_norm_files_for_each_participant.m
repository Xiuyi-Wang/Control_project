% combine normalization files for each participant for each session

clear;
clc;

% initiate hctsa
configpath;
load('config.mat');

wait_time = 1;
hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
% hctsaFolder_combine = fullfile(DataDir, 'hctsa_timeseries_combined');

file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';
file_suffix_hctsa_mat_norm = '_demean_parcel_HCTSA_N.mat';
file_suffix_hctsa_mat_norm_combined = '_demean_parcel_HCTSA_N_combined.mat';

% go through each session
for i = 1:length(ses_IDs)

    % go through each participant

    parfor sub_ID_index = 1:length(sub_IDs)

        %         for sub_ID_index = 3:5;
        sub_ID = sub_IDs{sub_ID_index};
        

        % get the combined file
        path_output = fullfile(hctsaFolder, sub_ID);
        filename_combined = strcat(sub_ID, '_task-', task, file_suffix_hctsa_mat_norm_combined);
        file_combined = fullfile(hctsaFolder, sub_ID, filename_combined);

        HCTSAs = {};

        if isfile(file_combined)
            fprintf('data have been combined before: %s\n',file_combined);
        else
            % go through each run
            for run_ID = 1:run_num
                % generate filename and full path file
                filename_hctsa_mat_norm = strcat(sub_ID, '_task-', task, '_run-', num2str(run_ID), file_suffix_hctsa_mat_norm);
                file_hctsa_mat_norm = fullfile(hctsaFolder, sub_ID, filename_hctsa_mat_norm);

                % check whether file exists
                if isfile(file_hctsa_mat_norm)

                    % append it to
                    HCTSAs = [HCTSAs, file_hctsa_mat_norm];

                else
                    fprintf('not existed: %s\n', file_hctsa_mat_norm);

                end
            end

            fprintf('start merging data %s..\n', file_combined);
            function_combine_hctsa_norm_files(HCTSAs, file_combined);

        end



    end

end
