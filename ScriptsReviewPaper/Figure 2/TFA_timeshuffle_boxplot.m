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
config.artdefredo   = 0; %redo artifact detection with 1, load files with 0 
config.ROI          = 'Hippocampus'; %region of interest
config.recfrom      = 2; %recall from day 2 or day 1
config.artdeftype   = 'complete'; %reject completely trials that have artifacts
config.regressors   = 'Accuracy'; %type of regressors (see GetRegressors.m)
config.smoothby     = 1; %smoothing parameter
config.day          = 1; %day for data
phaseint            = 30:5:140;
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
filename = sprintf('TFA_exp__day%d%s%s.mat', config.day, mat2str(event), roi);
folder = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/TFA';
expdatfile = fullfile(folder, filename);

if ~exist(expdatfile)
    %% TFA
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.keeptrials = 'yes';
    cfg.foi = phaseint;
    cfg.toi = timeint(1):0.05:timeint(2);
    cfg.foi             = 30:5:140;
    cfg.t_ftimwin          = ones(1,size(cfg.foi,2)).*0.40;
    config.taper    = 'dpss';
    cfg.tapsmofrq   = 10;
    
    
    
    for subj = 1:numel(subjc)
        for img = 1:numel(event)
            HFA{subj, img} = ft_freqanalysis(cfg, AllDat{subj, img});
            for trl = 1:size(HFA{subj, img}.powspctrm, 1)
                HFA{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(HFA{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
        end
        %                 config.foi                  = 'high';
        %                 HFA{subj, img}              = TFA(config)
    end
    
    cfg = [];
    cfg.method          = 'mtmconvol';
    cfg.output          = 'pow';
    cfg.keeptrials      = 'yes';
    cfg.foi             = 2:1:12;
    cfg.t_ftimwin       = 5./cfg.foi;
    cfg.taper        = 'hanning';
    cfg.toi = timeint(1):0.05:timeint(2);
    
    for subj = 1:numel(subjc)
        for img = 1:numel(event)
            LFA{subj, img} = ft_freqanalysis(cfg, AllDat{subj, img});
            for trl = 1:size(LFA{subj, img}.powspctrm, 1)
                LFA{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(LFA{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
        end
        %                 config.foi                  = 'high';
        %                 HFA{subj, img}              = TFA(config)
    end
    
    %% TFA by accuracy
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.keeptrials = 'yes';
    cfg.foi = phaseint;
    cfg.toi = timeint(1):0.05:timeint(2);
    cfg.foi             = 30:5:140;
    cfg.t_ftimwin          = ones(1,size(cfg.foi,2)).*0.40;
    config.taper    = 'dpss';
    cfg.tapsmofrq   = 10;
    
    for subj = 1:numel(subjc)
        for img = 1:numel(event)
            HFA_acc{subj, img} = ft_freqanalysis(cfg, AllDat_acc{subj, img});
            HFA_nacc{subj, img} = ft_freqanalysis(cfg, AllDat_nacc{subj, img});
            for trl = 1:size(HFA_acc{subj, img}.powspctrm, 1)
                HFA_acc{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(HFA_acc{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
            for trl = 1:size(HFA_nacc{subj, img}.powspctrm, 1)
                HFA_nacc{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(HFA_nacc{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
        end
        %                 config.foi                  = 'high';
        %                 HFA{subj, img}              = TFA(config)
    end
    
    cfg = [];
    cfg.method          = 'mtmconvol';
    cfg.output          = 'pow';
    cfg.keeptrials      = 'yes';
    cfg.foi             = 2:1:12;
    cfg.t_ftimwin       = 5./cfg.foi;
    cfg.taper        = 'hanning';
    cfg.toi = timeint(1):0.05:timeint(2);
    
    for subj = 1:numel(subjc)
        for img = 1:numel(event)
            LFA_acc{subj, img} = ft_freqanalysis(cfg, AllDat_acc{subj, img});
            LFA_nacc{subj, img} = ft_freqanalysis(cfg, AllDat_nacc{subj, img});
            for trl = 1:size(LFA_acc{subj, img}.powspctrm, 1)
                LFA_acc{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(LFA_acc{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
            for trl = 1:size(LFA_nacc{subj, img}.powspctrm, 1)
                LFA_nacc{subj, img}.powspctrm(trl, 1, :, :) = imgaussfilt(squeeze(squeeze(LFA_nacc{subj, img}.powspctrm(trl, 1, :, :))), config.smoothby);
            end
        end
        %                 config.foi                  = 'high';
        %                 HFA{subj, img}              = TFA(config)
    end
    
    save(expdatfile, 'HFA', 'LFA', 'HFA_acc', 'HFA_nacc', 'LFA_acc', 'LFA_nacc')
else
    load(expdatfile)
end
%% rename labels
rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');
for j = 1:numel(subjc)
    for img = 1:numel(event)
        LFA{j, img}.label  = {'TFA'};
        HFA{j, img}.label ={'TFA'};
    end
end

for j = 1:numel(subjc)
    for img = 1:numel(event)
        LFA_acc{j, img}.label  = {'TFA'};
        HFA_acc{j, img}.label ={'TFA'};
        LFA_nacc{j, img}.label  = {'TFA'};
        HFA_nacc{j, img}.label ={'TFA'};
    end
end
%% baseline correct for each trial
for subj = 1:numel(subjc)
    for img = 1:numel(event)
        cfg                 = [];
        cfg.baselinetype    = 'db';
        cfg.baseline        = [-0.5 0];
        HFA_b{subj, img}              = ft_freqbaseline(cfg, HFA{subj, img});
        HFA_b_acc{subj, img}          = ft_freqbaseline(cfg, HFA_acc{subj, img});
        HFA_b_nacc{subj, img}         = ft_freqbaseline(cfg, HFA_nacc{subj, img});
    end
end
for subj = 1:numel(subjc)
    for img= 1:numel(event)
        cfg                 = [];
        cfg.baselinetype    = 'absolute';
        cfg.baseline        = [-0.5 0];
        HFA_b{subj, img}          = ft_freqbaseline(cfg, HFA_b{subj, img});
        HFA_b_acc{subj, img}      = ft_freqbaseline(cfg, HFA_b_acc{subj, img});
        HFA_b_nacc{subj, img}     = ft_freqbaseline(cfg, HFA_b_nacc{subj, img});
    end
end

for subj = 1:numel(subjc)
    for img = 1:numel(event)
        cfg                 = [];
        cfg.baselinetype    = 'db';
        cfg.baseline        = [-0.5 0];
        LFA_b{subj, img}              = ft_freqbaseline(cfg, LFA{subj, img});
        LFA_b_acc{subj, img}          = ft_freqbaseline(cfg, LFA_acc{subj, img});
        LFA_b_nacc{subj, img}         = ft_freqbaseline(cfg, LFA_nacc{subj, img});
    end
end
for subj = 1:numel(subjc)
    for img= 1:numel(event)
        cfg                 = [];
        cfg.baselinetype    = 'absolute';
        cfg.baseline        = [-0.5 0];
        LFA_b{subj, img}          = ft_freqbaseline(cfg, LFA_b{subj, img});
        LFA_b_acc{subj, img}      = ft_freqbaseline(cfg, LFA_b_acc{subj, img});
        LFA_b_nacc{subj, img}     = ft_freqbaseline(cfg, LFA_b_nacc{subj, img});
    end
end
%% average over trials
cfg= [];
for subj = 1:numel(subjc)
    for img = 1:numel(event) 
        HFA_a{subj, img} = ft_freqdescriptives(cfg, HFA_b{subj, img});
        HFA_a_acc{subj, img} = ft_freqdescriptives(cfg, HFA_b_acc{subj, img});
        HFA_a_nacc{subj, img} = ft_freqdescriptives(cfg, HFA_b_nacc{subj, img});
        LFA_a{subj, img} = ft_freqdescriptives(cfg, LFA_b{subj, img});
        LFA_a_acc{subj, img} = ft_freqdescriptives(cfg, LFA_b_acc{subj, img});
        LFA_a_nacc{subj, img} = ft_freqdescriptives(cfg, LFA_b_nacc{subj, img});
    end
end

%% average over images and subjects
cfg =[];
HFA_avg                   = ft_freqgrandaverage(cfg, HFA_a{:, :});
LFA_avg                   = ft_freqgrandaverage(cfg, LFA_a{:, :});
HFA_avg_acc                   = ft_freqgrandaverage(cfg, HFA_a_acc{:, :});
LFA_avg_acc                   = ft_freqgrandaverage(cfg, LFA_a_acc{:, :});
HFA_avg_nacc                   = ft_freqgrandaverage(cfg, HFA_a_nacc{:, :});
LFA_avg_nacc                   = ft_freqgrandaverage(cfg, LFA_a_nacc{:, :});

%% average over iamges and extract data
cfg = [];
clear HFA_dat LFA_dat
for subj = 1:numel(subjc)
    HFA_avgimg{subj} =  ft_freqgrandaverage(cfg, HFA_a{subj, :});
    LFA_avgimg{subj} =  ft_freqgrandaverage(cfg, LFA_a{subj, :});
    %             HFA_avgimg{subj} = ft_freqbaseline(cfg, HFA_avgimg{subj});
    %             LFA_avgimg{subj} = ft_freqbaseline(cfg, LFA_avgimg{subj});
    HFA_dat(:, :, subj) = squeeze(HFA_avgimg{subj}.powspctrm);
    LFA_dat(:, :, subj) = squeeze(LFA_avgimg{subj}.powspctrm);
    
end


%% shuffle high freqs
filename = sprintf('SurrHFA_%s%s', mat2str(event), roi);
surrfile = fullfile(folder, filename);

if ~exist(surrfile)
    clear SurrHFA
    npnts = size(HFA_b{1, 1}.time, 2);
    for img = 1:numel(event)
        for subj = 1:numel(subjc)
            cfg = [];
            cfg.latency = [-0.5 2.5];
            HFA_s{subj, img} = ft_selectdata(cfg, HFA{subj, img});
        end
    end
    HFA_ss = HFA_s;
    HFA_ssb = HFA_s;
    
    addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
    rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');
    
    for subj = 1:numel(subjc)
        subj1trial = squeeze(HFA_s{subj}.powspctrm);
        subjc1surr = zeros(1000, size(subj1trial, 1), size(subj1trial, 2), size(subj1trial, 3));
        for img = 1:numel(event)
            for n = 1:1
                showprogress(n, 1)
                
                for trl = 1:size(HFA_s{subj, img}.powspctrm, 1)
                    for fr = 1:size(HFA_s{subj, img}.powspctrm, 3)
                        npnts = size(HFA_s{subj, img}.powspctrm, 4);
                        cutpoint            = randsample(round(npnts/10):round(npnts*.9),1);
                        
                        HFA_ss{subj, img}.powspctrm(trl, 1,  fr, :)= HFA_s{subj, img}.powspctrm...
                            (trl, 1, fr, [cutpoint:end 1:cutpoint-1]);
                    end
                end
                HFA_ssb{subj, img}.label        = {'TFA'};
                cfg                 = [];
                cfg.baselinetype    = 'db';
                cfg.baseline        = [-0.5 0];
                HFA_ssb{subj, img}              = ft_freqbaseline(cfg, HFA_ss{subj, img});
                
                HFA_ssb{subj, img}.label        = {'TFA'};
                cfg                 = [];
                cfg.baselinetype    = 'absolute';
                cfg.baseline        = [-0.5 0];
                HFA_ssb{subj, img}              = ft_freqbaseline(cfg, HFA_ssb{subj, img});
                subjc1surr(n, img, :, :)  = squeeze(mean(HFA_ssb{subj, img}.powspctrm, 1));
            end
        end
        subj1surr_m = squeeze(mean(subjc1surr, [2]));
        SurrHFA(subj, :, :, :) = subj1surr_m;
    end
    save(surrfile, 'SurrHFA');
else
    load(surrfile)
end

%% time shuffled surrogates Low frequencies
filename = sprintf('SurrLFA_%s%s', mat2str(event), roi);
surrfile = fullfile(folder, filename);
if ~exist(surrfile)
    clear SurrLFA
    npnts = size(LFA_b{1, 1}.time, 2);
    for img = 1:numel(event)
        for subj = 1:numel(subjc)
            cfg = [];
            cfg.latency = [-0.5 2.5];
            LFA_s{subj, img} = ft_selectdata(cfg, LFA{subj, img});
        end
    end
    LFA_ss = LFA_s;
    LFA_ssb = LFA_s;
    for subj = 1:numel(subjc)
        subj1trial = squeeze(LFA_s{subj}.powspctrm);
        subjc1surr = zeros(1000, size(subj1trial, 1), size(subj1trial, 2), size(subj1trial, 3));
        for img = 1:numel(event)
            for n = 1:1
                showprogress(n, 1)
                
                for trl = 1:size(LFA_s{subj, img}.powspctrm, 1)
                    for fr = 1:size(LFA_s{subj, img}.powspctrm, 3)
                        npnts = size(LFA_s{subj, img}.powspctrm, 4);
                        cutpoint            = randsample(round(npnts/10):round(npnts*.9),1);
                        
                        LFA_ss{subj, img}.powspctrm(trl, 1,  fr, :)= LFA_s{subj, img}.powspctrm...
                            (trl, 1, fr, [cutpoint:end 1:cutpoint-1]);
                    end
                end
                LFA_ssb{subj, img}.label        = {'TFA'};
                cfg                 = [];
                cfg.baselinetype    = 'db';
                cfg.baseline        = [-0.5 0];
                LFA_ssb{subj, img}              = ft_freqbaseline(cfg, LFA_ss{subj, img});
                
                LFA_ssb{subj, img}.label        = {'TFA'};
                cfg                 = [];
                cfg.baselinetype    = 'absolute';
                cfg.baseline        = [-0.5 0];
                LFA_ssb{subj, img}              = ft_freqbaseline(cfg, LFA_ssb{subj, img});
                subjc1surr(n, img, :, :)  = squeeze(mean(LFA_ssb{subj, img}.powspctrm, 1));
            end
        end
        subj1surr_m = squeeze(mean(subjc1surr, [2]));
        SurrLFA(subj, :, :, :) = subj1surr_m;
    end
    save(surrfile, 'SurrLFA');
else
    load(surrfile);
end
%% map for figs
cmap = [ones(1, 256)' ones(1, 256)' linspace(1, 0, 256)']; %white to yellow
cmap = [cmap; ones(1, 256)' linspace(1, 0, 256)' zeros(1, 256)']; %yellow to red
cmap = [cmap; linspace(1, 0, 256)' zeros(1, 256)' zeros(1, 256)']; %red to black
cmap = [cmap; zeros(1, 256)' zeros(1, 256)' linspace(0, 1, 256)']; %black to blue
cmap = [cmap; zeros(1, 256)' linspace(0, 1, 256)' ones(1, 256)']; %blue to cyan
cmap = [cmap; linspace(0, 1, 256)' ones(1, 256)' ones(1, 256)']; %cyan to white
cmap = flip(cmap);

%% cluster test for figures
mat1= HFA_dat;
mat2 = permute(squeeze(mean(SurrHFA, 2)), [2 3 1]);
[clust, pexpHF, texpHF] = permutest(mat1, mat2, true, 0.05, 1000, true);
clusterHF = zeros(size(squeeze(mean(mat1, 3))));
for i = 1:length(pexpHF)
    if pexpHF(i) < 0.05
        clusterHF(clust{i})=  i;
    end
end
maskHF = zeros(size(clusterHF));
maskHF(clusterHF > 0) = true;

A = mat1;
B = mat2;
[~,~,~,t] = ttest(reshape(A,[size(A,1)*size(A,2),size(A,3)]),reshape(B,[size(B,1)*size(B,2),size(B,3)]),'Dim',2);
t_map2D = reshape(t.tstat,[size(A,1),size(A,2)]);
t_maxH = max(t_map2D(clust{1}));
t_meanH = mean(t_map2D(clust{1}));


figure;set(gcf,'Position', [0 0 900 700])
contourf(timeint(1):0.05:timeint(2),phaseint, t_map2D,40,'linecolor','none')
set(gca,'clim',[-3 3])
hold on;
contour(timeint(1):0.05:timeint(2),phaseint, maskHF, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
% colormap(cmap)
title('TFA')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');

mat1= LFA_dat;
mat2 = permute(squeeze(mean(SurrLFA, 2)), [2 3 1]);
[clust, pexpLF, texpLF] = permutest(mat1, mat2, true, 0.05, 1000, true);
clusterLF = zeros(size(squeeze(mean(mat1, 3))));
for i = 1:length(pexpLF)
    if pexpLF(i) < 0.05
        clusterLF(clust{i})=  i;
    end
end
maskLF = zeros(size(clusterLF));
maskLF(clusterLF > 0) = true;

A = mat1;
B = mat2;
[~,~,~,t] = ttest(reshape(A,[size(A,1)*size(A,2),size(A,3)]),reshape(B,[size(B,1)*size(B,2),size(B,3)]),'Dim',2);
t_map2D = reshape(t.tstat,[size(A,1),size(A,2)]);
t_maxL = max(t_map2D(clust{1}));
t_meanL = mean(t_map2D(clust{1}));


lff = 2:1:12;
figure;set(gcf,'Position', [0 0 900 700])
contourf(timeint(1):0.05:timeint(2),lff, t_map2D,40,'linecolor','none')
set(gca,'clim',[-3 3])
hold on;
contour(timeint(1):0.05:timeint(2),lff, maskLF, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
% colormap(cmap)
title('TFA')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');

figure;set(gcf,'Position', [0 0 900 700])
contourf(timeint(1):0.05:timeint(2),phaseint, squeeze(mean(HFA_dat, 3)),40,'linecolor','none')
set(gca,'clim',[-1 1])
hold on;
contour(timeint(1):0.05:timeint(2),phaseint, maskHF, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
colormap(cmap)
title('TFA')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');

rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');

figure;set(gcf,'Position', [0 0 900 700])
cfg = [];
cfg.zlim                    = [-1 1];
cfg.ylim = [2 12];
cfg.xlim = [0 2.5];
% cfg.baseline = [-0.5 0];
% cfg.baselinetype = 'db';
ft_singleplotTFR(cfg, LFA_avg)
colormap('hot')
% hold on;
% contour(0:0.05:timeint(2),lff, maskLF, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Frequency for phase')
ylabel('frequency for amplitude')
colorbar
% colormap(cmap)
title('TFA')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');

figure;
[r c] = rect(numel(subjc));
for subj = 1:numel(subjc)
    subplot(r, c, subj)
    ax = gca;
    ax.TitleFontSizeMultiplier = 1.5;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    % cfg = rmfield(cfg, 'zlim')
    cfg = [];
    cfg.ylim = [2 12];
    colormap('hot')
    cfg.zlim                    = [-2 2];
    %          cfg.baseline = [-0.5 0];
    %          cfg.baselinetype = 'db';
    ft_singleplotTFR(cfg, LFA_avgimg{subj});
    title(sprintf('patient %d', subj))
end


%% boxplots

for subj = 1:numel(subjc)
    for img= 1:numel(event)
        datHFA = squeeze(HFA_a{subj, img}.powspctrm);
        datLFA = squeeze(LFA_a{subj, img}.powspctrm);
        bxpldatHFA(subj, img) = mean(datHFA(maskHF == 1), 'all');
        bxpldatLFA(subj, img) = mean(datLFA(maskLF == 1), 'all');
    end
end


scatdatHFA_acc = [];
scatdatLFA_acc = [];
for img = 1:numel(event)
    scatdatHFA_acc = [scatdatHFA_acc; bxpldatHFA(:, img)];
    scatdatLFA_acc = [scatdatLFA_acc; bxpldatLFA(:, img)];
end
c1 = [0 0.4470 0.7410];
c2 = [0.8500 0.3250 0.0980];
ccs = [c1; c2];


x = [];
xx= [];

for img = 1:numel(event)
    xx = [xx; ones(length(bxpldatHFA), 1)*img];
    x = [x ones(length(bxpldatHFA), 1)*img];
end


%fig
figure;
ax = axes()
hold(ax)
for i = 1:size(bxpldatHFA, 2)
    boxchart(x(:,i), bxpldatHFA(:, i), 'BoxFaceColor', ccs(2, :), 'LineWidth', 2);
end
hold on;
for i = 1:size(bxpldatHFA, 2)
    boxchart(x(:,i), bxpldatLFA(:, i), 'BoxFaceColor', ccs(1, :), 'LineWidth', 2);
end
hold on;
sz = [];
scatter(xx, scatdatHFA_acc, sz, c2, 'filled')
hold on;
sz = [];
scatter(xx, scatdatLFA_acc, sz, c1, 'filled')
% for img = 1:numel(event)-1
%     plot([xx((img*10-9):10*img) xx(img*10+1:img*10+10)]', [scatdatHFA((img*10-9):10*img) scatdatHFA(img*10+1:img*10+10)]','--k')
%     hold on;
% end
ylabel('Average TFA strength (dB)')
xlabel('Image number')
% legend({'HFA', 'Theta'}, 'Location', 'southwest')
title('TFA strength')
% ylim([-10 40])
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');

%% by acc

for subj = 1:numel(subjc)
    for img= 1:numel(event)
        datHFA_acc = squeeze(HFA_a_acc{subj, img}.powspctrm);
        datLFA_acc = squeeze(LFA_a_acc{subj, img}.powspctrm);
        bxpldatHFA_acc(subj, img) = mean(datHFA_acc(maskHF == 1), 'all');
        bxpldatLFA_acc(subj, img) = mean(datLFA_acc(maskLF == 1), 'all');
        datHFA_nacc = squeeze(HFA_a_nacc{subj, img}.powspctrm);
        datLFA_nacc = squeeze(LFA_a_nacc{subj, img}.powspctrm);
        bxpldatHFA_nacc(subj, img) = mean(datHFA_nacc(maskHF == 1), 'all');
        bxpldatLFA_nacc(subj, img) = mean(datLFA_nacc(maskLF == 1), 'all');
    end
end

bxpldatHFA_acc = mean(bxpldatHFA_acc, 2);
bxpldatHFA_nacc = mean(bxpldatHFA_nacc, 2);

scatdatHFA_acc = [];
scatdatLFA_acc = [];
scatdatHFA_nacc = [];
scatdatLFA_nacc = [];
for img = 1:size(bxpldatHFA_acc, 2)
    scatdatHFA_acc = [scatdatHFA_acc; bxpldatHFA_acc(:, img)];
    scatdatLFA_acc = [scatdatLFA_acc; bxpldatLFA_acc(:, img)];
    scatdatHFA_nacc = [scatdatHFA_nacc; bxpldatHFA_nacc(:, img)];
    scatdatLFA_nacc = [scatdatLFA_nacc; bxpldatLFA_nacc(:, img)];
end
c1 = [0 0.4470 0.7410];
c2 = [0.8500 0.3250 0.0980];
ccs = [c1; c2];


x = [];
xx= [];

for img = 1:size(bxpldatHFA_acc, 2)
    xx = [xx; ones(length(bxpldatHFA), 1)*img];
    x = [x ones(length(bxpldatHFA), 1)*img];
end


%fig
figure;
% subplot(121)
% ax = axes();
% hold(ax)
 hold on;
for i = 1:size(bxpldatHFA_acc, 2)
    boxchart(x(:,i), bxpldatHFA_acc(:, i), 'BoxFaceColor', ccs(1, :), 'LineWidth', 2);
   
end
hold on;
for i = 1:size(bxpldatHFA_acc, 2)
    boxchart(x(:,i)*2, bxpldatHFA_nacc(:, i), 'BoxFaceColor', ccs(2, :), 'LineWidth', 2);
end
hold on;
sz = [];
scatter(xx, scatdatHFA_acc, sz, c1, 'filled')
hold on;
sz = [];
scatter(xx*2, scatdatHFA_nacc, sz, c2, 'filled')
for img = 1:size(bxpldatHFA_acc, 2)
    plot([xx((img*10-9):10*img) xx*2]', [scatdatHFA_acc((img*10-9):10*img) scatdatHFA_nacc((img*10-9):10*img)]','--k')
    hold on;
end
ylabel('Average TFA strength (dB)')
xlabel('Accuracy')
% legend({'HFA', 'Theta'}, 'Location', 'southwest')
title('TFA strength')
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');

[h p ci stat] = ttest(bxpldatHFA_acc, bxpldatHFA_nacc);
% [hL pL ciL statL] = ttest(bxpldatLFA_acc, bxpldatLFA_nacc);

p
stat.tstat
% pL
% t_maxH
% t_maxL
