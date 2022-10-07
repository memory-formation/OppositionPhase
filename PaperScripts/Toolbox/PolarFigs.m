if event1(1) > 24
    encrec = 'Recall';
elseif event1(1) == 24
    encrec = 'Offset';
elseif numel(event1)>2
    encrec = 'Encoding';
elseif event1<24 & numel(event1)<2
    encrec = sprintf('Image %d', event1);
elseif numel(event1) == 2
    encrec = sprintf('Encoding Images %d %d', event1(1), event1(2));
end


figure;set(gcf,'Position', [0 0 900 650])
config.color = [0 0.4 0.7];
polarplot_bin(ampz_avg1, config)
[thfill rhofill zufill] = polarfill_bin(ampz_avg1, config);
tt = sprintf('Polar Distribution for \n %s %s trials day %d', encrec, acc1, day1);
title(tt)
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
polarfill(gca, thfill, thfill, zufill, rhofill, config.color, 0.3)
set(gca, 'children', flipud(get(gca, 'children')))
set(gcf, 'renderer', 'Painters')


if event2(1) > 24
    encrec = 'Recall';
elseif event2(1) == 24
    encrec = 'Offset';
elseif numel(event2)>2
    encrec = 'Encoding';
elseif event2<24 & numel(event2)<2
    encrec = sprintf('Image %d', event2);
elseif numel(event2) == 2
    encrec = sprintf('Encoding Images %d %d', event2(1), event2(2));
end
figure;set(gcf,'Position', [0 0 900 650])
config.color = [0.6 0.07 0.2];
polarplot_bin(ampz_avg2, config)
[thfill rhofill zufill] = polarfill_bin(ampz_avg2, config);
tt = sprintf('Polar Distribution for \n %s %s trials day %d', encrec, acc2, day2);
title(tt)
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
polarfill(gca, thfill, thfill, zufill, rhofill, config.color, 0.3)
set(gcf, 'renderer', 'Painters')


    
