%extract rows and columns of interest fo significant pac clusters of both
%conditions
figsCL = 1;
event = event1;
config.day = day1;
acc = 'all';

QuickPACload;
como1 = comodulogram;
surr1 = surrogates;

%condition 2
event = event2;
config.day = day2;
acc = 'all';

QuickPACload;
como2 = comodulogram;
surr2 = surrogates;

avgcomo = squeeze(mean(como1));
avgcomosurr = squeeze(mean(surr1));


mat3dacc =[];
mat3dnacc = [];
mat3dacc = permute(como1, [2, 3, 1]);
mat3dnacc = permute(surr1, [2, 3, 1]);
clustpm =[];

[clustpm tclust tper pclust, res] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'right', 0.05);

sigclust = zeros(size(clustpm));
for i= 1:max(max(clustpm))
    if pclust(i) < 0.05
        cond = clustpm == i;
        switch byacc
            case {'no', 'acc', 'nacc'}
                sigclust(cond) = avgcomo(cond)-avgcomosurr(cond);
            case 'yes'
                sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
        end
    end
end
mask = false(size(sigclust));
cond = abs(sigclust) > 0;
mask(cond) = true;


clear rowos colos
for i= 1:max(clustpm, [], 'all')
    clustnum = i;
    if pclust(i) < 0.05
        cond = clustpm == clustnum;
        
        
        sc = sigclust.*cond;
        [rowos{i}  colos{i}] = find(abs(sc) > 0);
    else
        sc = zeros(size(sigclust));
    end
end
if ~exist('rowos')
    [rowos{1} colos{1}] = find(max(res, [], 'all') == res);
end

r1 = rowos{1};
c1 = colos{1};
avgcomo = squeeze(mean(como2));
avgcomosurr = squeeze(mean(surr2));

mat3dacc =[];
mat3dnacc = [];
mat3dacc = permute(como2, [2, 3, 1]);
mat3dnacc = permute(surr2, [2, 3, 1]);
clustpm =[];

[clustpm tclust tper pclust, res] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'right', 0.05);

sigclust = zeros(size(clustpm));
for i= 1:max(max(clustpm))
    if pclust(i) < 0.05
        cond = clustpm == i;
        switch byacc
            case {'no', 'acc', 'nacc'}
                sigclust(cond) = avgcomo(cond)-avgcomosurr(cond);
            case 'yes'
                sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
        end
    end
end
mask = false(size(sigclust));
cond = abs(sigclust) > 0;
mask(cond) = true;


clear rowos colos
for i= 1:max(clustpm, [], 'all')
    clustnum = i;
    if pclust(i) < 0.05
        cond = clustpm == clustnum;
        
        
        sc = sigclust.*cond;
        [rowos{i}  colos{i}] = find(abs(sc) > 0);
    else
        sc = zeros(size(sigclust));
    end
end
if ~exist('rowos')
    [rowos{1} colos{1}] = find(max(res, [], 'all') == res);
end

r2 = rowos{1};
c2 = colos{1};

