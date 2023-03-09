function dataf = fieldtripize(data, config) 
%% instructions
%Input is a dataset that is  chan x timepoints x trials
%the function will put your dataset under the form of a fieldtrip dataset
%in order to continue with the function. 
%The PAC3 function requires fieldtrip-20201205 or later to function
%properly. 
%Copyright(C) Ludovico Saint Amour di Chanaz
%it is advised that the beginning of your trials are 0 or that you
%otherwise know where the start of the trial is. 
%inputs: 
%Data: where it is a 2 or 3D matrix 
%It has to be organized as data (trials, timepoints, channels)
%config where;
%config.fs 0 frequency sample (double, default is 1000)
%config.startend = [begin end]; this will help find the 0 of your point and
%calculate time in a way that is in accordance with what you are interested
%in your data. 

%% 
if ~isfield(config, 'fs')
    config.fs = 1000;
end
%get size of the data. 
totsize = length(size(data));
if totsize == 2
    data(:, :, 1) = data;
end
timef = config.startend(1):1/config.fs:config.startend(end);

for trials = 1:size(data, 1)
    for chans = 1:size(data, 3)
        dataf.trial{trials} = data(trials, :);
        dataf.label(chans) = {sprintf('Fake_ft_%d', chans)};
    end
    dataf.time{trials} = timef;
end


dataf.fsample = config.fs;
dataf.hdr = [];
dataf.trialinfo = 1:size(data, 1)';
dataf.sampleinfo(:, 1) = ones(size(data, 1), 1);
dataf.sampleinfo(:, 2) = ones(size(data, 1), 1).*length(timef);

dataf.cfg = [];
end
    