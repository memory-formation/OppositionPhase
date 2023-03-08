% phase amplitude coupling
clear
cd ('/media/ludovico/DATA/iEEG_Ludo')
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/toolbox2.0'))
addpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20201205')
addpath('/media/ludovico/DATA/iEEG_Ludo/ElecPlacementToolbox')
addpath ('/media/ludovico/DATA/iEEG_Ludo/spm12')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/PAC')
addpath ('/media/ludovico/DATA/iEEG_Ludo/Scripts/Figures_Analyses/Analyses')
ft_defaults;
Datafiles           = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/MatFiles';
config.artdefredo   = 0;
config.ROI          = 'Hippocampus';
config.recfrom      = 2;
config.artdeftype   = 'complete';
config.regressors   = 'Accuracy';
smoothby            = 1;
config.day          = 2;
event               = [50];
timeint             = [0 2.5];
config.n_iter       = 1000;
phaseint            = 4:1:12;   %freqs for phases of interest
ampint              = 30:5:140; %freqs for amplitude of interes
highfrint           = ampint;
byacc               = 'all'; %select all trials, accurate trials, or nona ccurate trials ('all', 'acc', 'nacc')
como                = 'yes'; %show comodulogram
config.norm         = 'norm'; %normalizeeach trial over mean of trials after filtering ('no', 'norm')
foi                 = 'no'; 
config.nbins        = 18; %number of bins
config.keeptrials   = 'no'; %keep trials in data or average over trials, defaut = 'no'.
config.MI           = 'MVL'; % both choose modulation index, 'MVL, 'DKL', 'both'
config.output       = config.MI; %output of function
config.binned       = 'yes'; %bin data
outputorig          = config.output;
config.equalize     = 'no'; %equalize trials
redoPAC             = 1; %redo PAC analysis, 0 to load instead saved file, PAC is done if there is no file
defaultschansubj; %defaults subjects
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

%get data
GetPACData;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FilterData


filename = sprintf('PAC_como_avg_%s_day%d_%s_%s_%s%s.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);


config.latency = timeint;
config.lowfreq = phaseint;
config.highfreq = ampint;

%filter
clear comodulogram surrogates
for subj = 1:numel(subjc)
    data = AllDatImg{subj};
    fprintf('\n Filtering patient %d \n', subj)
    config.output = 'MI';
    [phase_r{subj} amp_r{subj}] = GetPhaseAmp(data, config);
end


%do PAC for experimental conditions
if ~exist(filesave) || redoPAC == 1
    
    for subj = 1:numel(subjc)
        config.output = config.MI;
        fprintf('\n Computing PAC for patient %d \n', subj)
        config.modify = 'normbin';
        comodulogram(subj, :, :) = PAC_avg(phase_r{subj}, amp_r{subj}, config);
    end
    
    save(filesave, 'comodulogram')
else
    load(filesave)
end

filename = sprintf('PAC_surr_avg_%s_day%d_%s_%s_%s%s.mat', mat2str(event),...
    config.day, config.MI, acc, config.norm, roi);
FolderPAC = '/media/ludovico/DATA/iEEG_Ludo/Results/All_Subjects/NewPAC';
filesave = fullfile(FolderPAC, filename);
if ~exist(filesave) || redoPAC == 1
    
    for subj=1:numel(subjc)
        config.modify = 'normbin';
        surrogates(subj, :, :, :) = PAC_surr(phase_r{subj}, amp_r{subj}, config);
    end
    save(filesave, 'surrogates')
else
    load(filesave)
end

QuickPAC;
