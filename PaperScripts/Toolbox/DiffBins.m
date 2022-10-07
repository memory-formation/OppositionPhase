function DiffBin = DiffBins(Amp1, Amp2)
a1 = squeeze(Amp1);
a2 = squeeze(Amp2);

a1=a1./(sum(a1));
a2=a2./(sum(a2));

ma1 = mean(a1);
ma2 = mean(a2);
ma = mean([ma1 ma2]);
% 
AmpDiff = ((a1-a2)+2*ma)/2;
DiffBin = AmpDiff;
% max1 = max(AmpDiff);
% min1 = min(AmpDiff);
% dist = (max1-min1)/2;
% m_min = 2*ma-dist;
% m_max = 2*ma+dist;
% DiffBin = normalize(AmpDiff, 'range', [m_min m_max])/2;
DiffBin = DiffBin./sum(DiffBin); 
%create smoothbins to have a 
%specific smoothing for binned data
end