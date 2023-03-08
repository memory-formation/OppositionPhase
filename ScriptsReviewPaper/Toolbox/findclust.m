function [clust tcl] = findclust(mat1, pt, dirtest)

df = 9;

switch dirtest
    case 'two'
        pt = pt/2;
        tt = abs(tinv(pt, df));
        bw = abs(mat1) > tt;
    case 'one'
        tt = abs(tinv(pt, df));
        bw = mat1 > tt;
end
% Find connected components
CC = bwconncomp(bw);
% Plot the clusters
labeled = labelmatrix(CC);
% imagesc(labeled);

cMapPrimary = zeros(size(mat1));
tSumPrimary = zeros(CC.NumObjects,1);
for i=1:CC.NumObjects
    npix(i) = length(CC.PixelIdxList{i});
    cMapPrimary(CC.PixelIdxList{i}) = i;
    tSumPrimary(i) = sum(mat1(CC.PixelIdxList{i}));
end
% Sort clusters:
[~,tSumIdx] = sort(abs(tSumPrimary),'descend');
tSumPrimary = tSumPrimary(tSumIdx);
clust = cMapPrimary;
clust2 = zeros(size(clust));
for j = 1:length(tSumIdx)
%     [idx] = find(j == tSumIdx);
    cond = clust == tSumIdx(j);
    clust2(cond) = j;
end

clust =clust2;

tcl = tSumPrimary;

    
end