%determine dataset, trials and frequencies of interest
%download BrewerMap tookbox from matlab website for this script
data = AllDat2_cltr{2};
config.output = 'MI';
cfg.keeptrials ='yes';
DoFilterStuff;
a = ft_timelockanalysis(cfg, data); %extract ERP
% %trl 25 pat 2 for encoding (ph 2 amp 3)
% %trl 16 or 19 pat 2 recall (ph 4 amp 4)
phfreq = 4;
ampfreq = 4;
trial = 19;
time= 2501:3501;
b = squeeze(diff(phasefilt(trial, phfreq, (time))));
ab = find(diff(b>=0, 1));
ab(1:2:end) = [];



figure;
subplot(311) 
plot(squeeze(a.trial(trial, :, (time))))
hold all;
for i= 1:length(ab)
    xline([ab(i)], '--')
end
set(gca, 'xtick', [])
set(gca, 'ytick', [])
set(gca, 'XColor', 'white', 'YColor', 'white')
ylabel('LFP', 'Color', 'k')
subplot(312)
plot(squeeze(phasefilt(trial, phfreq, (time))))
set(gca, 'xtick', [])
set(gca, 'ytick', [])
set(gca, 'XColor', 'white', 'YColor', 'white')
ylabel('theta', 'Color', 'k')
hold all;
for i= 1:length(ab)
    xline([ab(i)], '--')
end
subplot(313)
plot(squeeze(ampfilt(trial, ampfreq, (time))))
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'renderer', 'Painters')
set(gca, 'xtick', [])
set(gca, 'ytick', [])
hold all;
for i= 1:length(ab)
    xline([ab(i)], '--')
end
set(gca, 'XColor', 'white', 'YColor', 'white')
ylabel('gamma', 'Color', 'k')
set(gcf, 'color', 'white')



ampval = squeeze(amp(trial, ampfreq, (time)));
phval = squeeze(phasefilt(trial, phfreq, (time)));
map = brewermap([], 'YlOrRd');
map(1:50, :) = [];
interpol=linspace(min(ampval), max(ampval), length(map));

cols = [];
for i = 1:length(ampval)
    [~, idx] = min(abs((interpol - ampval(i))));
    cols(i, :) = map(idx, :);
end

figure;
hold all
x = 1:length(phval);
for i = 1:length(phval)-1
    j = i:i+1;
    plot(x(j), phval(j), '-', 'color', cols(i, :), 'linewidth', 3)
end
set(gca, 'xtick', [])
set(gca, 'ytick', [])
set(gca, 'XColor', 'white', 'YColor', 'white')
ylabel('theta', 'Color', 'k')
hold all;
for i= 1:length(ab)
    xline([ab(i)], '--')
end
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 4);
set(gcf, 'renderer', 'Painters')
set(gca, 'xtick', [])
set(gca, 'ytick', [])
set(gca, 'XColor', 'white', 'YColor', 'white')
ylabel('theta', 'Color', 'k')
set(gcf, 'color', 'white')