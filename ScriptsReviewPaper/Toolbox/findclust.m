function [clust tcl] = findclust(mat1, pt)

%degrees of freedom = 9 because there are 9 patients, this is changed to 8
%for MTL PAC analysis because there are 9 patients with MTL.
df = 9;

%the test is one tailed: PAC values are inherently positive and we are
%looking only for instances were the experimental pac is bigger than the
%surrogates as a negative PAC would not make sense. to emulate the
%threshold of a two-way test even for one tailed we can set pt to pt/2 (in
%this case to 0.025).

tt = abs(tinv(pt, df));
bw = mat1 > tt;
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