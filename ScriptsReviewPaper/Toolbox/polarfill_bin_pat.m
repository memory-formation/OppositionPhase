function [thfill rhofill zufill] = polarfill_bin_pat(datb, config)

if ~isfield(config, 'color'); config.color = 'blue'; end
if ~isfield(config, 'alpha'); config.alpha = 0.4; end


nbins = size(datb, 2);
phase_edges = linspace(-pi, pi, nbins);
center_PE = diff(phase_edges);
CECE = center_PE(1)/2;
pedg = phase_edges(1:nbins);



dat_m = datb;

z2u = zeros(1,nbins);


[md idxmd] = max(dat_m);
% md = md+dat_SE(idxmd);
mf = 1; %/md; 

mins = min(dat_m, [], 'all');
mind = mins-mins/5;
maxs = max(dat_m, [], 'all');
maxd = maxs+maxs/5;

theta = [pedg pedg(1)];
rho = dat_m;
thfill = [];
rhofill = [];
zufill = [];
for nb = 1:nbins
    thetabin = [theta([nb nb+1]) theta(nb+1)];
    rhobin = [rho(nb) rho(nb) 0];
    zubin = [0 0 0];
    thfill = [thfill thetabin];
    rhofill = [rhofill rhobin];
    zufill = [zubin zufill];
end
