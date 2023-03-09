%% Behav results matlab

clear

% set path to home
cd ('/media/ludovico/DATA/iEEG_Ludo')

%add relevant paths to toolboxes
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/PAC')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses')
ft_defaults;
Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles'; %Where the data files are
config.regressors   = 'Accuracy'; %use accuracy score (from 0 to 3 for each series)
config.day          = 2; %day for data 
config.ROI          = 'Hippocampus'; 
byacc               = 'no';
event               = [50]; %event number 
defaultschansubj;   %defaults subjects

%name variable to find file
switch config.ROI
    case 'Hippocampus'
        roi = [];
    case 'middletemporal'
        roi = '_MT';
end
switch byacc
    case {'no', 'all'}
        acc = 'all';
    case'acc'
        acc = 'acc';
    case'nacc'
        acc ='nacc';
end
%Answers from day 1 
config.recfrom = 1;
for subj  = 1:numel(subjc)
    config.eventvalue           = event(1);
    config.Subject              = subjc(subj);
    regD1{subj}                   = GetRegressors(config);
    subj= subj+1;
end
%answers from day 2
config.recfrom=2;
for subj  = 1:numel(subjc)
    config.eventvalue           = event(1);
    config.Subject              = subjc(subj);
    regD2{subj}                   = GetRegressors(config);
    subj= subj+1;
end

for subj=1:numel(subjc)
    if length(regD1{subj}.Accuracy) < 60
        regD1{subj}.Accuracy(end:60) = NaN;
    end
     if length(regD2{subj}.Accuracy) < 60
        regD2{subj}.Accuracy(end:60) = NaN;
    end
    Acc1(subj, :) = regD1{subj}.Accuracy;
    Acc2(subj, :) = regD2{subj}.Accuracy;
end
Acc1(Acc1<2) =0;
Acc1(Acc1>1) =1;
Acc2(Acc2<2) =0;
Acc2(Acc2>1) =1;

Acc1_Perc = Acc1./0.01;
Acc2_Perc = Acc2./0.01;

Acc1_perc_m = squeeze(nanmean(Acc1_Perc, 2));
Acc2_perc_m = squeeze(nanmean(Acc2_Perc, 2));

bxpltdat(:, 1) = Acc1_perc_m;
bxpltdat(:, 2) = Acc2_perc_m;
scatdat = [bxpltdat(:, 1); bxpltdat(:, 2)];


c1 = [0 0.4470 0.7410];
c2 = [0.8500 0.3250 0.0980];
ccs = [c1; c2];
colrs = [repmat(c1, length(bxpltdat), 1); repmat(c2, length(bxpltdat), 1)];
xx = [ones(length(bxpltdat), 1); ones(length(bxpltdat), 1)*2];
x = [ones(length(bxpltdat), 1) ones(length(bxpltdat), 1)*2];



%figures
figure('Units', 'normalized', 'Position', [0 0 0.5 0.7])
ax = axes();
hold(ax)
for i = 1:size(bxpltdat, 2)
    boxchart(x(:,i), bxpltdat(:, i), 'BoxFaceColor', ccs(i, :), 'LineWidth', 2);
end
hold on;
sz = [];
scatter(xx, scatdat, sz, colrs, 'filled')
plot([xx(1:end/2) xx(end/2+1:end)]', [scatdat(1:end/2) scatdat(end/2+1:end)]','--k')
ylabel('Average Accuracy (%)')
% xlabel('Day')
xticks([1 2])
xticklabels({'Immediate Recall', 'Delayed Recall'})
legend({'Immediate Recall', 'Delayed Recall'}, 'Location', 'southwest')
title('Average Accuracy')
ylim([0 100])
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 16;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',16,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');


[h p ci stat] = ttest(Acc1_perc_m, Acc2_perc_m);
p

%% binary distrib
Acc1_b = Acc1;
Acc2_b = Acc2;

Acc1_b(Acc1_b < 2) = 0;
Acc1_b(Acc1_b > 1) = 1;
Acc2_b(Acc2_b < 2) = 0;
Acc2_b(Acc2_b > 1) = 1;

for subj= 1:numel(subjc)
    nbacc1(subj) = sum(Acc1_b(subj, :) == 1);
    nbnacc1(subj) = sum(Acc1_b(subj, :) == 0);
    nbacc2(subj) = sum(Acc2_b(subj, :) == 1);
    nbnacc2(subj) = sum(Acc2_b(subj, :) == 0);
end

nbacc1 = nbacc1/60;
nbacc2 = nbacc2/60;
nbnacc1 = nbnacc1 /60;
nbnacc2= nbnacc2 / 60;

nb1 = [nbacc1;nbnacc1];
nb2 = [nbacc2;nbnacc2];
nb = [nb1; nb2];

nb1_m = mean(nb1, 2);
nb2_m = mean(nb2, 2);
nb_m = [nb1_m nb2_m]';

nb1_SE = std(nb1,[], 2)./sqrt(numel(subjc));
nb2_SE = std(nb2,[], 2)./sqrt(numel(subjc));
nb_SE = [nb1_SE nb2_SE]';

figure(2); 
hold all;
b = bar(nb_m, 'FaceAlpha', 0.5);
b(1).FaceColor = ccs(1, :);
b(2).FaceColor = ccs(2, :);
b(1).EdgeColor = ccs(1, :);
b(2).EdgeColor = ccs(2, :);
b(1).LineWidth = 2;
b(2).LineWidth = 2;
x = centered_Ebars(nb_m, b);
errorbar(x, nb_m, nb_SE, 'k', 'LineWidth', 2, 'linestyle', 'none')
ylabel('Average percentage of trials per condition')
% xlabel('Day')
xticks([1 2])
xticklabels({'Immediate Recall', 'Delayed Recall'})
legend({'Accurate Trials', 'Non Accurate Trials'}, 'Location', 'northeast')
title('Average number of trials per condition')
ylim([0 1])
ax = gca;
ax.TitleFontSizeMultiplier = 1.5;
ax.FontSize = 16;
ax.FontWeight = 'bold';
set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',16,'FontWeight','bold', 'LineWidth', 3);
set(gcf, 'color', 'white');
set(gcf, 'renderer', 'Painters')


[h p1 ci stat] = ttest(nbacc1, nbnacc1);
p1
[h p2 ci stat] = ttest(nbacc2, nbnacc2);
p2
fprintf('Difference in Accuracy between Day 1 and 2, paired t-test, p = %.2f \n', p)
fprintf('Difference in number of trials per condition on Day 1, paired t-test, p = %.2f \n', p1)
fprintf('Difference in number of trials per condition on Day 2, paired t-test, p = %.2f \n', p2)