function MeanAmp = BinData(PHASE, AMP, config)
%% instructions: 
%This function Bins data of phase and amplitude that have to be 3D
%matrices. the output is a binned distrubtion of 
%bin(phasefreqs, ampfreqs,bins) or a 4D matrix with trials in function of
%the choixe of config.keeptrials. 
%another possible function to be used is BinVec that allows more wiggle
%room. 

%% settings
if ~isfield(config, 'nbins');   nbins = 20;            else nbins = config.nbins;           end
if ~isfield(config, 'lowfreq'); low_freqs = 4:1:20;    else low_freqs = config.lowfreq;    end
if ~isfield(config,'highfreq'); high_freqs = 30:5:160; else high_freqs = config.highfreq;  end

position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end

ampbin = zeros(size(AMP, 1), size(PHASE, 2), size(AMP, 2),  nbins);
for trl= 1:size(AMP, 1)
%     showprogress(trl, size(AMP, 1));
    for lf = 1:size(PHASE, 2)
        for hf = 1:size(AMP, 2)
            clear tmp
            for i=1:nbins
                phs_mask = find(PHASE(trl, lf, :) < position(i)+winsize & PHASE(trl, lf, :) >=  position(i));
                tmp(1,i) = squeeze(mean(AMP(trl, hf, phs_mask)));
            end
            ampbin(trl,lf,hf,:)=smoothbin(tmp, 3);
        end
    end
end



switch config.modify
    case 'yes'
        for trl = 1:size(ampbin, 1)
            for lf = 1:size(PHASE, 2)
                for hf = 1:size(AMP, 2)
                    MeanAmp(trl, lf, hf, :) = normalize(ampbin(trl, lf, hf, :), 'range');
                end
            end
        end
    case 'no' 
        MeanAmp = ampbin;
    case'normbin'
        for trl = 1:size(ampbin, 1)
            for lf = 1:size(PHASE, 2)
                for hf = 1:size(AMP, 2)
                    MeanAmp(trl, lf, hf, :) = (ampbin(trl, lf, hf, :)./sum(ampbin(trl, lf, hf, :)));
                end
            end
        end
end


switch config.keeptrials
    case 'no'
        MeanAmp = mean(MeanAmp, 1);
end

MeanAmp = squeeze(MeanAmp);
if size(size(MeanAmp)) < 3
    MeanAmp_n(1, 1, :) = MeanAmp';
    MeanAmp = MeanAmp_n;
end