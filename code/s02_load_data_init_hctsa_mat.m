% step 1 load the data and then init the data
clear;
clc;

% initiate hctsa
configpath;
load('config.mat');
addpath(fullfile(ciftiDir));

hctsaFolder = fullfile(DataDir, 'hctsa_timeseries');
ptseriesFolder = fullfile(DataDir,'ind_parcel_400_4run_ptseries');
file_suffix_nii = '_demean_parcel.ptseries.nii';
file_suffix_init_mat = '_demean_parcel_ts_init.mat';
file_suffix_hctsa_mat = '_demean_parcel_HCTSA.mat';

%% create labels and keywords
% read the file atlas
file_atlas = 'Schaefer_417.xlsx';
data_atlas = import_atlas(file_atlas);

%retrive the information, keywords=network, labels=strcat3column
data_label=data_atlas(:,{'network_id_full','network_name','parcel_ID_full'});
data_label{:,2}=rowfun(@(x) erase(x,'17networks_'),data_label,'InputVariables',2,'OutputFormat','uniform');
mergecell=@(a,b,c) strjoin([a,b,c],'_');
labels=rowfun(mergecell,data_label,'OutputFormat','cell');
labels=cellfun(@char,labels,'UniformOutput',false);
keywords=cellstr(char(data_atlas.network));

%% initialize the mat files

% use parallel toolbox
CoreNum=30;
if isempty(gcp('nocreate')) ; parpool(CoreNum); end

parfor sub_ID_index = 1:length(sub_IDs)
    sub_ID = sub_IDs{sub_ID_index};
    
    % go through each session

    path_output = fullfile(hctsaFolder,sub_ID);
    if ~exist(path_output, 'dir'); mkdir(path_output); end
    cd(path_output);

    % go through each run
    for run_ID = 1:run_num
        % generate filename and full path file
        filename_nii = [sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_nii];
        file_nii = fullfile(ptseriesFolder,sub_ID,filename_nii);
        
        filename_init_mat = [sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_init_mat];
        file_init_mat = fullfile(path_output,filename_init_mat);
        
        filename_hctsa_mat = [sub_ID,'_task-',task,'_run-',num2str(run_ID),file_suffix_hctsa_mat];
        file_hctsa_mat = fullfile(path_output,filename_hctsa_mat);
        
        % check whether the output exists
        if isfile(file_hctsa_mat)
            fprintf('hctsa has run: %s run-%d\n', sub_ID,run_ID);
            
        else
            % check whether nii map exists,
            if isfile(file_nii)
                % load the data
                cifti = cifti_read(file_nii);
                data = cifti.cdata;
                data = double(data)';

                % prepare input for real analysis
                % convert data to 1 * parcel_num cell
                % each cell is a vector 400:1 (n_timepoints)
                % data_new = num2cell(data,[parcel_num,timepoint_num]);

                % transpose the time series data
                timeSeriesData = num2cell(data,1)';

                % Save these variables out to INP_ts.mat:
                parsave(file_init_mat, timeSeriesData, labels, keywords);

                % this is the mat file you already have in the hctsa folder
                TS_Init(file_init_mat, [], [], false, file_hctsa_mat);

            else
                error('file nii not existed: %s\n', file_nii);     
            end
        
        end
        
    end
end

cd(CodeDir);

function parsave(fname, timeSeriesData, labels, keywords)
    save(fname, 'timeSeriesData', 'labels', 'keywords');
end
