function Timefreq = TFA (config)

%% explanations
%{
function created by Ludovico Saint Amour di Chanaz the 07/05/2019
config gives the basic configuratios needed

for this function the essential configurations are the Subject number and
the specification of a dataset (with removed artifacts)

non optional config:
config.dataset  = dataset from the workspace

optional but conditional
config.Subject = double (subject number)(optional if baselinetype = 'normal')
config.Mode    = string ('Day1', 'Day2') optional if baselinetype = 'normal')

optionals (with default)
config.baselinetype = string, 'custom', 'normal', default = 'normal'
config.structure: string ('Hippocampus', 'Amygdala', 'LT', 'Scalp')
default = 'Hippocampus'
config.antpost: (for Hippocampus) string('ant', 'med', 'post', 'all'),
default = 'all'
config.toi = matrix,  default = -0.5:0.05:3.5
config.prestim = double (prestim for preprocessing) default = 2
config.poststim = double , default = 5
config.method = method ('wavelet', 'mtmconvol' ), default = 'mtmconvol'
config.TFRdata = string ('yes', 'no') default = 'no'
config.foi      = string ('low' (1-20Hz), 'med' (1-40)
'high' (41-60)), default = 'all' (2-80)

 
%}

%% default values
TFA_defaults;
data_clean = config.dataset;
%% Core values
Home            = 'C:\Users\Ludovico\Documents\MATLAB';
Results         = 'Results';
if isfield (config, 'Subject') > 0
    Subj            = sprintf('Subject_%d', config.Subject);
end
OrderFold       = 'Order_mat';
EEGDataMatFold  = 'EEGDataMat';
structure       = config.structure;

%% for custom basline
if config.eventvalue == 50
    config.baselinetype = 'normal';
end
switch config.baselinetype
    case 'custom'
        %% unused because function
        
        %         if isfield (config, 'accuracy') ==0
        %             config.accuracy = [];
        %         end
        %                 filename        = sprintf ('bl_%s_%s_%s_%s_%s_%s%s%d.mat', structure, config.Mode, config.method, config.antpost, config.keeptrials, config.foi, config.accuracy, config.Subject);
        %                 path2file       = fullfile (Home, Results, filename);
        %                 path2save       = sprintf('%s', path2file);
        %                 if config.eventvalue == 10
        %                     if exist(path2save) == 2
        %                         load(path2save);
        %                     elseif exist(path2save) < 1
        %
        %                         data_clean_bl           = data_clean
        %                         cfg                     = [];
        %                         cfg.output              = 'pow'
        %                         cfg.method              = config.method;
        %                         cfg.taper               = config.taper;
        %                         cfg.foi                 = foi;
        %                         cfg.keeptrials          = config.keeptrials;
        %             %           cfg.t_ftimwin           = ones(length(cfg.foi), 1).*0.5;
        %                         cfg.t_ftimwin           = timwin;
        %                         cfg.toi                 = config.toi;
        %             %             cfg.channel             = data_clean_bl.label(1,1);
        %                         switch config.foi
        %                             case {'high', 'staresina'}
        %                                 cfg.tapsmofrq   = tapsmofrq;
        %                         end
        %
        %                         TFRhann                 = ft_freqanalysis(cfg, data_clean_bl);
        %
        %             %% manual baseline correction
        %                         cfg                             = [];
        %                         switch config.foi
        %                             case 'high'
        %                                 cfg.latency             = [-0.5 0];
        %                             otherwise
        %                                 cfg.latency             = [-0.5 0];
        %                         end
        %                         cfg.avgovertime         = 'yes';
        %                          switch config.keeptrials
        %                              case'no'
        %                                  cfg.avgoverrpt          = 'yes';
        %                          end
        %                         bl                      = ft_selectdata(cfg, TFRhann);
        %                         save(path2save, 'bl')
        
        %                       end
        %                 else
        %                     if exist(path2save) == 2
        %                         load(path2save);
        %                     else
        %                         error('eventvalue must be either 10 or 50')
        %                     end
        %                 end
        %Now we have a bl file that is a vector and can be adapted to any matrix
        %size by a repmat
        
        %% do the actual time freq analysis
        bl                      = createbl(config)
        cfg                     = [];
        cfg.output              = 'pow'
        cfg.method              = config.method;
        cfg.taper               = config.taper;
        cfg.foi                 = foi;
        cfg.keeptrials          = config.keeptrials;
        %        cfg.t_ftimwin           = ones(length(cfg.foi), 1).*0.5;
        cfg.width               = width;
        cfg.t_ftimwin           = timwin;
        cfg.toi                 = config.toi;
        %         cfg.channel             = bl.label(1,1);
        
        switch config.foi
            case {'high', 'staresina', 'sthigh', 'superhigh'}
                cfg.tapsmofrq   = tapsmofrq;
        end
        
        TFRhann                 = ft_freqanalysis(cfg, data_clean);
        %% match trials with bl.
        bl.label                 = TFRhann.label
        switch config.keeptrials
            case 'yes'
                bl.Order(:, 2)                                          = ismember (bl.Order(:, 1), TFRhann.trialinfo(:, 2));
                TFRhann.trialinfo(:, 4)                                 = ismember(TFRhann.trialinfo(:, 2), bl.Order(:, 1));
                bl.powspctrm(bl.Order(:, 2) == 0, :, :)                 = [];
                TFRhann.powspctrm(TFRhann.trialinfo(:, 4) ==0, :, :, :) = [];
                bl.Order(bl.Order(:, 2) == 0, :)                        = [];
                TFRhann.trialinfo(TFRhann.trialinfo(:, 4) == 0, :)      = [];
                % repeat powerspectrum over time and trials
                bl.powspctrm    = permute(repmat(bl.powspctrm, [1 1 1 length(TFRhann.time)]),[1 2 3 4]);
                bl.dimord       = TFRhann.dimord;
                bl.time         = TFRhann.time;
            case'no'
                bl.powspctrm    = permute(repmat(bl.powspctrm, [1 1 length(TFRhann.time)]),[1 2 3]);
                bl.dimord       = TFRhann.dimord;
                bl.time         = TFRhann.time;
        end
        %         cfg=[];
        %         cfg.parameter           = 'powspctrm';
        %         cfg.operation           = 'log10';
        %         TFHhann                 = ft_math(cfg, TFRhann)
        %         cfg=[];
        %         cfg.parameter           = 'powspctrm';
        %         cfg.operation           = 'log10';
        %         bl                      = ft_math(cfg, bl)
        cfg=[];
        cfg.parameter                   = 'powspctrm';
        switch config.contrast
            case'relative'
                cfg.operation                   = 'x1./x2'
                TFRhann_vs_baseline             = ft_math(cfg, TFRhann, bl);
            case'db'
                cfg.operation                   = 'x1./x2'
                TFRhann_vs_baseline             = ft_math(cfg, TFRhann, bl);
                TFRhann_vs_baseline.powspctrm   = 10*log10(TFRhann_vs_baseline.powspctrm)
        end
        switch config.keeptrials
            case 'yes'
                TFRhann_vs_baseline.Order       = TFRhann.trialinfo;
        end
        
        %% figure
        
        %         cfg                     = [];
        %         cfg.baseline            = [-0.5  0];
        %         cfg.baselinetype        ='db'
        %         cfg.zlim                = [0 2];
        switch config.TFRdata
            case 'yes'
                Timefreq = TFRhann_vs_baseline;
            case 'no'
                Timefreq = ft_singleplotTFR(cfg, TFRhann_vs_baseline);
        end
    case 'normal'
        cfg                     = [];
        cfg.output              = 'pow';
        cfg.method              = config.method;
        cfg.taper               = config.taper;
        cfg.foi                 = foi;
        cfg.width               = width;
        %        cfg.t_ftimwin           = ones(length(cfg.foi), 1).*0.5;
        cfg.t_ftimwin           = timwin;
        if isfield(config, 'trials') > 0
            cfg.trials = config.trials;
        end
        cfg.toi                 = config.toi;
        %         cfg.channel             = config.channel;
        switch config.method
            case 'mtmconvol'
                switch config.foi
                    case {'high', 'staresina', 'sthigh', 'superhigh'}
                        cfg.tapsmofrq   = tapsmofrq;
                end
        end
        
        
        
        switch config.TFRdata
            case 'yes'
                
                cfg.keeptrials          = config.keeptrials;
                
                TFRhann_vs_baseline     = ft_freqanalysis(cfg, data_clean);
                cfg =[];
                cfg.baseline = [-0.5 0];
                cfg.baselinetype        = config.contrast;
                switch cfg.baselinetype
                    case 'no'
                        fprintf('no baseline applied')
                        Timefreq                = TFRhann_vs_baseline
                        if config.smoothby > 0
                            for trl = 1:size(TFRhann_vs_baseline.powspctrm, 1)
                                TFRhann_vs_baseline.powspctrm(trl, 1, :, :)    = imgaussfilt(squeeze(squeeze(TFRhann_vs_baseline.powspctrm(trl, 1, :, :))), config.smoothby);
                            end
                        end
                    otherwise
                        switch config.keeptrials 
                            case 'yes'
                                if config.smoothby > 0
                                    for trl = 1:size(TFRhann_vs_baseline.powspctrm, 1)
                                        TFRhann_vs_baseline.powspctrm(trl, 1, :, :)    = imgaussfilt(squeeze(squeeze(TFRhann_vs_baseline.powspctrm(trl, 1, :, :))), config.smoothby);
                                    end
                                end
                            case 'no'
                                if config.smoothby > 0
                                    TFRhann_vs_baseline.powspctrm(1, :, :)    = imgaussfilt(squeeze(squeeze(TFRhann_vs_baseline.powspctrm(1, :, :))), config.smoothby); 
                                end
                        end
                        TFRhann_vs_baseline     = ft_freqbaseline(cfg, TFRhann_vs_baseline);
                        Timefreq                = TFRhann_vs_baseline;
                end
                
            case 'no'
                cfg.channel = config.channel;
                TFRhann_vs_baseline     = ft_freqanalysis(cfg, data_clean);
                cfg                     = [];
                cfg.keeptrials          = config.keeptrials;
                cfg.baseline            = [-0.5 0];
                cfg.zlim                = [-3 3];
                cfg.baselinetype        = 'db';
                cfg.maskstyle           = 'saturation';
                Timefreq                = ft_singleplotTFR(cfg, TFRhann_vs_baseline);
        end
end
end
