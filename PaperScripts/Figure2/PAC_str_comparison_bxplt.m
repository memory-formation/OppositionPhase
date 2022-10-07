%compare PACS
%this function may be used only when PAC has already been computed for both
%conditions as it loads the conditions. it compares them for accuracy.
%loads data that is the output of PAC_img_avg


clear
wantsurr = 'no';
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')

addpath('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Dependent_Scripts');
addpath '/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses';
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
config.unimodality  = 'yes';
event1              = [10 11 12 13];    %eventvalues of the event: 10 11 12 13 = images 1 2 3 4
day1                = 1;
%50 is recall, 24 is offset
event2              = event1 ;            %eventvalue of the second dataset same codes as event1.
%It can be the same event in case of comparing accurate and non accurate trials
%day of when the eventvalue takes place, it can be 1 or 2 for both days
day2                = day1;
config.recfrom      = 2;                %take accuracy from day 2 or accuracy from day 1
phaseint            = [4:12];            %phase of interest
ampofint            = [30:5:140];        %amplitude of interest
acc1                = 'acc'             % takes all trials, only accurate ones or non accurate ones.
acc2                = 'nacc'             % same as acc 1, options are 'all', 'acc' 'nacc'
config.norm         = 'norm'            %'no', 'norm'
tint                = [0 2.5];          %latency of interest
config.artdeftype   = 'complete';       %type of artefact detection wanted.
config.regressors   = 'Accuracy';       %how the regressors are going to be extracted
config.keeptrials   = 'no';
config.MI           = 'MVL';
config.output       = config.MI;
byacc               = 'no';
config.n_iter       = 1000;
%Chans of interest
config.equalize     = 'no';             %'no' to have an equal number of trials in both conditions
defaultschansubj;
timeint             = tint; %time of interest
config.day          = day1; 
config.normamp      ='no';
Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles';
switch config.ROI
    case 'Hippocampus'
        roi = [];
    case'middletemporal'
        roi = '_MT';
end
switch config.output
    case 'corrected'
        method = 'MOVI';
    case 'DKL'
        method = 'DKL';
end
config.latency = timeint;
config.lowfreq = phaseint;
config.highfreq = ampofint;

%% load comodulogram and surrogates

%condition 1
figsCL = 0; %put figsCL = 1 if you want figures of comodulogram
event = event1;
if numel(event) == 2 | event == 10 | event == 11 | event == 12 | event == 13
    event = [10 11 12 13];
end

%load dataset 1 with all trials to extract the cluster of interest
config.day = day1;
acc = 'all';

QuickPACload;
% comodulogram;
% surrogates;


%cluster permutation test between the two conditions
mat3dacc =[];
mat3dnacc = [];
mat3dacc = permute(comodulogram, [2, 3, 1]);
%         mat3dnacc = zeros(size(mat3dacc));
mat3dnacc = permute(surrogates, [2, 3, 1]);

[clustpm tclust tper pclust res] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'right');

sigclust = zeros(size(clustpm));
for i= 1:max(max(clustpm))
    if pclust(i) < 0.05
        cond = clustpm == i;
        switch byacc
            case {'no', 'acc', 'nacc'}
                sigclust(cond) = avgcomo(cond);
            case 'yes'
                sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
        end
    end
end

mask = false(size(sigclust));
cond = sigclust > 0;
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

% only max val
% ru = unique(rowos{1});
% cu = unique(colos{1});
% resres = res(ru, cu);
% mr = max(resres, [], 'all');
% clear rowos colos
% [rowos colos] = find(mr == res);

% all clust
rowosall = rowos{1};
colosall = colos{1};

%load accurate trials to extract values within the cluster of interest
figsCL = 0;
acc = 'acc';
event = event1;
QuickPACload;

como1 = comodulogram;
surr1 = surrogates;
%load non accurate trials to extract values within the cluster of interest
acc = 'nacc';
QuickPACload;
como2 = comodulogram;
surr2 = surrogates;
% 
% como1 = (como1-surr1);
% como2= (como2-surr2);
% como1(8, :, :) = [];
% como2(8, :, :) =[];
%t-test of accurate vs nona ccurate matrices
mat3dacc =[];
mat3dnacc = [];
mat3dacc = permute(como1, [2, 3, 1]);
%         mat3dnacc = zeros(size(mat3dacc));
mat3dnacc = permute(como2, [2, 3, 1]);

[clustpm tclust tper pclust res] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'right');

sigclust = zeros(size(clustpm));
for i= 1:max(max(clustpm))
    if pclust(i) < 0.05
        cond = clustpm == i;
        switch byacc
            case {'no', 'acc', 'nacc'}
                sigclust(cond) = avgcomo(cond);
            case 'yes'
                sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
        end
    end
end
mask = false(size(sigclust));
cond = sigclust > 0;
mask(cond) = true;

ac1 = squeeze(mean(como1));
ac2 = squeeze(mean(como2));
ac = ac1-ac2;

fig = figure;
contourf(config.lowfreq, config.highfreq, ac')%,40,'linecolor','none')
set(gca,'clim',[-5 5])
    hold on;
    contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
title('Map of phase-amplitude coupling')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
 ch = colorbar;
    set(ch, 'FontSize', 16)
    set(gcf, 'color', 'white');

fig = figure;
contourf(config.lowfreq, config.highfreq, res')
set(gca,'clim',[-3 3])
    hold on;
    contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
title('Map of T values')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
 ch = colorbar;
    set(ch, 'FontSize', 16)
    set(gcf, 'color', 'white');

%% bxplt 
%average values within cluster of interest to 1 value per patient
% como1 = (como1-surr1);
% como2 = (como2-surr2);
bpl1 = como1(:, rowosall, colosall);
bpl2 = como2(:, rowosall, colosall);
spl1 = surr1(:, rowosall, colosall);
spl2 = surr2(:, rowosall, colosall);


comocorr1 = squeeze(mean(bpl1, [2 3]));
comocorr2 = squeeze(mean(bpl2, [2 3]));

% outlier1 = (comocorr1 < mean(comocorr1)-2*std(comocorr1)) | (comocorr1 > mean(comocorr1)+2*std(comocorr1));
% outlier2 = (comocorr2 < mean(comocorr2)-2*std(comocorr2)) | (comocorr2 > mean(comocorr2)+2*std(comocorr2));
% comocorr1(outlier2 ==1 | outlier1 ==1) = [];
% comocorr2(outlier2 ==1 | outlier1 ==1) = [];


%% test

[h p ci stat] = ttest(comocorr1, comocorr2);
p

%% figure
%figprep
clear bxpltdat xx x scatdat
bxpltdat(:, 1) = comocorr1;
bxpltdat(:, 2) = comocorr2;
scatdat = [bxpltdat(:, 1); bxpltdat(:, 2)]
c1 = [0 0.4470 0.7410];
c2 = [0.8500 0.3250 0.0980];
ccs = [c1; c2];
colrs = [repmat(c1, length(bxpltdat), 1); repmat(c2, length(bxpltdat), 1)];
xx = [ones(length(bxpltdat), 1); ones(length(bxpltdat), 1)*2];
x = [ones(length(bxpltdat), 1) ones(length(bxpltdat), 1)*2];



%fig
figure;
ax = axes()
hold(ax)
for i = 1:size(bxpltdat, 2)
    boxchart(x(:,i), bxpltdat(:, i), 'BoxFaceColor', ccs(i, :), 'LineWidth', 2);
end
hold on;
sz = [];
scatter(xx, scatdat, sz, colrs, 'filled')
plot([xx(1:end/2) xx(end/2+1:end)]', [scatdat(1:end/2) scatdat(end/2+1:end)]','--k')
ylabel('Average PAC strength')
xlabel('Accuracy')
legend({'Accurate', 'Non Accurate'}, 'Location', 'southwest')
title('PAC strength')
% ylim([-10 40])
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');


% p
% [h p ci stat] = ttest(comocorr2)
