


%% if one or more events have more than one eventvalue put images together
%% put all images data together

if numel(event1) >1
    for subj= 1:numel(subjc)
        dat{subj} = [];
        for img = 1:numel(event1)
            for trl = 1:length(AllDat1_cltr{subj, img}.trial)
                dat{subj} = [dat{subj}; AllDat1_cltr{subj, img}.trial{trl}];
            end
        end
    end
    clear AllDat1_cltr
    config.fs = 1000;
    config.startend = tfpize;
    for subj = 1:numel(subjc)
        AllDat1_cltr{subj} = fieldtripize(dat{subj}, config);
    end
   AllDat1_cltr = AllDat1_cltr'; 
end



if numel(event2) > 1
    for subj= 1:numel(subjc)
        dat{subj} = [];
        for img = 1:numel(event2)
            for trl = 1:length(AllDat2_cltr{subj, img}.trial)
                dat{subj} = [dat{subj}; AllDat2_cltr{subj, img}.trial{trl}];
            end
        end
    end
    clear AllDat2_cltr
    config.fs = 1000;
    config.startend = tfpize;
    for subj = 1:numel(subjc)
        AllDat2_cltr{subj} = fieldtripize(dat{subj}, config);
    end
   AllDat2_cltr = AllDat2_cltr'; 
end

%% equalize trials
switch config.equalize 
    case'yes'
        for subj = 1:numel(subjc)
                [AllDat1_cltr{subj} AllDat2_cltr{subj}] = equalize_tr(AllDat1_cltr{subj}, AllDat2_cltr{subj});
        end
end