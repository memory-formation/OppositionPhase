%Script for time frequency analysis
clear
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/PAC')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses')
ft_defaults;
Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles'
config.artdefredo   = 0; %redo artifact detection with 1, load files with 0 
config.ROI          = 'Hippocampus'; %region of interest
config.recfrom      = 2; %recall from day 2 or day 1
config.artdeftype   = 'complete'; %reject completely trials that have artifacts
config.regressors   = 'Accuracy'; %type of regressors (see GetRegressors.m)
smoothby            = 1; %smoothing parameter
config.day          = 2; %day for data
event               = [50]; %number of event (see README.txt)
byacc               = 'all'; %selects all trials, accurate trials or nona ccurate trials, 'all', 'acc', 'nacc' 
timeint             = [-0.5 2.5];%time of interest (in seconds)
config.equalize     = 'no'; %equalize trials to have the same number of trials in 2 conditions if compared
config.contrast     = 'db'; % type of baseline correction: choices are: 'db', 'absolute',  'relative'
freqs               = 'diff';
defaultschansubj;
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

GetPACData;


%% TFA
for subj = 1:numel(subjc)
    config.dataset              = AllDatImg{subj};
    
    config.baselinetype         = 'normal';
    config.TFRdata              = 'yes';
    config.keeptrials           = 'no';
    config.contrast             = config.contrast;
    config.foi                  = 'med';
    config.toi                  = timeint(1):0.05:timeint(2);
    config.smoothby             = smoothby;
    LFA{subj}                   = TFA(config)
    config.foi                  = 'high';
    HFA{subj}                   = TFA(config)
end

%% corrrect by baseline

cfg =[];
HFA_avg                   = ft_freqgrandaverage(cfg, HFA{:, :});
LFA_avg                   = ft_freqgrandaverage(cfg, LFA{:, :});
% cfg = [];
% cfg.baseline = [-0.5 0];
% cfg.baselinetype = 'db';
% %         HFA_avg = ft_freqbaseline(cfg, HFA_avg);
% LFA_avg = ft_freqbaseline(cfg, LFA_avg);



%% average over pats
% prepare data
cfg = [];
clear HFA_dat LFA_dat
for subj = 1:numel(subjc)
%     HFA_avgimg{subj} =  ft_freqgrandaverage(cfg, HFA{subj, :});
%     LFA_avgimg{subj} =  ft_freqgrandaverage(cfg, LFA{subj, :});
    %             HFA_avgimg{subj} = ft_freqbaseline(cfg, HFA_avgimg{subj});
    %             LFA_avgimg{subj} = ft_freqbaseline(cfg, LFA_avgimg{subj});
    HFA_dat(:, :, subj) = squeeze(HFA{subj}.powspctrm);
    LFA_dat(:, :, subj) = squeeze(LFA{subj}.powspctrm);
    
end


mat3dacc =[];
mat3dnacc = [];
mat3dacc = HFA_dat;
mat3dnacc = zeros(size(mat3dacc));


[clustpmHF tclustHF tperHF pclustHF, resH] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'two');

sigclust = zeros(size(clustpmHF));
for i= 1:max(clustpmHF, [], 'all')
    if pclustHF(i) < 0.05
        cond = clustpmHF == i;
        sigclust(cond) = squeeze(HFA_avg.powspctrm(cond));
    end
end
maskHFA = false(size(sigclust));
cond = abs(sigclust) > 0;
maskHFA(cond) = true;

mat3dacc =[];
mat3dnacc = [];
mat3dacc = LFA_dat;
mat3dnacc = zeros(size(mat3dacc));


[clustpmLF tclustLF tper pclustLF, resL] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'two');

sigclust = zeros(size(clustpmLF));
for i= 1:max(max(clustpmLF))
    if pclustLF(i) < 0.05
        cond = clustpmLF == i;
        sigclust(cond) = squeeze(LFA_avg.powspctrm(cond));
    end
end
maskLFA = false(size(sigclust));
cond = abs(sigclust) > 0;
maskLFA(cond) = true;

%change fieldtrip toolbox because the newer ones don't allow subplots 
rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');


cmap = [ones(1, 256)' ones(1, 256)' linspace(1, 0, 256)']; %white to yellow
cmap = [cmap; ones(1, 256)' linspace(1, 0, 256)' zeros(1, 256)']; %yellow to red
cmap = [cmap; linspace(1, 0, 256)' zeros(1, 256)' zeros(1, 256)']; %red to black
cmap = [cmap; zeros(1, 256)' zeros(1, 256)' linspace(0, 1, 256)']; %black to blue
cmap = [cmap; zeros(1, 256)' linspace(0, 1, 256)' ones(1, 256)']; %blue to cyan
cmap = [cmap; linspace(0, 1, 256)' ones(1, 256)' ones(1, 256)']; %cyan to white
cmap = flip(cmap);



figure('units','normalized','outerposition',[0 0 0.5 0.7])
cfg                         = [];
cfg.zlim                    = [-1 1];
%         cfg.maskstyle               = 'opacity';
%         cfg.baseline = [-0.5 0];
cfg.xlim = [timeint(1) timeint(2)];
subplot(2, 1, 1)
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
ft_singleplotTFR(cfg, HFA_avg)
% colormap(cmap)
hold on;
% contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
title('Time frequency analysis for freq 30-160Hz')
xlabel('Time (s)')
ylabel('Spectral Power (dB)')
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);

subplot(2, 1, 2)
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
% cfg = rmfield(cfg, 'zlim')
cfg.zlim                    = [-1 1];
ft_singleplotTFR(cfg, LFA_avg)
% colormap(cmap)
hold on;
% contour(LFA_avg.time, LFA_avg.freq, maskLFA, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Time (s)')
ylabel('Spectral Power (dB)')
title('Time frequency analysis for freq 3-29Hz')
set(gcf, 'color', 'white');
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);


%% concat 

TFRAll = appendTFR(config, HFA_avg, LFA_avg);
figure('units','normalized','outerposition',[0 0 0.5 0.7])
cfg                         = [];
cfg.zlim                    = [-1 1];
%         cfg.maskstyle               = 'opacity';
%         cfg.baseline = [-0.5 0];

cfg.xlim = [timeint(1) timeint(2)];
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
cfg.zlim = [-1.4 1.4];
% ft_singleplotTFR(cfg, HFA_avg)
contourf(HFA_avg.time, HFA_avg.freq, squeeze(HFA_avg.powspctrm),40,'linecolor','none')
set(gca, 'clim', [-1.4 1.4])
colormap(cmap)
hold on;
% contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
title('Time frequency analysis')
xlabel('Time (s)')
ylabel('Spectral Power (dB)')
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
ch = colorbar;
set(ch, 'FontSize', 16)
set(gcf, 'color', 'white');

%% TVALS

TFRAll = appendTFR(config, HFA_avg, LFA_avg);
figure('units','normalized','outerposition',[0 0 0.5 0.7])
cfg                         = [];
cfg.zlim                    = [-1 1];
%         cfg.maskstyle               = 'opacity';
%         cfg.baseline = [-0.5 0];

cfg.xlim = [timeint(1) timeint(2)];
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
% cfg.zlim = [- 1.4];
% ft_singleplotTFR(cfg, HFA_avg)
contourf(HFA_avg.time, HFA_avg.freq, squeeze(resH),40,'linecolor','none')
set(gca, 'clim', [-3 3])
hold on;
contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
colormap('parula')
hold on;
% contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
title('T-values')
xlabel('Time (s)')
ylabel('Spectral Power (dB)')
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
ch = colorbar;
set(ch, 'FontSize', 16)
set(gcf, 'color', 'white');



cfg                         = [];
cfg.zlim                    = [-2 2];
[cc rr] = rect(numel(subjc))
figure('units','normalized','outerposition',[0 0 0.5 0.7])
for subj = 1:numel(subjc)
    subplot(cc, rr, subj)
    TFRsubj = appendTFR(config, HFA{subj}, LFA{subj});
    contourf(HFA_avg.time, HFA_avg.freq, squeeze(HFA{subj}.powspctrm),40,'linecolor','none')
set(gca, 'clim', [-2 2])
    colormap(cmap)
    title(sprintf('Pat %d', subjc(subj)));
end

pclustHF
tclustHF
max(resH, [], 'all')