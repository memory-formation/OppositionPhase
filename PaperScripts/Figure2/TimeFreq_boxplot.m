% see TimeFreqAnalysis.m for explanations of defaults and presets
clear
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath ('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
event               = [10 11];
config.day          = 1;
config.recfrom      = 2;
smoothby            = 1;
config.artdeftype   = 'complete';
timeint             = [-0.5 2.5];
config.equalize     = 'no';
byacc               = 'no';
config.keeptrials   = 'no';
config.regressors   = 'Accuracy';
config.contrast     = 'db';
freqs               = 'diff';
defaultschansubj;
switch config.ROI
    case 'Hippocampus'
        roi = [];
    case 'middletemporal'
        roi = '_MT';
end

Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles';
for img = 1:numel(event)
    config.eventvalue = event(img);
    filemat                     = sprintf('Data_complete_day%d_%d%s.mat',config.day, config.eventvalue, roi);
    datafile                    = fullfile(Datafiles, filemat);
    clear data
    load(datafile)
    
    for subj  = 1:numel(subjc)
        
        AllDat{subj, img}           = data{subj};
        AllDat_st{subj, img}= AllDat{subj, img};
        AllDat_st{subj, img} = rmfield(AllDat_st{subj, img}, 'trial');
        for sti = 1:length(AllDat{subj, img}.trial)
            AllDat_st{subj, img}.trial{sti}    = ft_preproc_standardize(AllDat{subj, img}.trial{sti});
        end
    end
end


%% Import R files
for subj  = 1:numel(subjc)
    config.eventvalue           = event(1);
    config.Subject              = subjc(subj);
    reg{subj}                   = GetRegressors(config);
    subj= subj+1;
end


%% make accuracy as a binary variable
for subj = 1:numel(subjc)
    reg{subj}.Accuracy(reg{subj}.Accuracy < 2, 1) = 0;
    reg{subj}.Accuracy(reg{subj}.Accuracy > 1, 1) = 1;
end

matreg = {};
for img= 1:numel(event)
    for i = 1:numel(subjc)
        matreg{i, img}(:, 2) = reg{i}.Trials;
        matreg{i, img}(:, 3) = reg{i}.Accuracy;
        matreg{i, img}(:, 4) = reg{i}.Engagement;
        matreg{i, img}(:, 1) = ismember(matreg{i, img}(:, 2), AllDat{i, img}.trialinfo(:, 2));
        %eliminate rows that are not present in the trialinfo due to
        %artifact rejection
        matreg{i, img}(matreg{i, img}(:, 1) == 0, :) = [];
        cond = ismember(AllDat{i, img}.trialinfo(:, 2), matreg{i, img}(:, 2));
        [~, idx] = sort(matreg{i, img}(:, 2));
        matreg{i, img} = matreg{i, img}(idx, :);
        matreg{i, img}(1:length(matreg{i, img}(:, 2)), 1) = reg{i}.Subject(1, 1);
        matreg{i, img}(:, 2) = AllDat{i, img}.trialinfo(cond, 4);
        tr_acc{i, img} = matreg{i, img}(matreg{i, img}(:, 3) == 1, 2);
        tr_nacc{i, img} = matreg{i, img}(matreg{i, img}(:, 3) == 0, 2);
        tr{i, img} = matreg{i, img}(:, 2);
    end
end



%     b = 1;
%     figure;


%% separate by accuracy

clear AllDat_acc AllDat_nacc
for img = 1:numel(event)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr_acc{subj, img};
        AllDat_acc{subj, img} = ft_preprocessing(cfg, AllDat_st{subj, img});
        cfg.trials = tr_nacc{subj, img};
        AllDat_nacc{subj, img} = ft_preprocessing(cfg, AllDat_st{subj, img});
    end
end

for img = 1:numel(event)
    for subj = 1:numel(subjc)
        cfg= [];
        cfg.trials = tr{subj, img};
        AllDat{subj, img} = ft_preprocessing(cfg, AllDat{subj, img});
    end
end



addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');


% config = rmfield(config, 'trials');
%% TFA
for img = 1:numel(event)
    for subj = 1:numel(subjc)
        
        config.dataset              = AllDat{subj, img};
        config.baselinetype         = 'normal';
        config.TFRdata              = 'yes';
        config.keeptrials           = 'no';
        config.contrast             = config.contrast;
        config.foi                  = 'theta';
        config.toi                  = timeint(1):0.05:timeint(2);
        config.smoothby             = smoothby;
        LFA{subj, img}              = TFA(config)
        config.foi                  = 'high';
        HFA{subj, img}              = TFA(config)
    end
end
rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');

for j = 1:numel(subjc)
    for img = 1:numel(event)
        LFA{j, img}.label  = {'TFA'};
        HFA{j, img}.label ={'TFA'};
    end
end


%% TFA acc_nacc
for img = 1:numel(event)
    for subj = 1:numel(subjc)
        
        
        config.baselinetype         = 'normal';
        config.TFRdata              = 'yes';
        config.keeptrials           = 'no';
        config.contrast             = config.contrast;
        config.toi                  = timeint(1):0.05:timeint(2);
        config.smoothby             = smoothby;
         config.foi                 = 'theta';
        config.dataset              = AllDat_acc{subj, img};
        LFA_acc{subj, img}          = TFA(config)
        config.foi                  = 'high';
        HFA_acc{subj, img}          = TFA(config)
        config.dataset              = AllDat_nacc{subj, img};
        config.foi                  = 'theta';
        LFA_nacc{subj, img}         = TFA(config)
        config.foi                  = 'high';
        HFA_nacc{subj, img}         = TFA(config)
    end
end
rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');

for j = 1:numel(subjc)
    for img = 1:numel(event)
        LFA_acc{j, img}.label  = {'TFA'};
        HFA_acc{j, img}.label ={'TFA'};
        LFA_nacc{j, img}.label  = {'TFA'};
        HFA_nacc{j, img}.label ={'TFA'};
    end
end



%% grandaverage for all trials
cfg =[];
HFA_avg                   = ft_freqgrandaverage(cfg, HFA{:, :});
LFA_avg                   = ft_freqgrandaverage(cfg, LFA{:, :});

cfg = [];
clear HFA_dat LFA_dat
for subj = 1:numel(subjc)
    HFA_avgimg{subj} =  ft_freqgrandaverage(cfg, HFA{subj, :});
    LFA_avgimg{subj} =  ft_freqgrandaverage(cfg, LFA{subj, :});
    %             HFA_avgimg{subj} = ft_freqbaseline(cfg, HFA_avgimg{subj});
    %             LFA_avgimg{subj} = ft_freqbaseline(cfg, LFA_avgimg{subj});
    HFA_dat(:, :, subj) = squeeze(HFA_avgimg{subj}.powspctrm);
    LFA_dat(:, :, subj) = squeeze(LFA_avgimg{subj}.powspctrm);
    
end

%% test
mat3dacc =[];
mat3dnacc = [];
mat3dacc = HFA_dat;
mat3dnacc = zeros(size(mat3dacc));


[clustpmHF tclustHF tper pclustHF, resH] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'two');

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
maskHFA_all = maskHFA;
sigclustHFA_all = sigclust;

mat3dacc =[];
mat3dnacc = [];
mat3dacc = LFA_dat;
mat3dnacc = zeros(size(mat3dacc));


[clustpmLF tclustLF tper pclustLF, resL] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'left');

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
maskLFA_all = maskLFA;
sigclustLFA_all = sigclust;

rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');

%% figures
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
contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
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
contour(LFA_avg.time, LFA_avg.freq, maskLFA, 1, 'linecolor', 'k', 'LineWidth', 2)
xlabel('Time (s)')
ylabel('Spectral Power (dB)')
title('Time frequency analysis for freq 3-29Hz')
set(gcf, 'color', 'white');
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);

%% each image
figure('units','normalized','outerposition',[0 0 0.5 0.7])
for img = 1:numel(event)
    
    cfg =[];
    HFA_avg                   = ft_freqgrandaverage(cfg, HFA{:, img});
    LFA_avg                   = ft_freqgrandaverage(cfg, LFA{:, img});
    cfg = [];
    clear HFA_dat LFA_dat
    for subj = 1:numel(subjc)
        
        HFA_dat(:, :, subj) = squeeze(HFA{subj, img}.powspctrm);
        LFA_dat(:, :, subj) = squeeze(LFA{subj, img}.powspctrm);
        
    end
    
    %% test
    mat3dacc =[];
    mat3dnacc = [];
    mat3dacc = HFA_dat;
    mat3dnacc = zeros(size(mat3dacc));
    
    
    [clustpmHF tclustHF tper pclustHF, resH] = clusterperm2D(mat3dacc, mat3dnacc, 1000, 'within', 'two');
    
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
    sigclustHFA_img{img} = sigclust;
    
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
    sigclustLFA_img{img} = sigclust;
    
    rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
    addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');
    
    %% figures
    cmap = [ones(1, 256)' ones(1, 256)' linspace(1, 0, 256)']; %white to yellow
    cmap = [cmap; ones(1, 256)' linspace(1, 0, 256)' zeros(1, 256)']; %yellow to red
    cmap = [cmap; linspace(1, 0, 256)' zeros(1, 256)' zeros(1, 256)']; %red to black
    cmap = [cmap; zeros(1, 256)' zeros(1, 256)' linspace(0, 1, 256)']; %black to blue
    cmap = [cmap; zeros(1, 256)' linspace(0, 1, 256)' ones(1, 256)']; %blue to cyan
    cmap = [cmap; linspace(0, 1, 256)' ones(1, 256)' ones(1, 256)']; %cyan to white
    cmap = flip(cmap);
    
    
    

    cfg                         = [];
    cfg.zlim                    = [-1 1];
    %         cfg.maskstyle               = 'opacity';
    %         cfg.baseline = [-0.5 0];
    cfg.xlim = [timeint(1) timeint(2)];
    subplot(2, 4, img)
    ax = gca;
    ax.TitleFontSizeMultiplier = 1.5;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    ft_singleplotTFR(cfg, HFA_avg)
    % colormap(cmap)
    hold on;
    contour(HFA_avg.time, HFA_avg.freq, maskHFA, 1, 'linecolor', 'k', 'LineWidth', 2)
    title('Time frequency analysis for freq 30-160Hz')
    xlabel('Time (s)')
    ylabel('Spectral Power (dB)')
    set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
    
    subplot(2, 4, img+4)
    ax = gca;
    ax.TitleFontSizeMultiplier = 1.5;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    % cfg = rmfield(cfg, 'zlim')
    cfg.zlim                    = [-1 1];
    ft_singleplotTFR(cfg, LFA_avg)
    % colormap(cmap)
    hold on;
    contour(LFA_avg.time, LFA_avg.freq, maskLFA, 1, 'linecolor', 'k', 'LineWidth', 2)
    xlabel('Time (s)')
    ylabel('Spectral Power (dB)')
    title('Time frequency analysis for freq 3-29Hz')
    set(gcf, 'color', 'white');
    set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
end

for subj = 1:numel(subjc)
    for img= 1:numel(event)
        datHFA = squeeze(HFA{subj, img}.powspctrm);
        datLFA = squeeze(LFA{subj, img}.powspctrm);
        bxpldatHFA(subj, img) = mean(datHFA(maskHFA_all == 1), 'all');
        bxpldatLFA(subj, img) = mean(datLFA(maskLFA_all == 1), 'all');
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


%% by accuracy

for subj = 1:numel(subjc)
    for img= 1:numel(event)
        datHFA_acc = squeeze(HFA_acc{subj, img}.powspctrm);
        datLFA_acc = squeeze(LFA_acc{subj, img}.powspctrm);
        bxpldatHFA_acc(subj, img) = mean(datHFA_acc(maskHFA_all == 1), 'all');
        bxpldatLFA_acc(subj, img) = mean(datLFA_acc(maskLFA_all == 1), 'all');
        datHFA_nacc = squeeze(HFA_nacc{subj, img}.powspctrm);
        datLFA_nacc = squeeze(LFA_nacc{subj, img}.powspctrm);
        bxpldatHFA_nacc(subj, img) = mean(datHFA_nacc(maskHFA_all == 1), 'all');
        bxpldatLFA_nacc(subj, img) = mean(datLFA_nacc(maskLFA_all == 1), 'all');
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
% for img = 1:size(bxpldatHFA_acc, 2)
%     plot([xx((img*10-9):10*img) xx*2]', [scatdatHFA_acc((img*10-9):10*img) scatdatHFA_nacc((img*10-9):10*img)]','--k')
%     hold on;
% end
ylabel('Average TFA strength (dB)')
xlabel('Accuracy')
% legend({'HFA', 'Theta'}, 'Location', 'southwest')
title('TFA strength')
% ylim([-10 40])
% 
% subplot(122)
% % ax = axes();
% % hold(ax)
%  hold on;
% for i = 1:size(bxpldatHFA_nacc, 2)
%     boxchart(x(:,i), bxpldatHFA_nacc(:, i), 'BoxFaceColor', ccs(2, :), 'LineWidth', 2);
% end
% hold on;
% for i = 1:size(bxpldatHFA_nacc, 2)
%     boxchart(x(:,i), bxpldatLFA_nacc(:, i), 'BoxFaceColor', ccs(1, :), 'LineWidth', 2);
% end
% hold on;
% sz = [];
% scatter(xx, scatdatHFA_nacc, sz, c2, 'filled')
% hold on;
% sz = [];
% scatter(xx, scatdatLFA_nacc, sz, c1, 'filled')
% % for img = 1:numel(event)-1
% %     plot([xx((img*10-9):10*img) xx(img*10+1:img*10+10)]', [scatdatHFA((img*10-9):10*img) scatdatHFA(img*10+1:img*10+10)]','--k')
% %     hold on;
% % end
% ylabel('Average TFA strength (dB)')
% xlabel('Image number')
% % legend({'HFA', 'Theta'}, 'Location', 'southwest')
% title('TFA strength')
% % ylim([-10 40])



ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');


