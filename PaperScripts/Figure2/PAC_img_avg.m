% phase amplitude coupling
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
event               = [12 13];
timeint             = [0 2.5];
config.n_iter       = 1000;
phaseint            = 4:1:12;   %freqs for phases of interest
ampint              = 30:5:140; %freqs for amplitude of interes
highfrint           = ampint;
byacc               = 'acc'; %select all trials, accurate trials, or nona ccurate trials ('all', 'acc', 'nacc')
como                = 'yes'; %show comodulogram
config.norm         = 'norm'; %normalizeeach trial over mean of trials after filtering ('no', 'norm')
foi                 = 'no'; 
config.nbins        = 18; %number of bins
config.keeptrials   = 'no'; %keep trials in data or average over trials, defaut = 'no'.
config.MI           = 'MVL'; % both choose modulation index, 'MVL, 'DKL', 'both'
config.output       = config.MI; %output of function
config.binned       = 'yes'; %bin data
outputorig          = config.output;
config.equalize     = 'no'; %equalize trials
redoPAC             = 0; %redo PAC analysis, 0 to load instead saved file, PAC is done if there is no file
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

%get data
GetPACData;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FilterData


filename = sprintf('PAC_como_avg_%s_day%d_%s_%s_%s%s.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/PAC';
filesave = fullfile(FolderPAC, filename);


config.latency = timeint;
config.lowfreq = phaseint;
config.highfreq = ampint;

%filter
clear comodulogram surrogates
for subj = 1:numel(subjc)
    data = AllDatImg{subj};
    fprintf('\n Filtering patient %d \n', subj)
    config.output = 'MI';
    [phase_r{subj} amp_r{subj}] = GetPhaseAmp(data, config);
end


%do PAC for experimental conditions
if ~exist(filesave) || redoPAC == 1
    
    for subj = 1:numel(subjc)
        config.output = config.MI;
        fprintf('\n Computing PAC for patient %d \n', subj)
        config.modify = 'normbin';
        comodulogram(subj, :, :) = PAC_avg(phase_r{subj}, amp_r{subj}, config);
    end
    
    save(filesave, 'comodulogram')
else
    load(filesave)
end

filename = sprintf('PAC_surr_avg_%s_day%d_%s_%s_%s%s.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/PAC';
filesave = fullfile(FolderPAC, filename);
if ~exist(filesave) || redoPAC == 1
    
    for subj=1:numel(subjc)
        config.modify = 'normbin';
        surrogates(subj, :, :) = PAC_surr(phase_r{subj}, amp_r{subj}, config);
    end
    save(filesave, 'surrogates')
else
    load(filesave)
end

for subj = 1:numel(subjc)
    comn(subj, :, :) = comodulogram(subj, :, :)./sum(comodulogram(subj, :, :), 'all');
    surn(subj, :, :) = surrogates(subj, :, :)./sum(surrogates(subj, :, :), 'all');
end
avgsurr = squeeze(mean(surn));
%
avgcomo = squeeze(mean(comn));
%                 switch config.output
%         %                     case'entropy'
%         %                         for i = 1:size(avgcomo, 1)
%         %                             avgcomo(i, :) = zscore(avgcomo(i, :));
%         %                         end
%         %                 end
%
%         fig = figure;
%         contourf(config.lowfreq, config.highfreq, avgcomo',40,'linecolor','none')
% %         set(gca,'clim',[0 0.0005])
%         xlabel('Frequency for phase')
%         ylabel('frequency for amplitude')
%         colorbar
%         title('Map of phase-amplitude coupling')
%         ax = gca;
%         ax.TitleFontSizeMultiplier = 1.5;
%         ax.FontSize = 14;
%         ax.FontWeight = 'bold';
%         set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
%
% %
%
%          fig = figure;
%         contourf(config.lowfreq, config.highfreq, avgsurr',40,'linecolor','none')
% %         set(gca,'clim',[-.001 .001])
%         xlabel('Frequency for phase')
%         ylabel('frequency for amplitude')
%         colorbar
%         title('Map of phase-amplitude coupling SUrr')
%         ax = gca;
%         ax.TitleFontSizeMultiplier = 1.5;
%         ax.FontSize = 14;
%         ax.FontWeight = 'bold';
%         set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);


% %         control individual patients if need be
config.lowfreq = phaseint;
% comodulogram(7, :, :) = [];
% surrogates(7, :, :) = [];

switch byacc
    case{'all', 'no', 'acc', 'nacc'}
        mat3dacc =[];
        mat3dnacc = [];
        mat3dacc = permute(comodulogram, [2, 3, 1]);
        %         mat3dnacc = zeros(size(mat3dacc));
        mat3dnacc = permute(surrogates, [2, 3, 1]);
    case'yes'
        mat3dacc =[];
        mat3dnacc = [];
        mat3dacc = permute(comodulogram_acc, [2, 3, 1]);
        mat3dnacc = permute(comodulogram_nacc, [2, 3, 1]);
end

[clustpm tclust tper pclust res] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'right');

sigclust = zeros(size(clustpm));
for i= 1:max(max(clustpm))
    if pclust(i) < 0.05
        cond = clustpm == i;
        switch byacc
            case {'all', 'no', 'acc', 'nacc'}
                sigclust(cond) = avgcomo(cond);
            case 'yes'
                sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
        end
    end
end

mask = false(size(sigclust));
cond = sigclust > 0;
mask(cond) = true;

stdsurr = squeeze(std(surn, 1))';
avgg = avgcomo'-avgsurr';
clear aa1r
aa1r = avgg./stdsurr;


fig = figure;
contourf(config.lowfreq, config.highfreq, aa1r)%,40,'linecolor','none')
set(gca,'clim',[-10 10])
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


% figure;
% clf
% contourf(config.lowfreq, config.highfreq, sigclust') %,40,'linecolor','none')
% % set(gca,'clim',[-0.0005 0.0005])
% xlabel('Frequency for phase')
% ylabel('frequency for amplitude')
% colorbar
% title('Map of phase-amplitude coupling')
% ax = gca;
% ax.TitleFontSizeMultiplier = 1.5;
% ax.FontSize = 14;
% ax.FontWeight = 'bold';
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
% %
% figure;
% clf
% contourf(config.lowfreq, config.highfreq, clustpm') %,40,'linecolor','none')
% % set(gca,'clim',[0 4])
% xlabel('Frequency for phase')
% ylabel('frequency for amplitude')
% colorbar
% title('Map of phase-amplitude coupling')
% ax = gca;
% ax.TitleFontSizeMultiplier = 1.5;
% ax.FontSize = 14;
% ax.FontWeight = 'bold';
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
%
%
% figure;
% clf
% imagesc(config.lowfreq, config.highfreq, res') %,40,'linecolor','none')
% set(gca,'clim',[-2.5 2.5])
% hold on;
% contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 3)
% xlabel('Frequency for phase')
% ylabel('frequency for amplitude')
% colorbar
% title('Map of T vlaues permutaiton test')
% ax = gca;
% ax.TitleFontSizeMultiplier = 1.5;
% ax.FontSize = 14;
% ax.FontWeight = 'bold';
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
% set(gca, 'YDir', 'normal')

fig = figure;
contourf(config.lowfreq, config.highfreq, res')
set(gca,'clim',[-3 3])
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


figure;
[rr cc]= rect(size(comn, 1));
for subj = 1:numel(subjc)
    subplot(rr, cc, subj)
    contourf(config.lowfreq, config.highfreq, (squeeze(comn(subj, :, :))'-squeeze(surn(subj, :, :))'),40,'linecolor','none')
    set(gca, 'clim', [-0.01 0.01])
    hold on;
    contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
    colorbar
    
end

%
% switch nonuni
%     case 'yes'
%         addpath('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses')
%         for i= 1:max(clustpm, [], 'all')
%             if pclust(i) < 0.05
%                 clustnum = i;
%                 Non_Uni;
%             end
%         end
%     case 'no'
%         fprintf('Non Running Non Uniformity, only Comodulogram')
% end
if isempty(pclust) == 1
    p = 1;
else
    p = pclust(1);
end
fprintf('event %s day %d %s trials, n_iter =  %d\n pval1 = %f \n',...
    mat2str(event), config.day, acc, config.n_iter, p)