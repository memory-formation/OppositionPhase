function MA = Binning(AMP, PHASE, config)
%% instructions 
%this funciton works only for vectors

%% defaults
if ~isfield(config, 'nbins');   nbins = 20;            else nbins = config.nbins;   end
    
position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end


phase_edges = linspace(-pi, pi, config.nbins);

for trl= 1:size(AMP, 1)
    clear tmp
    for i=1:nbins
        phs_mask = find(PHASE(trl, 1, :) < position(i)+winsize & PHASE(trl, 1, :) >=  position(i));
        tmp(1,i) = mean(AMP(trl, 1, phs_mask));
    end
    ampbin(trl,:)=tmp./sum(tmp);
end

switch config.keeptrials
    case 'no'
        MA = squeeze(nanmean(ampbin, 1));
    otherwise
        MA = ampbin;
end

switch config.modify
    case 'yes'
        for trl= 1:size(MA, 1)
            
            MA(trl, :) = normalize(MA(trl, :), 'range');
        end

    case 'zscore'
        for trl= 1:size(MA, 1)
                    MA(trl, :) = zscore(MA(trl, :));
        end
end
end
