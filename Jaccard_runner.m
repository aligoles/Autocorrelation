clear
SUBJ = {  }; %List of subjects
ROIs = {'HPC_Left' 'HPC_Right' 'ERC_Left' 'ERC_Right'}; % list of ROIs
N_Subject = length(SUBJ);
for roi = 1:length(ROIs)
    
    %% Reading group-average clusters
    cluster_name = %Address of the group average clusters. Example: strcat('/HCP/Group/',ROIs{roi},'_Clusters.nii.gz');
    data = MRIread(cluster_name);
    gClusters = data.vol;
    N_Voxel = sum(sum(sum(gClusters~=0)));
    
    %% Separating sub-regions
    N_cluster = max(max(max(gClusters)));
    for i = 1:N_cluster
        gMasks(:,:,:,i) = (gClusters == i);
    end
    Group_J = zeros(N_Subject,N_cluster);
    J = zeros(N_Subject,N_Subject,N_cluster);
    %% Looping through subjects
    for sbj1 = 1:length(SUBJ)
       % Reading files
        mm_name = % address to individual cluster file. Example: strcat('/HCP/',SUBJ{sbj1},'/Output/',ROIs{roi},'_Clusters.nii.gz');
        data = MRIread(mm_name);
        Clusters = data.vol;
        X = data.height;    
        Y = data.width;
        Z = data.depth;
        %% Separating sub-regions
        for i = 1:N_cluster%max(max(max(Clusters)))
            Masks(:,:,:,i) = (Clusters == i);
        end
        %% Calculating Jaccard betweeen group-cluaters and individual clusters
        for i = 1:N_cluster
            Group_J(sbj1,i) = Jaccard(gMasks(:,:,:,i),Masks(:,:,:,i));
        end
        %% Looping through subjects for 2nd time to calculate between-subject Jaccard
        for sbj2 = 1:length(SUBJ)
            % Reading files
            mm_name = % address to individual cluster file. Example: strcat('/HCP/',SUBJ{sbj1},'/Output/',ROIs{roi},'_Clusters.nii.gz');
            data = MRIread(mm_name);
            Clusters = data.vol;
            %% Separating sub-regions
            for i = 1:N_cluster%max(max(max(Clusters)))
                Masks2(:,:,:,i) = (Clusters == i);
            end
            %% Calculating Jaccard betweeen clusters from two individuals
            for i = 1:N_cluster
                J(sbj1,sbj2,i) = Jaccard(Masks(:,:,:,i),Masks2(:,:,:,i));
            end
            clear Masks2
        end
        clear Masks
    end
    clear gMasks
    %% Writing Jaccard between sub-regions from subjects and group-average into a CSV file
    csvwrite(strcat('/HCP/Group/gJaccard_',ROIs{roi},'.csv'),Group_J);
    %% Reorder and save between-subject Jaccards
    for N_roi = 1:N_cluster
        MAT(:,:) = J(:,:,N_roi);

        Itr = 0;
        for i = 1:N_Subject
            for j = i+1:N_Subject
                Itr = Itr + 1;
                MAT_Inter(Itr) = MAT(i,j);
            end
        end
        %% Writing Jaccard between sub-regions from two subjects into a CSV file
        csvwrite(strcat('/HCP/Group/Jaccard_ROI',num2str(N_roi),'_',ROIs{roi},'.csv'),MAT_Inter');
        clear MAT_Inter
    end
end
      