%% instructions and explanations
% This script was created by Ludovico Saint Amour di Chanaz the 16-03-2022
% to study opposition of phase between two conditions. opposition of phase
% has already been studied in PACOI with Diego-Lonzano's method but that
% only takes into account angles and not amplitude.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  Usage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for more information about how the whole script works and the assumption
% it is based on and the references of interest type
% help MOVI_help
% settings of this script are commented below. The only things that need to
% change across conditions are the settings scepcified in the Settings section.

%% Settings

clear
redoMOVI = 1;
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
addpath('/media/ludovico/DATA/iEEG_Ludo/SimToolbox')
addpath('/media/ludovico/DATA/iEEG_Ludo/Scripts/PaperScripts/Review');
addpath('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Dependent_Scripts');
addpath '/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses';
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
config.unimodality  = 'yes';
event1              = [10 11 12 13];    %eventvalues of the event: 10 11 12 13 = images 1 2 3 4
%50 is recall, 24 is offset
event2              = [50];             %eventvalue of the second dataset same codes as event1.
%It can be the same event in case of comparing accurate and non accurate trials
day1                = 1;                %day of when the eventvalue takes place, it can be 1 or 2 for both days
day2                = 1;
config.recfrom      = 1;                %take accuracy from day 2 or accuracy from day 1
phaseint            = [4:1:12];            %phase of interest
ampofint            = [30:5:140];        %amplitude of interest
ampint              = ampofint;
modint              = phaseint;
phaseofint          = phaseint;
acc1                = 'all' ;            % takes all trials, only accurate ones or non accurate ones.
acc2                = 'all'  ;           % same as acc 1, options are 'all', 'acc' 'nacc'
config.norm         = 'norm'   ;         %'no', 'norm'
tint                = [0 2.5];          %latency of interest
config.artdeftype   = 'complete';       %type of artefact detection wanted.
config.regressors   = 'Accuracy';       %how the regressors are going to be extracted
config.keeptrials   = 'no';
config.output       = 'corrected';
config.MI           = 'MVL';
byacc               = 'no';
event               = max([numel(event1) numel(event2)]); %if there is a for image loop event can be used
config.n_iter       = 1000;
%Chans of interest
config.equalize     = 'no'    ;         %'no' to have an equal number of trials in both conditions
config.peak         = 'yes';
defaultschansubj;
timeint             = tint;
config.day          = day1;
config.normamp      ='no';
clustMethod         = 'tscore';
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
ev1 = mat2str(event1);
ev2 = mat2str(event2);
tfpize = [-2 4];
%% get data
GetPacoiData;


%% filter data for both conditions
config.latency = timeint;
config.lowfreq = phaseint;
config.highfreq = ampofint;
% switch config.unimodality
%     case 'yes'
%         unidir = [];
%     case'no'
%         unidir = 'non_uni';
% end

filename= sprintf('MOVI_como_day%d_%d_%s_%s_%s_%s_%s_%s%s_%s_%dHz.mat', day1, day2,...
    mat2str(event1), acc1, mat2str(event2), acc2, method, config.norm, roi, clustMethod, phaseint(1));
pacfiles = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/PAC';
filesave = fullfile(pacfiles, filename);


%% load pac and find cluster for each condition

GetClusts;
clusttype = 'common';


for subj = 1:numel(subjc)
    data = AllDat1_cltr{subj};
    fprintf('doing patient %d dataset 1 \n', subj)
    config.output = 'MI';
    [phase1{subj} amp1{subj}] = GetPhaseAmp(data, config);
    data = AllDat2_cltr{subj};
    fprintf('doing patient %d dataset 2 \n', subj)
    [phase2{subj} amp2{subj}] = GetPhaseAmp(data, config);
end


%% Bin data separately then avg over freqs of clusts

clear amp1_s amp2_s phase1_s phase2_s
clear comoclust1 comoclust2
config.modify = 'no';
config.keeptrials = 'no';
config.nbins = 18;
config.output = method;
coMOVI = [];
ampbin1 = zeros(numel(subjc), length(r1), config.nbins);
ampbin2 = zeros(numel(subjc), length(r2), config.nbins);
tic
for subj = 1:numel(subjc)
    showprogress(subj, numel(subjc))
    for fr= 1:length(r1)
        rhf = c1(fr);
        clf = r1(fr);
        amp1_s = amp1{subj}(:, rhf, :);
        phase1_s = phase1{subj}(:, clf, :);
        ampbin1(subj, fr, :) = Binning(amp1_s, phase1_s, config);
    end
    for fr = 1:length(r2)
        rhf = c2(fr);
        clf = r2(fr);
        amp2_s = amp2{subj}(:, rhf, :);
        phase2_s = phase2{subj}(:, clf, :);
        ampbin2(subj, fr, :) = Binning(amp2_s, phase2_s, config);
    end
    ampbin1_m(subj, 1, :) = mean(ampbin1(subj, :, :), 2);
    ampbin2_m(subj, 1, :) = mean(ampbin2(subj, :, :), 2);
    ampdiff(subj, 1, :) = DiffBins(ampbin1_m(subj, 1, :), ampbin2_m(subj, 1, :));
    switch config.output
        case'MOVI'
            coMOVI(subj) = Compute_MVL(ampdiff(subj, 1, :), config);
        case {'DKL', 'JSD'}
            tmp1 = squeeze(ampbin1_m(subj, 1, :));
            tmp2 = squeeze(ampbin2_m(subj, 1, :));
            coMOVI(subj) = ComputeKLD(tmp1, tmp2);
    end
end
AB1 = ampbin1;
AB2 = ampbin2;
toc
filename = sprintf('MOVI_BC_%s_%s_day%d_%s_%s_day%d_Clust_%s%s%s_%s_%dHz.mat'...
    , ev1, acc1, day1, ev2, acc2, day2, clusttype, roi, method, clustMethod, phaseint(1));

path2savefile = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MOVI_BC';
filesave = fullfile(path2savefile, filename);

if ~exist(filesave) || redoMOVI == 1
    
    %% do sme for surr for every iteration. Only keep MVL value all the rest reset
    clear amp1_s amp2_s phase1_s phase2_s
    clear comoclust1 comoclust2
    config.modify = 'no';
    config.keeptrials = 'no';
    config.nbins = 18;
    config.output = method;
    surrMOVI = zeros(1, config.n_iter);
    for n = 1:config.n_iter
        showprogress(n, config.n_iter)
        ampbin1 = zeros(numel(subjc), length(r1), config.nbins);
        ampbin2 = zeros(numel(subjc), length(r2), config.nbins);
        
        for subj = 1:numel(subjc)
            rand1 = randperm(length(amp1{subj}(:, 1, 1)));
            rand2 = randperm(length(amp2{subj}(:, 1, 1)));
            amp1_r = amp1{subj}(rand1, :, :);
            amp2_r = amp2{subj}(rand2, :, :);
            for fr= 1:length(r1)
                rhf = c1(fr);
                clf = r1(fr);
                amp1_s = amp1_r(:, rhf, :);
                phase1_s = phase1{subj}(:, clf, :);
                ampbin1(subj, fr, :) = Binning(amp1_s, phase1_s, config);
            end
            for fr = 1:length(r2)
                rhf = c2(fr);
                clf = r2(fr);
                amp2_s = amp2_r(:, rhf, :);
                phase2_s = phase2{subj}(:, clf, :);
                ampbin2(subj, fr, :) = Binning(amp2_s, phase2_s, config);
            end
            ampbin1_m(subj, 1, :) = mean(ampbin1(subj, :, :), 2);
            ampbin2_m(subj, 1, :) = mean(ampbin2(subj, :, :), 2);
            ampdiff(subj, 1, :) = DiffBins(ampbin1_m(subj, :, :), ampbin2_m(subj, :, :));
            switch config.output
                case 'MOVI'
                     surrMOVI(subj, n) = Compute_MVL(ampdiff(subj, :, :), config);
                case {'DKL', 'JSD'}
                    tmp1 = squeeze(ampbin1_m(subj, 1, :));
                    tmp2 = squeeze(ampbin2_m(subj, 1, :));
                    surrMOVI(subj, n) = ComputeKLD(tmp1, tmp2);
            end
        end
    end
else
    load(filesave)
end

%% plot bar for both experimental conditions
ampz_avg1 = squeeze(mean(AB1, 2));
ampz_avg2 = squeeze(mean(AB2, 2));
config.r_type = 'no';
[ampz_avg1 ampz_avg2] = RealignBins(ampz_avg1, ampz_avg2, config);

amp_ovsubj1 = smoothbin(squeeze(mean(ampz_avg1, 1)), 3);
amp_ovsubj2 = smoothbin(squeeze(mean(ampz_avg2, 1)), 3);

amp1_se = std(ampz_avg1, 1)./sqrt(numel(subjc));
amp1_eh =  amp1_se;
amp1_el =  - amp1_se;

amp2_se = std(ampz_avg2, 1)./sqrt(numel(subjc));
amp2_eh =  amp1_se;
amp2_el =  -amp1_se;

P_E_s = linspace(-pi, pi ,18);

% 
% 
% 
% 
% figure('Units', 'normalized', 'Position', [0 0 0.7 0.7])
% b1 = bar(P_E_s(1:end), amp_ovsubj1, 'FaceColor', 'k', 'EdgeColor', 'k', 'LineWidth', 2);
% hold on;
% set(gca,'xlim',[P_E_s(1) P_E_s(end)]);
% b1.FaceAlpha = 0.3;
% hold on;
% b2 = bar(P_E_s(1:end), amp_ovsubj2, 'FaceColor', 'r', 'EdgeColor', 'r', 'LineWidth', 2);
% er1 = errorbar(P_E_s, amp_ovsubj1, amp1_el, amp1_eh, 'Color', 'k', 'LineWidth', 2);
% er1.LineStyle = 'none';
% er2 = errorbar(P_E_s, amp_ovsubj2, amp2_el, amp2_eh, 'Color', 'r', 'LineWidth', 2);
% er2.LineStyle = 'none';
% b2.FaceAlpha = 0.3;
% xlabel('Phase (rad)')
% ylabel(sprintf('Hippocampus \n Amplitude (z)'))
% yline(0, 'linewidth', 3)
% legend(leg1, leg2)
% title(sprintf('Modulation for significant PAC clusters'))
% ax = gca;
% ax.TitleFontSizeMultiplier = 1.5;
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
% set(gcf, 'renderer', 'Painters')


%% polar plots
ampz_avg1 = squeeze(mean(AB1, 2));
ampz_avg2 = squeeze(mean(AB2, 2));
ampz_avg1 = squeeze(mean(AB1, 2));
ampz_avg2 = squeeze(mean(AB2, 2));
config.r_type = 'no';
[ampz_avg1 ampz_avg2] = RealignBins(ampz_avg1, ampz_avg2, config);
ampz_avg1 = zscore(ampz_avg1, [], 'all')+1;
ampz_avg2 = zscore(ampz_avg2, [], 'all')+1;
ampz_avg1 = (ampz_avg1)./2;
ampz_avg2 = (ampz_avg2)./2;

PolarFigs;
PolarFigs_pat;

ampz_avg1 = squeeze(mean(AB1, 2));
ampz_avg2 = squeeze(mean(AB2, 2));
config.r_type = 'no';
[ampz_avg1 ampz_avg2] = RealignBins(ampz_avg1, ampz_avg2, config);

% for subj = 1:numel(subjc)
%     ampz_avg1(subj, :) = zscore(ampz_avg1(subj, :));
%     ampz_avg2(subj, :) = zscore(ampz_avg2(subj, :));
% end

ampz_avg1 = zscore(ampz_avg1, [], 'all');
ampz_avg2 = zscore(ampz_avg2, [], 'all');

amp_ovsubj1 = smoothbin(squeeze(mean(ampz_avg1, 1)), 3);
amp_ovsubj2 = smoothbin(squeeze(mean(ampz_avg2, 1)), 3);

amp1_se = std(ampz_avg1, 1)./sqrt(numel(subjc));
amp1_eh =  amp1_se;
amp1_el =  - amp1_se;

amp2_se = std(ampz_avg2, 1)./sqrt(numel(subjc));
amp2_eh =  amp1_se;
amp2_el =  -amp1_se;


figure('Units', 'normalized', 'Position', [0 0 0.5 0.7])
clear lineProps
lineProps.width = 3;
lineProps.col{1} =  [0 0.4 0.7];
lineProps.transparent = 0.6;
set(gca, 'FontWeight', 'bold', 'Fontsize', 14)
mseb(P_E_s, amp_ovsubj1, amp1_se, lineProps, 0.5)
hold on;
lineProps.width = 3;
lineProps.col{1} = [0.6 0.07 0.2];
lineProps.transparent = 0.6;
set(gca, 'FontWeight', 'bold', 'Fontsize', 14)
mseb(P_E_s, amp_ovsubj2, amp2_se, lineProps, 0.5)
xlim([P_E_s(1) P_E_s(end)])
ylim([-1 1]) % change if not zscored
xlabel('Phase (rad)')
ylabel(sprintf('Hippocampus \n Amplitude (z)'))
legend(leg1, leg2)
title(sprintf('Modulation for significant PAC clusters'))
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white')
set(gcf, 'renderer', 'Painters')



%% plot surr distrib of MVL values and exp value
coMOVI_m = mean(coMOVI);
surrMOVI_m = mean(surrMOVI);
figure('Units', 'normalized', 'Position', [0 0 0.5 0.7])
histogram(surrMOVI_m,50);
hold on
plot([coMOVI_m coMOVI_m],get(gca,'ylim')/2,'m-p','linewi',4,'markersize',16);
legend({'histogram of permuted MOVI values';'observed MOVI value'})
xlabel('MVL of MOVI distribution')
ylabel('Count')
ylim([0 80])
xmin = (min(surrMOVI_m, [], 'all')-min(surrMOVI_m, [], 'all')/5);
maxval = max([max(coMOVI_m) max(surrMOVI_m, [], 'all')]);
xmax= (maxval+min(surrMOVI_m, [], 'all')/5);
xlim([xmin xmax])
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')

%% stats
[tval, degfree, pval] = CrawfordHowell(mean(coMOVI), mean(surrMOVI));
% Modul_all_pats;

fprintf('P-value for Crawford-Howell Test : %f , tval = %f \n', pval, tval)

% save values:

%% fig across patients
ampz_avg1 = squeeze(mean(AB1, 2));
ampz_avg2 = squeeze(mean(AB2, 2));
config.r_type = 'mean_pos';
% config.figbin='yes';
[ampz_avg1 ampz_avg2] = RealignBins(ampz_avg1, ampz_avg2, config);


clear ampz1_z ampz2_z
for subj = 1:numel(subjc)
    ampz1_z(subj, :) = zscore(ampz_avg1(subj, :));
    ampz2_z(subj, :) = zscore(ampz_avg2(subj, :));
end
% for subj = 1:numel(subjc)
%     ampz1_z(subj, :) = smoothbin(ampz1_z(subj, :), 3);
%     ampz2_z(subj, :) = smoothbin(ampz2_z(subj, :), 3);
% end

ampz1_z = [ampz1_z ampz1_z];
ampz2_z = [ampz2_z ampz2_z];


figure('Units', 'normalized', 'Position', [0 0 0.5 0.7])
subplot(121) 
imagesc(ampz1_z)
xticks([1 36])
xticklabels({'0' '720'})
xlabel('Angle')
ylabel('Subjects')
colorbar()
colormap('parula')
caxis([-2 2])
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
title(sprintf('%s', leg1))
subplot(122)
imagesc(ampz2_z)
xticks([1 36])
xticklabels({'0', '720'})
xlabel('Angle')
ylabel('Subjects')
colorbar()
colormap('parula')
caxis([-2 2])
title(sprintf('%s', leg2))
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')

% plot(squeeze(phase1{1, 1}(1, :, :)))


subj = 8;
clear ampbin1 ampbin2
config.keeptrials = 'yes';
    showprogress(subj, numel(subjc))
    for fr= 1:length(r1)
        rhf = c1(fr);
        clf = r1(fr);
        amp1_s = amp1{subj}(:, rhf, :);
        phase1_s = phase1{subj}(:, clf, :);
        ampbin1(1, fr, :, :) = Binning(amp1_s, phase1_s, config);
    end
    for fr = 1:length(r2)
        rhf = c2(fr);
        clf = r2(fr);
        amp2_s = amp2{subj}(:, rhf, :);
        phase2_s = phase2{subj}(:, clf, :);
        ampbin2(1, fr, :, :) = Binning(amp2_s, phase2_s, config);
    end


ampbin1_avg = squeeze(mean(ampbin1, 2));
ampbin1s = squeeze(ampbin1_avg(:, :));

ampbin2_avg = squeeze(mean(ampbin2, 2));
ampbin2s = squeeze(ampbin2_avg(:, :));

ampbin1s = ampbin1s-1/18;
ampbin2s = ampbin2s-1/18;

ampz_avg1 = squeeze(ampbin1s);
ampz_avg2 = squeeze(ampbin2s);
% config.r_type = 'no';
% % config.figbin='yes';
% [ampz_avg1 ampz_avg2] = RealignBins(ampz_avg1, ampz_avg2, config);
% for subj = 1:numel(subjc)
%     ampz_avg1(subj, :) = smoothbin(ampz_avg1(subj, :), 3);
%     ampz_avg2(subj, :) = smoothbin(ampz_avg2(subj, :), 3);
% end

clear ampz1_z ampz2_z
for trl = 1: size(ampz_avg1, 1)
    ampz1_z(trl, :) = zscore(smoothbin(ampz_avg1(trl, :), 3));
end
   for trl = 1: size(ampz_avg2, 1)
    ampz2_z(trl, :) = zscore(smoothbin(ampz_avg2(trl, :), 3));
end


ampz1_z = [ampz1_z ampz1_z];
ampz2_z = [ampz2_z ampz2_z];


figure('Units', 'normalized', 'Position', [0 0 0.5 0.7])
subplot(121) 
imagesc(ampz1_z)
xticks([1 36])
xticklabels({'0' '720'})
xlabel('Angle')
ylabel('Subjects')
colorbar()
colormap('parula')
caxis([-2 2])
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
title(sprintf('%s', leg1))
subplot(122)
imagesc(ampz2_z)
xticks([1 36])
xticklabels({'0', '720'})
xlabel('Angle')
ylabel('Subjects')
colorbar()
colormap('parula')
% caxis([-2 2])
title(sprintf('%s', leg2))
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')

SMO = squeeze(mean(surrMOVI));
vM = mean(coMOVI);
zM = (vM-mean(SMO))./std(SMO);
SmoS = sort(SMO);
[val idx] = min(abs(SmoS-vM));
pM = 1-idx/length(SMO);
fprintf('\n P-Value for zscoring and sorting : %f , zval = %f \n', pM, zM)

save(filesave, 'coMOVI', 'surrMOVI'); 