function [] = polarplot_bin_pat(datb, config)
%% instructions
% use as polarplot_bin(datb, config) where datb is a subj*bins matrix 
%subjects or trials are needed to have the SE of the bars and the mean 
%config is optional and it's about color. 
%to fill the plot see polarfill_bin and polarfill
datb = squeeze(datb);
if ~isfield(config, 'color'); config.color = 'blue'; end
if ~isfield(config, 'alpha'); config.alpha = 0.4; end


nbins = size(datb, 2);
phase_edges = linspace(-pi, pi, nbins);
center_PE = diff(phase_edges);
CECE = center_PE(1)/2;
pedg = phase_edges(1:nbins);



dat_m = datb;


[md idxmd] = max(dat_m);
mf = 1; %/md; 


z2u = zeros(1,nbins);
%mean vec
MV = mean(dat_m.*exp(sqrt(-1)*phase_edges));
[THM RHM] = cart2pol(real(MV), imag(MV));
ang180 = floor(nbins/4);
[~, idx] = min(abs(phase_edges-THM));
mfv = circshift(dat_m, nbins/2-idx);
posmean = mfv(nbins/2-ang180:nbins/2+ang180);
idx = find(ismember(mfv, posmean)==0);
negmean = mfv(idx);

RHM = abs(mean(posmean)-mean(negmean)+min(dat_m)/2);

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
    polarplot([thetabin, thetabin], [zubin, rhobin], 'LineWidth', 2, 'Color', config.color);
    hold all;
end
mlim = 1;;
%errorbars
% polarplot([pedg+CECE; pedg+CECE], [dat_m-dat_SE; dat_m+dat_SE], 'k','LineWidth', 2); hold on;  
% polarplot(pedg(1:end-1)+CECE,dat_m(1:end-1), '.', 'MarkerSize', 15,  'Color', [0 0 0 ],'LineWidth', 1); hold on;
%mean vector
pv = polarplot([THM THM], [0; RHM], 'r', 'LineWidth', 4); hold on;
uistack(pv, 'top')
thetaticks(0:90:270)
thetaticklabels({'\fontsize{15}0' '\fontsize{25}\pi\fontsize{15}/2' '\fontsize{25}\pi' '\fontsize{15}3\fontsize{25}\pi\fontsize{15}/2'})
set(gca, 'FontSize', 16, 'RAxisLocation', 70, 'LineWidth', 3);
rlim([0 max(dat_m)])
set(gcf, 'color', 'white');
rticks([0:mlim/2:mlim])
rticklabels({mat2str(0), mat2str(mlim/2, 1), mat2str(mlim, 1)})
set(gcf, 'renderer', 'Painters')




    

% c2u = brewermap([nbins*10],'Blues'); 
% cmp=colormap(c2u(1:nbins*10/20:nbins*10,:,:));
% 
% % for i = 1:nbins
% %     if dat_m(i) > 0
% %         dmG(i) = dat_m(i)+ 0.0000075;
% %     else
% %         dmG(i) = dat_m(i) - 0.0000075;
% %     end
% % end
% % polarplot([pedg; pedg], [dmG; dat_m], 'LineWidth', 17, 'Color', cmp(20,:)*.8); hold on;   %
% polarplot([pedg; pedg], [z2u; dat_m],'LineWidth', 17,  'Color', cmp(20,:)*.8);% hold on; 
% rlim([mind maxd])

