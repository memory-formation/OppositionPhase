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

%% load dataset
for img = 1:numel(event)
    config.eventvalue = event(img);
    filemat                     = sprintf('Data_complete_day%d_%d%s.mat',config.day, config.eventvalue, roi);
    datafile                    = fullfile(Datafiles, filemat);
    clear data
    load(datafile)
    
    for subj  = 1:numel(subjc)
        
        AllDat{subj, img}           = data{subj};
    end
end

%Organise behavioral data and match it with artifact detected data to match
%trials 
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

%separate by accuracy
clear AllDat_acc AllDat_nacc
for img = 1:numel(event)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr_acc{subj, img};
        AllDat_acc{subj, img} = ft_preprocessing(cfg, AllDat{subj, img});
        cfg.trials = tr_nacc{subj, img};
        AllDat_nacc{subj, img} = ft_preprocessing(cfg, AllDat{subj, img});
    end
end

%clean up trials and select desired ones
for img = 1:numel(event) 
     for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = matreg{subj, img}(:, 2);
        AllDat{subj, img} = ft_preprocessing(cfg, AllDat{subj, img});
     end
end

%Equalize number of trials if necessary to have the same number in 2
%conditions
switch config.equalize
    case'yes'
        for subj = 1:numel(subjc)
            [AllDat_acc{subj} AllDat_nacc{subj}] = equalize_tr(AllDat_acc{subj}, AllDat_nacc{subj});
        end
end

%% put all images data together
for subj= 1:numel(subjc)
    dat{subj} = [];
    for img = 1:numel(event)
        for trl = 1:length(AllDat{subj, img}.trial)
            dat{subj} = [dat{subj}; AllDat{subj, img}.trial{trl}];
        end
    end
end

config.fs = 1000;
config.startend = [-2 4];
for subj = 1:numel(subjc)
    AllDatImg{subj} = fieldtripize(dat{subj}, config);
end

%baseline correct data and extract accuracy
switch byacc
    case 'no'
        cfg = [];
        cfg.keeptrials = 'yes';
        cfg.baseline = [-0.5 0];
        for subj = 1:numel(subjc)
            AllDatImg{subj} = ft_timelockanalysis(cfg, AllDatImg{subj});
            AllDatImg{subj} = fieldtripize(squeeze(AllDatImg{subj}.trial), config);
        end
    case'acc'
        
        for subj= 1:numel(subjc)
            dat{subj} = [];
            for img = 1:numel(event)
                for trl = 1:length(AllDat_acc{subj, img}.trial)
                    dat{subj} = [dat{subj}; AllDat_acc{subj, img}.trial{trl}];
                end
            end
        end
        
        config.fs = 1000;
        config.startend = [-2 4];
        for subj = 1:numel(subjc)
            AllDat_acc{subj} = fieldtripize(dat{subj}, config);
        end
        
        
        cfg = [];
        cfg.keeptrials = 'yes';
        cfg.baseline = [-0.5 0];
        for subj = 1:numel(subjc)
            AllDat_acc{subj} = ft_timelockanalysis(cfg, AllDat_acc{subj});
            AllDatImg{subj} = fieldtripize(squeeze(AllDat_acc{subj}.trial), config);
        end
    case 'nacc'
        
        for subj= 1:numel(subjc)
            dat{subj} = [];
            for img = 1:numel(event)
                for trl = 1:length(AllDat_nacc{subj, img}.trial)
                    dat{subj} = [dat{subj}; AllDat_nacc{subj, img}.trial{trl}];
                end
            end
        end
        
        config.fs = 1000;
        config.startend = [-2 4];
        for subj = 1:numel(subjc)
            AllDat_nacc{subj} = fieldtripize(dat{subj}, config);
        end
        
        
        cfg = [];
        cfg.keeptrials = 'yes';
        cfg.baseline = [-0.5 0];
        for subj = 1:numel(subjc)
            AllDat_nacc{subj} = ft_timelockanalysis(cfg, AllDat_nacc{subj});
            AllDatImg{subj} = fieldtripize(squeeze(AllDat_nacc{subj}.trial), config);
        end
        
    case 'yes'
        for subj= 1:numel(subjc)
            dat{subj} = [];
            for img = 1:numel(event)
                for trl = 1:length(AllDat_acc{subj, img}.trial)
                    dat{subj} = [dat{subj}; AllDat_acc{subj, img}.trial{trl}];
                end
            end
        end
        
        config.fs = 1000;
        config.startend = [-2 4];
        for subj = 1:numel(subjc)
            AllDat_acc{subj} = fieldtripize(dat{subj}, config);
        end
        
        
        cfg = [];
        cfg.keeptrials = 'yes';
        cfg.baseline = [-0.5 0];
        for subj = 1:numel(subjc)
            AllDat_acc{subj} = ft_timelockanalysis(cfg, AllDat_acc{subj});
            AllDat_acc{subj} = fieldtripize(squeeze(AllDat_acc{subj}.trial), config);
        end
        for subj= 1:numel(subjc)
            dat{subj} = [];
            for img = 1:numel(event)
                for trl = 1:length(AllDat_nacc{subj, img}.trial)
                    dat{subj} = [dat{subj}; AllDat_nacc{subj, img}.trial{trl}];
                end
            end
        end
        
        config.fs = 1000;
        config.startend = [-2 4];
        for subj = 1:numel(subjc)
            AllDat_nacc{subj} = fieldtripize(dat{subj}, config);
        end
        
        
        cfg = [];
        cfg.keeptrials = 'yes';
        cfg.baseline = [-0.5 0];
        for subj = 1:numel(subjc)
            AllDat_nacc{subj} = ft_timelockanalysis(cfg, AllDat_nacc{subj});
            AllDat_nacc{subj} = fieldtripize(squeeze(AllDat_nacc{subj}.trial), config);
        end
end