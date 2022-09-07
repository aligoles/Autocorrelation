function [Map,Clusters] = AC_generator(func,ROI_mask,L,TR,Filter_trigger)
%% This functuion calculate voxel-wise autocorrelation (AC) of fMRI data within a mask
%% Inputs:
%%      func: 4D fMRI data
%%      ROI_mask: 3D mask (e.g. Hippocampus mask
%%      L: length of AC shifts (e.g. 5 for HCP data)
%%      TR: TR of fMRI data
%% Outputs:
%%      Map: 4D map of autocorreation values within the mask
%%      Clusters: 3D map of clusters based on modularity maximization method
addpath('/home/ali/paco/build')
addpath('/home/ali/Documents/MATLAB/BCT/2017_01_15_BCT/')

X = size(func,1);
Y = size(func,2);
Z = size(func,3);

%% Filter design for low-pass filtering the signal
%Filter_trigger = 1;
d1 = designfilt('lowpassiir','PassbandRipple', 0.1, ...
                 'StopbandAttenuation', 50, ...
            'PassbandFrequency',0.09,'StopbandFrequency',0.11,'SampleRate', 1/TR);

%% Reading signals and calculating autocorrelation
N = sum(sum(sum(ROI_mask~=0)));
ac = zeros(N,L);
XX = zeros(N,1);
YY = zeros(N,1);
ZZ = zeros(N,1);
Order = zeros(N,1);
Itr = 0;
for x = 1:X
    for y = 1:Y
        for z = 1:Z
            if ROI_mask(x,y,z)~=0
                Itr = Itr + 1;
                tg(:,1) = func(x,y,z,:);
                if Filter_trigger
                    Sig(:,1) = filtfilt(d1,tg);
                else
                    Sig(:,1) = tg(:,1);
                end
                Sig = Sig - mean(Sig);
                at = xcorr(Sig,L,'unbiased');
                ac(Itr,:) = at(L+2:end);
                XX(Itr) = x;
                YY(Itr) = y;
                ZZ(Itr) = z;
                Order(Itr) = Itr;
            end
        end
    end
end
VC(1,:) = ac(:,1);
ac = (ac - mean(VC))/std(VC);

%% Calculating similarity matrix
SimMat = -sqrt(squareform(pdist(ac)));
SimMat = (SimMat - min(min(SimMat)))/(max(max(SimMat)) - min(min(SimMat)));
W = SimMat - eye(size(SimMat)); %% Initial similarity matrix

%% Modulairty Maximization
%[COMTY ~] = cluster_jl(W,1,1);
%idx = COMTY.COM{size(COMTY.COM,2)};
[M,Qlouvain]=community_louvain(W,[],[],'negative_sym');
%[Ci,Qnewman]=modularity_und(W);

idx = M';
%%
%[idx, asymp_surprise] = paco_mx(W,'quality',2);
%idx = idx + 1;

%%
%N_cluster = max(idx);
%AC = zeros(1,N_cluster);
%Sz = zeros(1,N_cluster);

Itr = 0;
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
                ttmp = ttmp + ac(j,:);
                Ac_tmp = Ac_tmp + ac(j,1);
                Sm = Sm + 1;
            end
        end
        Ref(1,:) = ttmp./Sm;
        AC(Itr) = sqrt(sum(Ref.^2));
        Ac(Itr) = Ac_tmp/Sm;
        Index(Itr) = i;
        Sz2(Itr) = Sz(i);
    end
end

%% Sorting clusters based on their autocorrelation
%[~,IDX] = sort(AC);

[~,IDX] = sort(Ac);
%[~,IDX] = sort(Sz2,'descend');
idx_updated = zeros(size(idx));
for i = 1:Itr
    idx_updated(idx == Index(IDX(i))) = i;
end

%% Creating output data
Clusters = zeros(X,Y,Z);
Map = zeros(X,Y,Z,L);
for i = 1:N
   % Clusters(XX(i),YY(i),ZZ(i)) = IDX(idx(i));
    Clusters(XX(i),YY(i),ZZ(i)) = idx_updated(i);
    Map(XX(i),YY(i),ZZ(i),:) = (ac(i,:));%-min(ac(:,1)))/(max(ac(:,1))-min(ac(:,1)));
end