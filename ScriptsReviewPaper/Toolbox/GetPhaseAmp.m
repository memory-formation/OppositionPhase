function [phase amp] = GetPhaseAmp(data, config)


%% settings
if ~isfield(config, 'lowfreq')
    low_freqs = 4:1:20;
else
    low_freqs = config.lowfreq;
end

if ~isfield(config, 'highfreq')
    high_freqs = 30:5:150;
else
    high_freqs = config.highfreq;
end

if ~isfield(config, 'latency')
    latency = [0 2];
else
    latency = config.latency;
end
if isstruct(data) == 0
    fieldtripize(config, data);
end

srate = data.fsample;


PhaseFreq_BandWidth=1;
AmpFreq_BandWidth=10;


% %% select latency
% cfg             = [];
% cfg.latency     = latency;
% datacut        = ft_selectdata(cfg, data);
npnts = length(data.trial{1});
%filter phase
fprintf('doing phase... ')
for trl= 1:length(data.trial)
     showprogress(trl, length(data.trial))
    for lf = 1:length(low_freqs)
        Pf1 = low_freqs(lf)-(low_freqs(lf)*.4)/2;
        Pf2 = low_freqs(lf)+(low_freqs(lf)*.4)/2;
        if fix(srate/Pf1*2) > fix(npnts/3)
            filtorder = fix(npnts/3-1);
        else
            filtorder = fix(srate/low_freqs(lf)*2) ;
        end
        phasefilt(trl, lf, :) = eegfilt(data.trial{trl}, srate, Pf1, Pf2, npnts, filtorder);
    end
end
%normalize phasefilt
switch config.norm
    case'norm'
        fprintf('Normalizing ovec trials \n')
        for lf = 1:length(low_freqs)
            Mphf = mean(phasefilt(:, lf, :), 1);
            stdPhf = std(phasefilt(:, lf, :), 1);
            for trl= 1:length(data.trial)
                phasefilt(trl, lf, :) = (phasefilt(trl, lf, :)-Mphf)./stdPhf;
            end
        end
end
%extract angle                    
for lf = 1:length(low_freqs)
    for trl= 1:length(data.trial)
        phase(trl, lf, :) = angle(hilbert(phasefilt(trl, lf, :)));
    end
end
%filter amplitude
fprintf('doing amplitude... ')
for trl= 1:length(data.trial)
    showprogress(trl, length(data.trial))
    for hf = 1:length(high_freqs)   
        Hf1 = high_freqs(hf)-(high_freqs(hf)*.7)/2;% -high_freqs(hf)*.3;
        Hf2 = high_freqs(hf)+(high_freqs(hf)*.7)/2;
        ampfilt(trl, hf, :) = eegfilt(data.trial{trl}, srate, Hf1, Hf2);
    end
end
%normalize amplitude
switch config.norm
    case'norm'
        fprintf('Normalizing ovec trials \n')
        for hf = 1:length(high_freqs)
            Mphf = mean(ampfilt(:, hf, :), 1);
            stdPhf = std(ampfilt(:, hf, :), 1);
            for trl= 1:length(data.trial)
                ampfilt(trl, hf, :) = (ampfilt(trl, hf, :)-Mphf)./stdPhf;
            end
        end
end
%extract envelope
for trl= 1:length(data.trial)
    for hf = 1:length(high_freqs)
        amp(trl, hf, :) = abs(hilbert(ampfilt(trl, hf, :))).^2;
    end
end

%cut data in function of time of interest
idx0 = find(data.time{1} == 0);
idxlow = idx0-config.latency(1)*data.fsample;
idxhigh = idx0 + config.latency(2)*data.fsample;
for trl = 1:length(data.trial)
    for lf = 1:size(phase, 2)
        phasecut(trl, lf, :) = phase(trl, lf, [idxlow:idxhigh]);
    end
end
phase = phasecut;
for trl = 1:length(data.trial)
    for lf = 1:size(amp, 2)
        ampcut(trl, lf, :) = amp(trl, lf, [idxlow:idxhigh]);
    end
end
amp = ampcut;

end
