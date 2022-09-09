clear
SUBJ = {  }; %List of subjects
ROIs = {'HPC_Left' 'HPC_Right' 'ERC_Left' 'ERC_Right'}; % list of ROIs

for roi = 1:length(ROIs)

    for sbj = 1:length(SUBJ)

        mm_name = %read AC Values file. Example:  strcat('/HCP/',SUBJ{sbj},'/Output/,ROIs{roi},'_values.nii.gz');
        data = MRIread(mm_name);
        mm = data.vol;
        X = data.height;    
        Y = data.width;
        Z = data.depth;
        L = data.nframes;
        % Reading value maps for all subjects
        Itr = 0;
        for x = 1:X
            for y = 1:Y
                for z = 1:Z
                    if mm(x,y,z,1) ~= 0
                        Itr = Itr + 1;
                        XX(Itr) = x;
                        YY(Itr) = y;
                        ZZ(Itr) = z;
                        mm_mtrx(sbj,Itr,:) = mm(x,y,z,:);
                    end
                end
            end
        end
    end
    %% Creating an average value map
    Ave(:,:) = mean(mm_mtrx,1);
    MSK = zeros(X,Y,Z,size(Ave,2));
    for i = 1:length(XX)
        MSK(XX(i),YY(i),ZZ(i),:) = Ave(i,:);
    end
    cluster_name = % address of the group average value file. Example: strcat('/HCP/Group/',ROIs{roi},'_Values.nii.gz');
    Struct = data;
    Struct.vol = MSK;
    MRIwrite(Struct,cluster_name);

    %% Clustering the average value map
    SimMat = -sqrt(squareform(pdist(Ave)));
    SimMat = (SimMat - min(min(SimMat)))/(max(max(SimMat)) - min(min(SimMat)));
    W = SimMat - eye(size(SimMat));

    [idx,Qlouvain]=community_louvain(W,[],[],'negative_sym');

    Itr = 0;
    N = length(idx);
    %% Calculating size and average autocorrelation of each cluster
    for i = 1:max(idx)
        Sz(i) = sum(idx==i);
        if Sz(i) > 0 
            Itr = Itr + 1;
            ttmp = zeros(1,L);
            Ac_tmp = 0;
            Sm = 0;
            for j = 1:N
                if idx(j) == i 
                    ttmp = ttmp + Ave(j,:);
                    Ac_tmp = Ac_tmp + Ave(j,1);
                    Sm = Sm + 1;
                end
            end
            RefVec(Itr,:) = ttmp./Sm;
            Ref(1,:) = ttmp./Sm;
            AC(Itr) = sqrt(sum(Ref.^2));
            Ac(Itr) = Ac_tmp/Sm;
            Index(Itr) = i;
            Sz2(Itr) = Sz(i);
        end
    end

    %% Sorting clusters based on their autocorrelation
    [~,IDX] = sort(Ac);
    idx_updated = zeros(size(idx));
    for i = 1:Itr
        idx_updated(idx == Index(IDX(i))) = i;
    end
    %% Plotting the AC values with respect to shift
    for i = 1:size(RefVec,1)
        CL = [1 i/size(RefVec,1) 0];
        plot(RefVec(IDX(i),:),'color',CL,'LineWidth',3);
        hold on
    end
    xlabel('Shift');
    ylabel('AC');
    set(gca,'FontSize',16)

    %% Saving AC values in an excel file
    xlswrite(Address to the excel file. Example: strcat('/HCP/Group/',ROIs{roi},'_AC_Values.xls'),RefVec');

    %% Creating output data
    Clusters = zeros(X,Y,Z);
    for i = 1:N
        Clusters(XX(i),YY(i),ZZ(i)) = idx_updated(i);
    end

    cluster_name = % Address to the average cluster file. Example: strcat('/HCP/Group/',ROIs{roi},'_Clusters.nii.gz');
    Struct = data;
    Struct.vol = Clusters;
    MRIwrite(Struct,cluster_name);

    clear AC Index IDX Sz2 Sz Ac
    clear mm_mtrx Ave XX YY ZZ RefVec
 
end