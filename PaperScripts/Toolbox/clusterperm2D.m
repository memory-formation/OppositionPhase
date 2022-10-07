function [Cluster,T_Cluster,T_per,p_Cluster, res]=clusterperm2D(A,B,nPer,method,tail,alpha)
%-[Preal,Pper]=xb_permutTF(A,B,nPer,nCluster)
%
%
% Permutation test for 2-D data, get first nCluster major clusters,
% desending by number of voxel (instead of sum T value)
% Input:  
% A & B,      Two Matrix for permutation text, with same size of 3
%             dimensions. datapoints * datapoints * trial           
% nPer,       Number of permutation. By default 1000
% method,     Method of t-test. ('within' or 'between') By default paired t-test
% tail,       Direction of t-test. 'two', 'left' or 'right', By default 'right'
% alpha,      sig threshold, by default 0.05
%
% Output:
% Cluster,    Real n_cluster defined by T-test, 2 D matrix datapoints * datapoints 
% T_Cluster,  T value of each cluster
% T_per,      Null distribution of the biggest cluster T value
% p_Cluster,  p value of each cluster
%
%
% Author:  Xiongbo Wu, 2019-10-15 (modified 2020.11.16)
%- corrected p_value output 2021.05.18


switch nargin 
    case {0,1}
        error('Both ''A'' and ''B'' are requiered')
    case 2
        nPer = 1000; method = 'within'; tail = 'right'; alpha = 0.05;
    case 3
        method = 'within'; tail = 'right'; alpha = 0.05;
    case 4 
        tail = 'right'; alpha = 0.05;
    case 5
        alpha = 0.05;
end

switch tail
    case {'right','left'}
    case 'two'
        alpha = alpha/2;
end 
        
%% T test of real data 


C = reshape(A,[size(A,1)*size(A,2),size(A,3)]);
D = reshape(B,[size(B,1)*size(B,2),size(B,3)]); 
switch method
    case 'within'
        [~,P,~,STATS] = ttest (C',D');
        res = STATS.tstat;
    case 'between'
        [~,P,~,STATS] = ttest2 (C',D');
        res = STATS.tstat;
end

switch tail 
    case 'left'
        Preal = P < alpha & res<0;
        Preal = reshape(Preal,size(A,[1,2]));
        res   = reshape(res,size(A,[1,2]));
    case 'right'
        Preal = P < alpha & res>0;
        Preal = reshape(Preal,size(A,[1,2]));
        res   = reshape(res,size(A,[1,2]));
    case 'two'
        Preal = P < alpha;
        Preal = reshape(Preal,size(A,[1,2]));
        res   = reshape(res,size(A,[1,2]));
end 
clearvars P STATS C D
%% Finding cluster
cc = bwconncomp(Preal); 
numPixels = cellfun(@numel,cc.PixelIdxList);
[~,V_ind]=sort(numPixels,'descend'); % numbers of cluster voxel and their index in matrix.
nCluster = length(cc.PixelIdxList);
Cluster = zeros(size(A,[1,2]));
T_Cluster = zeros(nCluster,1);
for i_clstr = 1:nCluster
    Cluster(cc.PixelIdxList{V_ind(i_clstr)})=i_clstr;
    T_Cluster(i_clstr)=sum(res(cc.PixelIdxList{V_ind(i_clstr)}));
    
end
clearvars i_clstr cc numPixels V_ind nCluster Preal

%% Rand Permutation %%%%%%%%%%%%%%%%%%%%%%%


T_per=zeros(nPer,1);% T value of all cluster in all permutation


for i_Per = 1:nPer
    
    display (['permutation number: ' int2str(i_Per)]);
    i_perm_A = randperm(size(A,3));
    i_perm_B = randperm(size(B,3));
    
    number_shuffle = randperm(min(size(A,3),size(B,3)),1);
    C_A=randperm(min(size(A,3),size(B,3)),number_shuffle);
    C_B=randperm(min(size(A,3),size(B,3)),number_shuffle);
    
    Shf_A = A(:,:,i_perm_A);
    Shf_B = B(:,:,i_perm_B);
        
    Shf_A(:,:,C_A)=B(:,:,C_B);
    Shf_B(:,:,C_B)=A(:,:,C_B);

    clearvars i_shf number_shuffle C_A C_B
    
    % T test (for all points then identify value)
    Shf_C = reshape(Shf_A,[size(Shf_A,1)*size(Shf_A,2),size(Shf_A,3)]);
    Shf_D = reshape(Shf_B,[size(Shf_B,1)*size(Shf_B,2),size(Shf_B,3)]);
    switch method
        case 'within'
            [~,P_perm,~,STATS_perm] = ttest (Shf_C',Shf_D');
            res_perm = STATS_perm.tstat;
        case 'between'
            [~,P_perm,~,STATS_perm] = ttest2 (Shf_C',Shf_D');
            res_perm = STATS_perm.tstat;
    end

    Preal_perm = P_perm < alpha ;
    Preal_perm = reshape(Preal_perm,size(A,[1,2]));
    res_perm   = reshape(res_perm,size(A,[1,2]));

    %% Finding cluster
    cc_perm = bwconncomp(Preal_perm);
    numPixels = cellfun(@numel,cc_perm.PixelIdxList);
    [~,V_ind]=sort(numPixels,'descend'); % numbers of cluster voxel and their index in matrix.
    nCluster_perm = length(cc_perm.PixelIdxList);
    if ~isempty(numPixels)
        T_Cluster_perm = zeros(nCluster_perm,1);
        for i_clstr = 1:nCluster_perm
            T_Cluster_perm(i_clstr)=sum(res_perm(cc_perm.PixelIdxList{V_ind(i_clstr)}));
            
        end
        clearvars i_clstr
        
        [~,ind_max] = max(abs(T_Cluster_perm));
        T_per(i_Per) = T_Cluster_perm(ind_max);
        clearvars ind_max T_Cluster_perm
    else
        T_per(i_Per) = 0;
    end
    
    


   
       
end
%% calculateing p value
if ~isempty(T_Cluster)
    p_Cluster = zeros(length(T_Cluster),1);
    switch tail
        case 'right'
            for i=1:length(T_Cluster)
                p_Cluster(i)=sum(T_Cluster(i)<T_per)/nPer;
            end
        case 'left'
            for i=1:length(T_Cluster)
                p_Cluster(i)=sum(T_Cluster(i)>T_per)/nPer;
            end
        case 'two'
            for i=1:length(T_Cluster)
                if T_Cluster(i)<0
                    p_Cluster(i)=sum(T_Cluster(i)>T_per)/nPer;
                else
                    p_Cluster(i)=sum(T_Cluster(i)<T_per)/nPer;
                end
            end
    end
else
    p_Cluster = [];
end
