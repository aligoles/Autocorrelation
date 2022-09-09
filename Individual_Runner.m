clear
SUBJ = {  }; %List of subjects
ROIs = {'HPC_Left' 'HPC_Right' 'ERC_Left' 'ERC_Right'}; % list of ROIs
L = 5; %% Length of autocorrelation vector
    
for sbj = 1:length(SUBJ)

    %% Reading pre-processed fMRI data
    func_name =   % Address to the fMRI data of each subject. Example: strcat('/HCP/',SUBJ{sbj},'func.nii.gz');
    data = MRIread(func_name);
    func = data.vol;
    X = data.height;    
    Y = data.width;
    Z = data.depth;
    TR = .001*data.tr;
    %% Specifying output directory
    output_folder = % Output directory. Example: strcat('/HCP/',SUBJ{sbj},'/Output/');
    mkdir(output_folder)

    for roi = 1:length(ROIs)
        %% Reading ROI mask
        ROI_mask_name = % address of the mask. Example: strcat('/HCP/',ROIs{roi},'.nii.gz');
        data = MRIread(ROI_mask_name);
        ROI_mask = data.vol;

        dataOut = data;
        [Map,Clusters] = AC_generator(func,ROI_mask,L,TR,Filter_trigger);

        dataOut.vol = Clusters;
        PTH = strcat(output_folder,ROIs{roi},'_clusters.nii.gz');
        MRIwrite(dataOut,PTH); 

        dataOut.vol = Map;
        PTH = strcat(output_folder,ROIs{roi},'_values.nii.gz');
        MRIwrite(dataOut,PTH); 

        clear Map Clusters ROI_mask
    end
    clear func
end