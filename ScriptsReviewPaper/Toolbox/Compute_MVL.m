function phaseamp = Compute_MVL(AmpBin, config)

numlf = size(AmpBin, 1);
numhf = size(AmpBin, 2);
nbins = size(AmpBin, 3);

position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end

phaseamp = zeros(numlf, numhf);
switch config.output
    case{'MOVI', 'MVL'}
        for lf = 1:numlf
%             showprogress(lf, numlf)
            for hf = 1:numhf
                clear tmp
                tmp = squeeze(AmpBin(lf, hf, :));
                modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                phaseamp(lf, hf) = modidx;
            end
        end
    case'DKL'
        for lf = 1:numlf
%             showprogress(lf, numlf)
            for hf = 1:numhf
                clear tmp
                tmp = squeeze(AmpBin(lf, hf, :));
                modidx = Tort_MI(tmp, nbins);
                phaseamp(lf, hf) = modidx;
            end
        end
end

        
