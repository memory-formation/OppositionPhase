%% quick PAC
addpath('/media/ludovico/DATA/iEEG_Ludo/Scripts/PaperScripts/Review')
clear
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/PAC')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses')
ft_defaults;
Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles';
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
config.recfrom      = 2;
config.artdeftype   = 'complete';
config.regressors   = 'Accuracy';
smoothby            = 1;
config.day          = 1;
event               = [50] ;
timeint             = [0 2.5];
config.n_iter       = 1000;
phaseint            = 4:1:12;   %freqs for phases of interest
ampint              = 30:5:140; %freqs for amplitude of interes
highfrint           = ampint;
byacc               = 'all'; %select all trials, accurate trials, or nona ccurate trials ('all', 'acc', 'nacc')
como                = 'yes'; %show comodulogram
config.norm         = 'norm'; %normalize each trial over mean of trials after filtering ('no', 'norm')
foi                 = 'no'; 
config.shuffle      = 'LS'; %'TS' time shuffle 'LS' label shuffle
config.nbins        = 18; %number of bins
config.keeptrials   = 'no'; %keep trials in data or average over trials, defaut = 'no'.
config.MI           = 'MVL'; % both choose modulation index, 'MVL, 'DKL', 'both'
config.output       = config.MI; %output of function
config.binned       = 'yes'; %bin data
outputorig          = config.output;
config.equalize     = 'no'; %equalize trials
redoPAC             = 1; %redo PAC analysis, 0 to load instead saved file, PAC is done if there is no file
defaultschansubj; %defaults subjects
switch config.ROI
    case 'Hippocampus'
        roi = [];
    case 'middletemporal'
        roi = '_MT';
end
switch byacc
    case {'no', 'all'}
        acc = 'all';
    case'acc'
        acc = 'acc';
    case'nacc'
        acc ='nacc';
end
switch config.shuffle
    case 'TS'
        shuf = '_TS';
    case 'LS'
        shuf = [];
end

%% load comodulogram and surrogates
filename = sprintf('PAC_como_avg_%s_day%d_%s_%s_%s%s%s', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi, shuf);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);
load(filesave)

lp = length(phaseint);
lc = size(comodulogram, 2);
ld = 1+lc-lp;
comodulogram = comodulogram(:, [ld:end], :);

filename = sprintf('PAC_surr_avg_%s_day%d_%s_%s_%s%s%s.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi, shuf);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);
load(filesave)
lp = length(phaseint);
lc = size(surrogates, 3);
ld = 1+lc-lp;
surrogates = surrogates(:, :, [ld:end], :);



%% average for figure
clear comn surn
comn = comodulogram;
surn = squeeze(mean(surrogates, 2));
% comn(:, 1, : ) = [];
% surn(:, 1, :) = [];
clear comf
for subj = 1:numel(subjc)
    comf(subj, :, :) = (comodulogram (subj, :, :)- surn(subj, :, :))./std(surn(subj, :, :));
end
surr_m = squeeze(mean(surrogates, 2));
avgcomo = squeeze(mean(comf));





%% t scoring 
%demean data before tscoring
alldata = [];
alldata(:, 1, :, :) = comodulogram;
alldata = [alldata surrogates];

sizemat = (size(avgcomo, 1)*size(avgcomo, 2)*numel(subjc)*1001);

como_n = alldata;
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

[clust tcl] = findclust(tvalsexp, 0.025);

for n = 1:1000
    [clustss tcls] = findclust(squeeze(tvalssurr(n, :, :)), 0.025);
    if isempty(tcls) == 1
        tcls = 0;
    end
    tclsm(n) = tcls(1);
end

%find clusters that resist surrogate correction
tsurrs = sort(tclsm);
for t=1:length(tcl)
    [val idx] = min(abs(tsurrs-tcl(t)));
    ptsort(t) = 1-idx/1000;
end
clustpm = clust;
sigclust = avgcomo;
clustsig = zeros(size(avgcomo));
for i= 1:max(clustpm, [], 'all')
    clustnum = i;
    a = find(clustpm == i);
    if ptsort(i) <0.05
        cond = clustpm == clustnum;
        sc = sigclust.*cond;
        [rowos{i}  colos{i}] = find(abs(sc) > 0);
        clustsig(cond) = 1;
    else
        sc = zeros(size(sigclust));
    end
end
mask = zeros(size(clustsig));
cond = clustsig>0;
mask(cond) = true;


figure;set(gcf,'Position', [0 0 900 700])
contourf(phaseint, ampint, tvalsexp',40,'linecolor','none')
set(gca,'clim',[-3 3])
hold on;
contour(phaseint, ampint, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
colormap('parula')
title('Map of T values')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');


figure('units','normalized','outerposition',[0 0 0.5 0.9])
histogram(tclsm, 50)
hold on;
plot([max(tcl) max(tcl)],get(gca,'ylim')/2,'m-p','linewi',4,'markersize',16);
legend({'Distribution of cluster sizes of exp vs individual surrogates', 'T max of exp vs mean surrogates'})
xlabel('Tmax of clusters')
ylabel('Count')
ylim([0 80])
xmin = (min(tclsm, [], 'all')-min(tclsm, [], 'all')/5);
maxval = max([max(tcl) max(tclsm, [], 'all')]);
xmax= (maxval+min(tclsm, [], 'all')/5);
xlim([xmin xmax])
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
ptsort

cond = mask>0;
tsum = sum(tvalsexp(cond));
tmax = max(tvalsexp(cond));
fprintf('\n tsum = %.2f, tmax = %.2f, p =%.2f\n', tsum, tmax, ptsort(1))