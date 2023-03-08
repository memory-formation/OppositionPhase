%to adapt the legend on the figures. 

leg1 = labels4legends(event1, acc1, day1);
leg2 = labels4legends(event2, acc2, day2);
%% get accuracy information
config.day = day1;
for img = 1:numel(event1)
    config.eventvalue = event1(img);
    filemat                     = sprintf('Data_complete_day%d_%d%s.mat',config.day, config.eventvalue, roi);
    datafile                    = fullfile(Datafiles, filemat);
    clear data
    load(datafile)
    
    for subj  = 1:numel(subjc)
        
        AllDat1{subj, img}           = data{subj};
    end
end

config.day = day2;
for img = 1:numel(event2)
    config.eventvalue = event2(img);
    filemat                     = sprintf('Data_complete_day%d_%d%s.mat',config.day, config.eventvalue, roi);
    datafile                    = fullfile(Datafiles, filemat);
    clear data
    load(datafile)
    
    for subj  = 1:numel(subjc)
        
        AllDat2{subj, img}           = data{subj};
    end
end


%% get recressors

for subj  = 1:numel(subjc)
    config.Subject = subjc(subj);
    config.day = day1;
    for img = 1:numel(event1)
        config.eventvalue = event1(img);
        reg1{subj, img}             = GetRegressors(config);
    end
    config.day = day2;
    for img = 1:numel(event2)
        config.eventvalue = event2(img);
        reg2{subj, img}             = GetRegressors(config);
    end
end

%make accuracy binary
for subj = 1:numel(subjc)
    for img = 1:numel(event1)
        reg1{subj, img}.Accuracy(reg1{subj, img}.Accuracy < 2, 1) = 0;
        reg1{subj, img}.Accuracy(reg1{subj, img}.Accuracy > 1, 1) = 1;
    end
end
for subj = 1:numel(subjc)
    for img = 1:numel(event2)
        reg2{subj, img}.Accuracy(reg2{subj, img}.Accuracy < 2, 1) = 0;
        reg2{subj, img}.Accuracy(reg2{subj, img}.Accuracy > 1, 1) = 1;
    end
end

%extract accuracy trials
clear tr_acc1 tr_nacc1
matreg1 = {};
for img= 1:numel(event1)
    for subj = 1:numel(subjc)
        matreg1{subj, img}(:, 2) = reg1{subj, img}.Trials;
        matreg1{subj, img}(:, 3) = reg1{subj, img}.Accuracy;
        matreg1{subj, img}(:, 4) = reg1{subj, img}.Engagement;
        matreg1{subj, img}(:, 1) = ismember(matreg1{subj, img}(:, 2), AllDat1{subj, img}.trialinfo(:, 2));
        %eliminate rows that are not present in the trialinfo due to
        %artifact rejection
        matreg1{subj, img}(matreg1{subj, img}(:, 1) == 0, :) = [];
        cond = ismember(AllDat1{subj, img}.trialinfo(:, 2), matreg1{subj, img}(:, 2));
        [~, idx] = sort(matreg1{subj, img}(:, 2));
        matreg1{subj, img} = matreg1{subj, img}(idx, :);
        matreg1{subj, img}(1:length(matreg1{subj, img}(:, 2)), 1) = reg1{subj}.Subject(1, 1);
        matreg1{subj, img}(:, 2) = AllDat1{subj, img}.trialinfo(cond, 4);
        tr_acc1{subj, img} = matreg1{subj, img}(matreg1{subj, img}(:, 3) == 1, 2);
        tr_nacc1{subj, img} = matreg1{subj, img}(matreg1{subj, img}(:, 3) == 0, 2);
        tr1{subj, img} = matreg1{subj, img}(:, 2);
    end
end

matreg2 = {};
for img= 1:numel(event2)
    for subj = 1:numel(subjc)
        matreg2{subj, img}(:, 2) = reg2{subj, img}.Trials;
        matreg2{subj, img}(:, 3) = reg2{subj, img}.Accuracy;
        matreg2{subj, img}(:, 4) = reg2{subj, img}.Engagement;
        matreg2{subj, img}(:, 1) = ismember(matreg2{subj, img}(:, 2), AllDat2{subj, img}.trialinfo(:, 2));
        %eliminate rows that are not present in the trialinfo due to
        %artifact rejection
        matreg2{subj, img}(matreg2{subj, img}(:, 1) == 0, :) = [];
        cond = ismember(AllDat2{subj, img}.trialinfo(:, 2), matreg2{subj, img}(:, 2));
        [~, idx] = sort(matreg2{subj, img}(:, 2));
        matreg2{subj, img} = matreg2{subj, img}(idx, :);
        matreg2{subj, img}(1:length(matreg2{subj, img}(:, 2)), 1) = reg2{subj}.Subject(1, 1);
        matreg2{subj, img}(:, 2) = AllDat2{subj, img}.trialinfo(cond, 4);
        tr_acc2{subj, img} = matreg2{subj, img}(matreg2{subj, img}(:, 3) == 1, 2);
        tr_nacc2{subj, img} = matreg2{subj, img}(matreg2{subj, img}(:, 3) == 0, 2);
        tr2{subj, img} = matreg2{subj, img}(:, 2);
    end
end

a = [numel(event1) numel(event2)];
b = max(a);

%separate data by accuracy
clear AllDat_acc AllDat_nacc
for img = 1:numel(event1)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr_acc1{subj, img};
        AllDat1_acc{subj, img} = ft_preprocessing(cfg, AllDat1{subj, img});
        cfg.trials = tr_nacc1{subj, img};
        AllDat1_nacc{subj, img} = ft_preprocessing(cfg, AllDat1{subj, img});
    end
end

for img = 1:numel(event2)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr_acc2{subj, img};
        AllDat2_acc{subj, img} = ft_preprocessing(cfg, AllDat2{subj, img});
        cfg.trials = tr_nacc2{subj, img};
        AllDat2_nacc{subj, img} = ft_preprocessing(cfg, AllDat2{subj, img});
    end
end

for img = 1:numel(event1)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr1{subj, img};
        AllDat1{subj, img} = ft_preprocessing(cfg, AllDat1{subj, img});
    end
end
for img = 1:numel(event2)
    for subj = 1:numel(subjc)
        cfg = [];
        cfg.trials = tr2{subj, img};
        AllDat2{subj, img} = ft_preprocessing(cfg, AllDat2{subj, img});
    end
end