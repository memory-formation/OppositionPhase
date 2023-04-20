function phaseamp_surr = PAC_surr(PHASE, AMP, config)

if isfield(config, 'n_iter') == 0
    n_iter = 200;
else
    n_iter = config.n_iter;
end
rng shuffle;
numlf = size(PHASE, 2);
numhf = size(AMP, 2);
numtrl1 = size(AMP, 1);
nbins = config.nbins;
phaseamp_surr = zeros(n_iter, numlf, numhf);
config.prog = 'no';
position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end
switch config.shuffle
    case 'TS'
        
        switch config.output
            case 'MVL'
                %for MOVI
                for bi = 1:n_iter
                    ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
                    showprogress(bi, n_iter)
                    %shuffle
                    for trl = 1:size(AMP, 1)
                        for hf = 1:size(AMP, 2)
                            npnts = size(AMP, 3);
                            cutpoint            = randsample(round(npnts/10):round(npnts*.9),1); %cut between 10% from beginning to 10% from the end
                            ampsh(trl, hf, :) = AMP(trl, hf, [cutpoint:end 1:cutpoint-1]);
                        end
                    end
                    
                    ampbinsh       = BinData(PHASE, ampsh, config);
                    
                    for lf = 1:numlf
                        for hf = 1:numhf
                            clear tmp
                            tmp = squeeze(ampbinsh(lf, hf, :));
                            modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                            phaseamp_surr(bi, lf, hf) = modidx;
                        end
                    end
                end
            case'DKL'
                %for test with KL distance
                for bi = 1:n_iter
                    ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
                    showprogress(bi, n_iter)
                    for trl = 1:size(AMP, 1)
                        for hf = 1:size(AMP, 2)
                            npnts = size(AMP, 3);
                            cutpoint            = randsample(round(npnts/10):round(npnts*.9),1); %cut between 10% from beginning to 10% from the end
                            ampsh(trl, hf, :) = AMP(trl, hf, [cutpoint:end 1:cutpoint-1]);
                        end
                    end
                    
                    ampbinsh       = BinData(PHASE, ampsh, config);
                    for lf = 1:numlf
                        for hf = 1:numhf
                            phaseamp_surr(bi, lf, hf) = Tort_MI(ampbinsh(lf, hf, :), config.nbins);
                        end
                    end
                end
        end
        
    case 'LS'
        switch config.output
            case 'MVL'
                %for MOVI
                for bi = 1:n_iter
                    ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
                    showprogress(bi, n_iter)
                    r               = randperm(size(AMP, 1));
                    ampsh          = AMP(r, :, :);
                    ampbinsh       = BinData(PHASE, ampsh, config);
                    
                    for lf = 1:numlf
                        for hf = 1:numhf
                            clear tmp
                            tmp = squeeze(ampbinsh(lf, hf, :));
                            modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                            phaseamp_surr(bi, lf, hf) = modidx;
                        end
                    end
                end
            case'DKL'
                %for test with KL distance
                for bi = 1:n_iter
                    ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
                    showprogress(bi, n_iter)
                    r               = randperm(size(AMP, 1));
                    ampsh          = AMP(r, :, :);
                    ampbinsh       = BinData(PHASE, ampsh, config);
                    for lf = 1:numlf
                        for hf = 1:numhf
                            phaseamp_surr(bi, lf, hf) = Tort_MI(ampbinsh(lf, hf, :), config.nbins);
                        end
                    end
                end
            case'both'
                for bi = 1:n_iter
                    ampbinsh =zeros(size(PHASE, 2), size(AMP, 2), config.nbins);
                    showprogress(bi, n_iter)
                    r               = randperm(size(AMP, 1));
                    ampsh          = AMP(r, :, :);
                    ampbinsh       = BinData(PHASE, ampsh, config);
                    for lf = 1:numlf
                        for hf = 1:numhf
                            clear tmp
                            tmp = squeeze(ampbinsh(lf, hf, :));
                            modidx = abs(mean(tmp'.*exp(sqrt(-1)*position)));
                            MOVI(bi, lf, hf) = modidx;
                            DKL(bi, lf, hf) = Tort_MI(ampbinsh(lf, hf, :), config.nbins);
                        end
                    end
                end
        end
end
% switch config.keepiter
%     case'yes'
%        switch config.output
%             case'both'
%                 clear phaseamp
%                 phaseamp_surr.MOVI = MOVI;
%                 phaseamp_surr.DKL = DKL;
%             otherwise
%                 phaseamp_surr = phaseamp;
%         end
%     case ' no'
switch config.output
    case'both'
        clear phaseamp
        phaseamp_surr.MOVI = squeeze(mean(MOVI, 1));
        phaseamp_surr.DKL = squeeze(mean(DKL, 1));
    otherwise
        phaseamp_surr = phaseamp_surr;
end
% end

end
