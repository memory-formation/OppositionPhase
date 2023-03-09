function MI = Tort_MI(amp, nbins)
%% intro 
%use as MI = Tort_MI(amp, nbins) where amp is a vector of 1*nbins and nbins
%is the number of specified bins. 
%You can normalize amp before entering it in the funciton but the MI is
%going to be horrible if you input zscored data (see lines 10-11) 

nAmp = amp;
% noramlize binned amplitude
nAmp = amp./sum(amp);
nAmp(nAmp<0)=nan;

%calculate MI (see Tort 2010)
Hp = -nansum(nAmp.*log(nAmp));
Dkl = log(nbins)-Hp;
MI = Dkl/log(nbins);

end