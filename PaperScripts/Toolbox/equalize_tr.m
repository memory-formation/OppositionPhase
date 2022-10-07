function [data1 data2 ntrials] = equalize_tr(data1, data2)

if isstruct(data1) == 0
    fieldtripize(data1)
end
if isstruct(data2) == 0
    fieldtripize(data1)
end

l1 = length(data1.trial);
l2 = length(data2.trial);

lesstrials = min(l1, l2);
maxtrials    = max(l1, l2);
trsel = randperm(maxtrials);
trsel = sort(trsel(1:lesstrials));

if maxtrials == l1
    cfg = []; 
    cfg.trials = trsel;
    data1 = ft_selectdata(cfg, data1);
    fprintf('Equalizing trials \n')
elseif maxtrials == l2 
    cfg =[];
    cfg.trials = trsel;
    data2 = ft_selectdata(cfg, data2);
    fprintf('Equalizing trials \n')
elseif l1 == l2 
    fprintf('Equal number of trials, no equalization needed \n')
end
ntrials = lesstrials;
end
