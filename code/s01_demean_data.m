%single parcellation using gMSHBM
clear;
clc;

%initiate
configpath;
load('config.mat');
cd(CodeDir);
addpath(ciftiDir);
file_suffix_func = 'space-fsLR_den-91k_desc-residual_smooth_bold.dtseries.nii';



% setup directory
%file_suffix_ds = 'space-fsLR_den-91k_desc-residual_smooth_bold.dtseries.nii';
file_suffix_ps = 'parcel.ptseries.nii';
input_dir = fullfile(DataDir, 'ind_parcel_400_4run');
ptseries_dir=fullfile(DataDir, 'ind_parcel_400_4run_ptseries');
if ~isdir(ptseries_dir); mkdir(ptseries_dir);end

%get template 
template_file = fullfile(WorkDir,'template',file_suffix_ps);
template_data = cifti_read(template_file);
template_data.diminfo{2}.seriesStep=0.78;
template_data.diminfo{2}.length=1200;

%% step 1 write to .ptseries.nii
for i = 1:length(sub_IDs)
    sub_ID=sub_IDs{i};
    S=load(fullfile(input_dir,sub_ID,'data_pacel.mat'));
    output_dir=fullfile(ptseries_dir,sub_ID);
    if ~exist(output_dir,'dir'); mkdir(output_dir);end
    for runid=1:run_num
        ptseries_data=squeeze(S.data_pacel(2:end,:,runid));

        file_ps = fullfile(output_dir,sprintf('%s_task-rest_run-%d_%s',sub_ID,runid, file_suffix_ps));

        if ~exist(file_ps,'file')
            cifti1=template_data;
            cifti1.cdata=ptseries_data;
            cifti_write(cifti1,file_ps);
            fprintf('creating %s\n',file_ps);
        else
            fprintf('existed: %s\n',file_ps)
        end

    end
end

%% step 2 .demean the ptseries

%whether to use parallel toolbox
CoreNum=16;
if isempty(gcp('nocreate')) ; parpool(CoreNum); end
    
file_suffix_ps_mean = 'mean_parcel.ptseries.nii';
file_suffix_ps_demean = 'demean_parcel.ptseries.nii';
parfor i = 1:length(sub_IDs)
    sub_ID=sub_IDs{i};
    output_dir=fullfile(ptseries_dir,sub_ID);
    for runid=1:run_num
        file_ps = fullfile(output_dir,sprintf('%s_task-rest_run-%d_%s',sub_ID, runid, file_suffix_ps));
        file_ps_mean = fullfile(output_dir,sprintf('%s_task-rest_run-%d_%s',sub_ID,runid, file_suffix_ps_mean));
        file_ps_demean = fullfile(output_dir,sprintf('%s_task-rest_run-%d_%s',sub_ID,  runid, file_suffix_ps_demean));
        get_mean_data(wb_command, file_ps, file_ps_mean);
        demean_data(wb_command, file_ps, file_ps_mean, file_ps_demean)
    end

end


%% function
% step 1 get the mean each data
function get_mean_data(path_workbench, input_file,output_file_mean)
%     get the mean data
%     :param: input_file, fMRI time series data; it is *_space-fsLR_den-91k_desc-residual_smooth_bold.dtseries.nii
%     return: output_file_mean, *mean.dscalar.nii

    % check whether the mean and demean  have been saved; if yes, pass
    if exist(output_file_mean,'file')
        fprintf('mean file already exists %s\n ', output_file_mean);
        return
%     # if not, generate these files
%     # Make sure the next command will be executed only if the first command returns exit status zero
%     # Get the mean of each vertex; Demean the time series of each file_ori;
    elseif ~exist(input_file,'file')
        error('error file not exists %s\n ', input_file);
    else
        unix([path_workbench,' -cifti-reduce ', input_file, '  MEAN ', output_file_mean ]);
    end
end

% step 2 demean each data
function demean_data(path_workbench, input_file, output_file_mean, output_file_demean)

% demean the resting state data of each run and then save it
% get the mean of the demeaned time series data of each vertex/parcel and then save it
% :param input_file: fMRI time series data; it is *_space-fsLR_den-91k_desc-residual_smooth_bold.dtseries.nii
% :param output_file_mean: *mean.dscalar.nii, the mean bold for each vertex/parcel
% :param output_file_demean: the demeaned output input_file - output_file_mean
% :return: None


    % check whether the mean and demean  have been saved; if yes, pass
    if  exist(output_file_demean,'file')
        fprintf('demean file already exists %s\n ', output_file_mean);
        return

    elseif ~exist(input_file,'file')
        error('input_file not exists: %s\n', input_file)

    elseif ~exist(output_file_mean,'file')
        error('output_file_mean not exists: %s\n', output_file_mean)

    % if not, generate these files
    % Make sure the next command will be executed only if the first command returns exit status zero
    % Get the mean of each vertex; Demean the time series of each file_ori;
    else
        unix([path_workbench, '  -cifti-math  ', ' x-mean ', output_file_demean,...
              ' -fixnan 0 -var x ', input_file, ' -var mean ', ...
              output_file_mean, ' -select 1 1 -repeat ']);
    end
end