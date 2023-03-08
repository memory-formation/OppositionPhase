clear
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath ('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
event               = [10 11 12 13];
config.day          = 1;
config.recfrom      = 2;
smoothby            = 1;
config.artdeftype   = 'complete';
timeint             = [-0.5 2.5];
config.equalize     = 'no';
byacc               = 'no';
config.keeptrials   = 'no';
config.regressors   = 'Accuracy';
config.contrast     = 'absolute';
freqs               = 'diff';
phaseint            = 2:1:12;
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
AllDat_st = AllDat;

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
    end
end

rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205');
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119')
%     b = 1;
%     figure;
for i = 1:numel(subjc)
    for img = 1:numel(event)
        ERP{i, img}.label            = {'ERP'};
    end
end


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

switch config.equalize
    case'yes'
        for subj = 1:numel(subjc)
            [AllDat_acc{subj} AllDat_nacc{subj}] = equalize_tr(AllDat_acc{subj}, AllDat_nacc{subj});
        end
end


%% ERP

for subj  = 1:numel(subjc)
    for img = 1:numel(event)
        cfg                             = [];
        cfg.keeptrials                  = config.keeptrials;
        cfg.baseline                    = [-0.5 0];
        cfg.lpfilter                    = 'yes';
        cfg.preproc.lpfreq              = 20;
        cfg.latency                     = [-2 4];
        ERP{subj, img}                  = ft_timelockanalysis(cfg, AllDat{subj, img});
    end
end

for subj = 1:numel(subjc) 
    for img = 1:numel(event) 
        config.fs = 1000;
        config.startend = [-2 4];
        ERP2fr{subj, img} = fieldtripize(ERP{subj, img}.avg, config);
    end
end

cfg = [];
cfg.method = 'mtmconvol';
cfg.output = 'pow';
cfg.keeptrials = 'no';
cfg.taper = 'hanning';
cfg.foi = phaseint;
cfg.t_ftimwin = 5./cfg.foi;
cfg.toi = timeint(1):0.05:timeint(2);
cfg.latency = [0 2.5];
for img = 1:numel(event)
    for subj = 1:numel(subjc)
        LFA{subj, img} = ft_freqanalysis(cfg, ERP2fr{subj, img});
        
        %                 config.foi                  = 'high';
        %                 HFA{subj, img}              = TFA(config)
    end
end

rmpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20191119');

for subj = 1:numel(subjc)
    for img = 1:numel(event)
        LFA{subj, img}.label        = {'TFA'};
   
        cfg                 = [];
        cfg.baselinetype    = 'db';
        cfg.baseline        = [-0.5 0];
        LFA_b{subj, img}              = ft_freqbaseline(cfg, LFA{subj, img});
    
    end
end

cfg =[];

LFA_avg                   = ft_freqgrandaverage(cfg, LFA_b{:, :});



figure;
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 14;
ax.FontWeight = 'bold';
% cfg = rmfield(cfg, 'zlim')
cfg = [];
% cfg.zlim                    = [-25 25];
%          cfg.baseline = [-0.5 0];
%          cfg.baselinetype = 'db';
ft_singleplotTFR(cfg, LFA_avg)
title('TFA or the ERP')
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);