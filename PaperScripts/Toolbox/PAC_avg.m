function phaseamp = PAC_avg(PHASE, AMP, config)

if isfield(config, 'n_iter') == 0
    n_iter = 200;
else
    n_iter = config.n_iter;
end

numlf = size(PHASE, 2);
numhf = size(AMP, 2);
numtrl1 = size(AMP, 1);
nbins = config.nbins;
phaseamp = zeros(numlf, numhf);
position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end

switch config.output
    case 'MVL'
        %for MOVI 
            ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
            fprintf('Binning... \n')
            ampbinsh       = BinData(PHASE, AMP, config);
            for lf = 1:numlf
                showprogress(lf, numlf)
                for hf = 1:numhf
                    clear tmp
                    tmp = squeeze(ampbinsh(lf, hf, :));
                    modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                    phaseamp(lf, hf) = modidx;
                end
            end
    case'DKL'
        %for test with KL distance

            ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
            ampbinsh       = BinData(PHASE, AMP, config);
            for lf = 1:numlf
                for hf = 1:numhf
                    clear tmp
                    tmp = squeeze(ampbinsh(lf, hf, :));
                    phaseamp(lf, hf) = Tort_MI(tmp, config.nbins);
                end
            end
    case'both'
            ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
            ampbinsh       = BinData(PHASE, AMP, config);
            for lf = 1:numlf
                for hf = 1:numhf
                    clear tmp
                    tmp = squeeze(ampbinsh(lf, hf, :));
                    modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                    MOVI(lf, hf) = modidx;
                    DKL(lf, hf) = Tort_MI(tmp, config.nbins);
                end
            end
    case 'compare'
        phaseamp = [];
           ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
            fprintf('Binning... \n')
            ampbinsh       = BinData(PHASE, AMP, config);
            for lf = 1:numlf
                showprogress(lf, numlf)
                for hf = 1:numhf
                    clear tmp
                    tmp = squeeze(ampbinsh(lf, hf, :));
                    modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                    phaseamp(lf, hf) = modidx;
                end
            end
end
switch config.output
    case'both'
        clear phaseamp
        phaseamp.MOVI = squeeze(MOVI, 1);
        phaseamp.DKL = squeeze(DKL, 1);
    otherwise
        phaseamp = phaseamp;
end

end