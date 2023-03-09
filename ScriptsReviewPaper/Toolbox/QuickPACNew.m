if numel(event) == 2 | event == 10 | event == 11 | event == 12 | event == 13
    event = [10 11 12 13];
end

filename = sprintf('PAC_como_avg_%s_day%d_%s_%s_%s%s_TS', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);
load(filesave)

lp = length(phaseint);
lc = size(comodulogram, 2);
ld = 1+lc-lp;
comodulogram = comodulogram(:, [ld:end], :);

filename = sprintf('PAC_surr_avg_%s_day%d_%s_%s_%s%s_TS.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);
load(filesave)
lp = length(phaseint);
lc = size(surrogates, 3);
ld = 1+lc-lp;
surrogates = surrogates(:, :, [ld:end], :);

% %


clear comn surn
comn = comodulogram;
surn = squeeze(mean(surrogates, 2));
% comn(:, 1, : ) = [];
% surn(:, 1, :) = [];
clear comf
for subj = 1:numel(subjc)
    comf(subj, :, :) = (comodulogram (subj, :, :)- surn(subj, :, :))./std(surn(subj, :, :));
end
avgcomo = squeeze(mean(comf));

switch clustMethod
    case 'RegMean'
        %% direct comparison
        mat1 = permute(comodulogram, [2 3 1]);
        surr_m = squeeze(mean(surrogates, 2));
        mat2 = permute(surr_m, [2 3 1]);
        
        [clust, pclust, texp] = permutest(mat1, mat2, true, 0.025, 1000, true);
        cluster = zeros(size(squeeze(mean(comodulogram))));
        for i = 1:length(clust)
            
            cluster(clust{i})=  i;
        end
        clustpm = cluster;
        sigclust = zeros(size(clustpm));
        for i= 1:max(max(clustpm))
            if pclust(i) < 0.05
                cond = clustpm == i;
                switch byacc
                    case {'all', 'no', 'acc', 'nacc'}
                        sigclust(cond) = avgcomo(cond);
                    case 'yes'
                        sigclust(cond) = avgcomo_acc(cond)-avgcomo_nacc(cond);
                end
            end
        end
        
        mask = false(size(sigclust));
        cond = sigclust > 0;
        mask(cond) = true;
        
        clear rowos colos
        for i= 1:max(clustpm, [], 'all')
            clustnum = i;
            if pclust(i) < 0.05
                cond = clustpm == clustnum;
                sc = sigclust.*cond;
                [rowos{i}  colos{i}] = find(abs(sc) > 0);
            else
                sc = zeros(size(sigclust));
            end
        end
        if ~exist('rowos')
            [rowos{1} colos{1}] = find(max(avgcomo, [], 'all') == avgcomo);
        end
        %
        % switch config.peak
        %     case'yes'
        %         clust = res(rowos{1}, colos{1});
        %         peak = max(clust, [], 'all');
        %         [rowpeak colpeak] = find(res == peak);
        %         rowos{1} = rowpeak;
        %         colos{1} = colpeak;
        % end
    case 'tscore'
        %% t scoring
        PAC_clust_tscore;
end

if figsCL == 1
    
    
    
    config.latency = timeint;
    config.lowfreq = phaseint;
    config.highfreq = ampint;
    comn = comodulogram;
    surn = surr_m;
    %     comn(7, :, :) = [];
    %     surn(7, :, :) = [];
    avgsurr = squeeze(mean(surn));
    %
    avgcomo = squeeze(mean(comn));
    
    stdsurr = squeeze(std(surn, 1))';
    
    aab = comn-surn;
    for subj = 1:size(aab, 1)
        aab(subj, :, :) = zscore(aab(subj, :, :), [], 'all');
    end
    
    aac = squeeze(mean(aab))';
    %     aac = rescale(aac, -1, 1);
    
    avgc = squeeze(mean(comn-surn))';
    avgg = avgcomo'-avgsurr'; %range [-0.0003 0.0003]
    clear aa1r
    aa1r = avgc;%./stdsurr; %range [-0.5 10]
    %     aa1r = zscore(aa1r, [], 'all');
    
    %avgcomo %range[ 0.0003 0.001]
    cmap = [ones(1, 256)' ones(1, 256)' linspace(1, 0, 256)']; %white to yellow
    cmap = [cmap; ones(1, 256)' linspace(1, 0, 256)' zeros(1, 256)']; %yellow to red
    cmap = [cmap; linspace(1, 0, 256)' zeros(1, 256)' zeros(1, 256)']; %red to black
    cmap = [cmap; zeros(1, 256)' zeros(1, 256)' linspace(0, 1, 256)']; %black to blue
    cmap = [cmap; zeros(1, 256)' linspace(0, 1, 256)' ones(1, 256)']; %blue to cyan
    cmap = [cmap; linspace(0, 1, 256)' ones(1, 256)' ones(1, 256)']; %cyan to white
    cmap = flip(cmap);
    comf_avg = squeeze(mean(comf));
    
    
    figure;set(gcf,'Position', [0 0 900 700])
    contourf(config.lowfreq, config.highfreq, smooth2a(aac, 2, 2),40,'linecolor','none')
    set(gca,'clim',[-0.4 0.4])
    
    
    hold on;
    contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
    xlabel('Frequency for phase (Hz)')
    ylabel('frequency for amplitude (Hz)')
    %         colormap(cmap)
    colorbar
    title('Map of phase-amplitude coupling')
    ax = gca;
    ax.TitleFontSizeMultiplier = 1.5;
    ax.FontSize = 14;
    ax.FontWeight = 'bold';
    set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
    ch = colorbar;
    colormap('parula')
    set(ch, 'FontSize', 16)
    set(gcf, 'color', 'white');
    set(gcf, 'renderer', 'Painters')
    
    %     figure;set(gcf,'Position', [0 0 900 700])
    %     contourf(config.lowfreq, config.highfreq, res',40,'linecolor','none')
    %     set(gca,'clim',[-1 3])
    %     hold on;
    %     contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
    %     xlabel('Frequency for phase')
    %     ylabel('frequency for amplitude')
    %     colorbar
    %     title('Map of T values')
    %     ax = gca;
    %     ax.TitleFontSizeMultiplier = 1.5;
    %     ax.FontSize = 14;
    %     ax.FontWeight = 'bold';
    %     set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
    %     set(gcf, 'renderer', 'Painters')
    %     set(gcf, 'color', 'white');
    %
    %     comodulogram(8, :, :)  = [];
    figure;set(gcf,'Position', [0 0 1000 900])
    diffn = squeeze(comn-surn);
    diffn = aab;
    [rr cc]= rect(size(comn, 1));
    for subj = 1:size(comn, 1)
        subplot(rr, cc, subj)
        diffns = squeeze(diffn(subj, :, :))';
        %         diffn = rescale(diffn, -1, 1);
        contourf(config.lowfreq, config.highfreq, diffns,40,'linecolor','none')
        set(gca, 'clim', [-2 2])
        hold on;
        title(sprintf('Pat %d', subjc(subj)))
        %         contour(config.lowfreq, config.highfreq, mask', 1, 'linecolor', 'k', 'LineWidth', 2)
        colorbar
        colormap('parula')
        set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',14,'FontWeight','bold', 'LineWidth', 3);
    end
    set(gcf, 'color', 'white');
    set(gcf, 'renderer', 'Painters')
end

% fprintf('event %s day %d %s trials, n_iter =  %d\n pval1 = %f \n One way t-test \n',...
%     mat2str(event), config.day, acc, config.n_iter, pclust(1))