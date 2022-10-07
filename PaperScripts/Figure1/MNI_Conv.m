% Alexis Pérez Bellido (2021)
% To use this script you only need to loop over the participants folders loading the file with the localised electrodes and the preimplantation T1 anat scans.
clear
addpath('/media/ludovico/DATA/iEEG_Ludo/StructuralToolbox') %look at attached toolbox
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/spm12')) % add SPM12 (all folders)
addpath(genpath('/media/ludovico/DATA/iEEG_Ludo/fieldtrip-20220514')) %download last version of fieldtrip
ft_defaults;
config.ROI = 'Hippocampus'; %this is for the defaultschansubj where there is patient number and Chan name after referencing
defaultschansubj; %this script has 2 outputs: subjc (has the subj number to go look into the files and extract data)
%Chans: This is a cell array of strings where each one is either empty (for
%subjects not used) or a string under the form 'Hippelec1-Hippelec2' and
%has the name of the virtual channel after referencing that is the name of
%the referenced channel- referencing channel.
%Both subjc and Chans will be needed for the rest.
%example:
%   Chans = {[],[],'Ha2g_3-Ha2g_4', 'HmT3_2-HmT3_3', 'HaT2_2-HaT2_3', 'HaT1_3-HaT1_4', [], 'HMd1-HMd2',...
%           'HA1-HA2', 'HM2-HM3', [], [], [], [], 'HA2-HA3', [], 'AmT2_1-AmT2_2', 'HaT1_2-HaT1_3', 'HPL1-HPL2'};
%       subjc  = [3 4 5 6 8 9 10 15 17 19];

Respath = '/media/ludovico/DATA/iEEG_Ludo/Results'; %path to the results
StructFold = 'Structural'; %folder for structural data where your freesurfer data, MRI_acpc files etc... are saved
%including the elec_placement files you generated during electrode
%placement pipeline.





for subj = 1 : length(subjc)
    SubjFold = sprintf('Subject_%d', subjc(subj)); %this is where subjc is interesting because this string
    %                                                  will pick up on the subj
    %                                                  "real" number and will
    %                                                  be used to go fetch the
    %                                                  results file
    %                                                  corresponding to the
    %                                                  patient. Change string
    %                                                  if files are organized
    %                                                  differently.
    subj_path = fullfile(Respath, SubjFold, StructFold); %path to structural folder where all the files are located.
    
    
    
    % loading acpc alligned preimplantation T1
    p_mri_acpc = ft_read_mri(fullfile(subj_path, 'MR_acpc.nii')); %name of the MRI saved during placement pipeline
    %                         Path to it thanks to the subj
    %                         name that changes every
    %                         iteration. MR_acpc.nii should
    %                         be the same for every
    %                         patient.
    
    % loading acpc alligned localized electrodes
    
    electrodes_path = fullfile(subj_path, 'elec_acpc_f.mat'); %load the elec file.
    load(electrodes_path)
    
    
    % Loading labels info in order to
    iEEGcorr_path = fullfile(subj_path, 'iEEG_correg.mat'); %loat the .mat file corresponding to the elec placement file.
    iEEGcorr(subj) = load(iEEGcorr_path);
    
    % Here you can check whether the electrodes are correctly alligned to
    % the native space T1 image
    
    %figure;
    %ft_plot_ortho(p_mri_acpc.anatomy, 'transform', p_mri_acpc.transform, 'style', 'intersect');
    %ft_plot_sens(elec_acpc_f, 'label', 'on', 'fontcolor', 'w', 'fontsize', 6, 'style','r', 'elecsize', 10);
    
    % Standarizing electrodes to MNI space
    
    p_mri_acpc.coordsys = 'acpc';
    elec_acpc_ff    = elec_find(elec_acpc_f, Chans{subjc(subj)}); %extract only channels of interest
    %This is why we have the variable Chans, because it will automatically
    %pick the two channels involved in referencing with elec_find (see
    %toolbox)
    cfg            = [];
    cfg.elec       = elec_acpc_ff; %have only the relevant channels be realigned and found.
    cfg.method     = 'mni';
    cfg.mri        = p_mri_acpc;
    cfg.spmversion = 'spm12';
    cfg.spmmethod  = 'new';
    cfg.nonlinear  = 'yes';
    elec_mni_fstd(subj) = ft_electroderealign(cfg);
    elec_data =  elec_mni_fstd(subj);
    elect_savepath = fullfile( subj_path, 'elec_mni_fstd.mat');
    
    %save MNI modified space of electrodes of interest.
    save(elect_savepath, 'elec_data')
    
    
end



%% visualize the results
rmpath(genpath('/media/ludovico/DATA/iEEG_Ludo/spm12')) %remove spm 12 to avoid conflicts with fieldtrip
[ftver, ftpath] = ft_version;

% in surface pial

load([ftpath filesep 'template/anatomy/surface_pial_left.mat']);
template_lh = mesh; %clear mesh;

load([ftpath filesep 'template/anatomy/surface_pial_right.mat']);
template_rh = mesh; %clear mesh;

% in mni volume

mni_path = fullfile(ftpath , 'template/anatomy/single_subj_T1_1mm.nii');
mni = ft_read_mri(mni_path);

%% create subcortical space
%right hippomcapus
atlas = ft_read_atlas(fullfile(ftpath, 'template/atlas/aal/ROI_MNI_V4.nii'));
atlas = ft_convert_units(atlas, 'mm');
atlas.coordsys = 'mni';
cfg            = [];
cfg.inputcoord = 'mni';
cfg.atlas      = atlas;
cfg.roi        = {'Hippocampus_R'}; %change name here if other area is interesting
mask_rha = ft_volumelookup(cfg, atlas);


rmpath(genpath('/media/ludovico/DATA/iEEG_Ludo/spm12'))
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha1 = ft_prepare_mesh(cfg, seg);

%left hippomcapus
atlas = ft_read_atlas(fullfile(ftpath, 'template/atlas/aal/ROI_MNI_V4.nii'));
atlas = ft_convert_units(atlas, 'mm');
atlas.coordsys = 'mni';
cfg            = [];
cfg.inputcoord = 'mni';
cfg.atlas      = atlas;
cfg.roi        = {'Hippocampus_L'};%change name here if other area is interesting
mask_rha = ft_volumelookup(cfg, atlas);


rmpath(genpath('/media/ludovico/DATA/iEEG_Ludo/spm12'))
seg = keepfields(atlas, {'dim', 'unit','coordsys','transform'});
seg.brain = mask_rha;
cfg             = [];
cfg.method      = 'iso2mesh';
cfg.radbound    = 2;
cfg.maxsurf     = 0;
cfg.tissue      = 'brain';
cfg.numvertices = 1000;
cfg.smooth      = 3;
cfg.spmversion  = 'spm12';
mesh_rha2 = ft_prepare_mesh(cfg, seg);

% Define colors for each participant electrodes...

cmap = brewermap(10, 'Paired');

%% Visualize in 3D whole brain
figure;
ft_plot_mesh(template_lh, 'facealpha', 0.1);
ft_plot_mesh(template_rh, 'facealpha', 0.1);
ft_plot_mesh(mesh_rha1, 'facecolor', [0 0.7 1], 'facealpha', 0.2, 'edgealpha', 0)
ft_plot_mesh(mesh_rha2, 'facecolor', [0 0.7 1], 'facealpha', 0.2, 'edgealpha', 0)


% When you load the electrodes, you can use the information from iEEGcorr
% in order to filter only a specific set of a electrode channels.
for subj = 1 : length(subjc)
    ft_plot_sens(elec_mni_fstd(subj), 'fontcolor' , 'white', 'fontsize', 10, 'style',cmap(subj,:), 'elecsize',30);
end

view([110 20]); %change orientation here. [-110 20] to see from the other side
material dull;
lighting gouraud;
camlight;
set(gcf, 'color', 'white');
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');



%% Visualize in 3D only hipp
figure;
% ft_plot_mesh(template_lh, 'facealpha', 0.1);
% ft_plot_mesh(template_rh, 'facealpha', 0.1);
ft_plot_mesh(mesh_rha1, 'facecolor', [0 0.7 1], 'facealpha', 0.2, 'edgealpha', 0)
ft_plot_mesh(mesh_rha2, 'facecolor', [0 0.7 1], 'facealpha', 0.2, 'edgealpha', 0)

% When you load the electrodes, you can use the information from iEEGcorr
% in order to filter only a specific set of a electrode channels.
for subj = 1 : length(subjc)
    ft_plot_sens(elec_mni_fstd(subj), 'fontcolor' , 'white', 'fontsize', 10, 'style',cmap(subj,:), 'elecsize',30);
end

view([-120 40]);
material dull;
lighting gouraud;
camlight;
set(gcf, 'renderer', 'Painters')
set(gcf, 'color', 'white');
%
% %% Visualize in volume space
% figure;
% ft_plot_ortho(mni.anatomy, 'transform', mni.transform, 'style', 'intersect');
% for subj = 1 : length(subjc)
%     ft_plot_sens(elec_mni_fstd(subj), 'label', 'on','fontcolor' , 'white', 'fontsize', 10, 'style',cmap(subj,:), 'elecsize',50);
% end
%
%
% %ft_plot_sens(elec_mni_frv, 'label', 'on', 'fontcolor', 'w','style', 'b');