
%% t scoring 
alldata = [];
alldata(:, 1, :, :) = comodulogram;
alldata = [alldata surrogates];

sizemat = (size(avgcomo, 1)*size(avgcomo, 2)*numel(subjc)*1001);
como_n = alldata;%./sum(alldata, 'default', 'all');
% for n = 1:1000
%     surr_n(:, n, :, :) = surrogates(:, n, :, :)./sum(surrogates(:, n, :, :), 'default', 'all');
%     surr_nn(:, n, :, :) =surr_n(:, n, :, :)-1/sizemat;
% end

como_nn= como_n-mean(como_n, 'all');
como_n1 = squeeze(como_nn(:, 1, :, :));
surr_nn = como_nn(:, 2:end, :, :);
como_nn = como_n1;
%tscore
for lf = 1:length(phaseint)
    for hf = 1:length(ampint)
        [h p(lf, hf), ci, t]= ttest(squeeze(como_nn(:, lf, hf)));
        tvalsexp(lf, hf) = t.tstat;
    end
end
for n = 1:1000
    for lf = 1:length(phaseint)
        for hf = 1:length(ampint)
            [h ps(n, lf, hf), ci, t]= ttest(squeeze(surr_nn(:, n, lf, hf)));
            tvalssurr(n, lf, hf) = t.tstat;
        end
    end
end

for n = 1:1000
    [clustss tcls] = findclust(squeeze(tvalssurr(n, :, :)), 0.025);
    if isempty(tcls) == 1
        tcls = 0;
    end
    tclsm(n) = tcls(1);
end

[clust tcl] = findclust(tvalsexp, 0.025);


tsurrs = sort(tclsm);
for t=1:length(tcl)
    [val idx] = min(abs(tsurrs-tcl(t)));
    ptsort(t) = 1-idx/1000;
end

mask = zeros(size(clust));
cond = clust>0;
mask(cond) = true;
clustpm = clust;
sigclust = tvalsexp;
clear rowos colos
for i= 1:max(clustpm, [], 'all')
    clustnum = i;
    a = find(clustpm == i);
    if ptsort(i) <0.05
        cond = clustpm == clustnum;
        sc = sigclust.*cond;
        [rowos{i}  colos{i}] = find(abs(sc) > 0);
    else
        sc = zeros(size(sigclust));
    end
end
if ~exist('rowos') 
    [rowos{1} colos{1}] = find(max(avgcomo, [], 'all') == avgcomo);
end
% 