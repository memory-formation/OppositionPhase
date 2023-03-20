%Core
close all ;
clearvars;
commandwindow; 
% initialize access to the inpoutx64 low-level I/O driver
config_io;
% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
% write a value to the default LPT1 printer output port (at 0x378)
address = hex2dec('378');
byte = 99;

%Setup PTB with default settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

%Name Folders for later Use
Home = ('C:\Users\Ludovico\Documents\MATLAB\TaskDesign\');
Fantasy = ('FantasyImages/');
Task = ('ImagesTask');
ResultFolder = ('Results/');

%Define number of subject
TotalSubj = dir('Results/Subj*');
Subject = length(TotalSubj);

%Set the keyboard info
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
key1 = KbName('1');
key2 = KbName('2');
key3 = KbName('3');
key4 = KbName('4');

%-------------------------------------------------------------------------
%                               SCREEN SETUP
%-------------------------------------------------------------------------

screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

%open the screen
[window, windowRect] = PsychImaging('OpenWindow',...
    screenNumber, grey, [], 32, 2);
Screen('Flip', window);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xcenter, ycenter] = RectCenter(windowRect);
%frame duration
ifi = Screen ('GetFlipInterval', window);

%Set text size
Screen('TextSize', window, 60);

%Query the maximum priority level
topPriorityLevel= MaxPriority(window);

%Centre coordinates fo the window
[xCenter, yCenter] = RectCenter(windowRect);

%Set the Blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%-------------------------------------------------------------------------
%                             TIMING INFORMATION
%-------------------------------------------------------------------------

%Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

%Numer of frames to wait before re-drawing
waitframes = 1;

%How long should the image stay up during flicker in time and frames
imageSecs = 1;
imageFrames = round(imageSecs / ifi);

%Duration (in seconds) of the blanks between the images during flicker
blankSecs = 0.25;
blankFrames = round(blankSecs / ifi);

%Make a vector which shows what we do on each frame
presVector = [ones(1, imageFrames) zeros(1, blankFrames)...
    ones(1, imageFrames) .*2 zeros(1, blankFrames)];
numPresLoopFrames = length(presVector);

%-------------------------------------------------------------------------
%                          Experimental image list
%-------------------------------------------------------------------------

%Get the image files for the experiment and randomize the series 
%the files will be in order (1/2/3/4) but the series will be randomized
%each time

Imagesfolder = sprintf('%s%s', Home, Task);
topLevelFolder =(Imagesfolder);
if topLevelFolder == 0
    return;
end
SubFolders = genpath(topLevelFolder);
remain = SubFolders;
listFolderNames ={};
while true 
    [singleSubFolder, remain] =strtok(remain, ';');
    if isempty(singleSubFolder)
        break;
    end
    listFolderNames= [listFolderNames singleSubFolder];
end
listFolderNames = listFolderNames(2:41);
numberF = length(listFolderNames);
basefilenames = dir();
i=randperm(length(listFolderNames));
FullFile = {};
for k =1:numberF
    thisFolder = listFolderNames{i(k)};
    fprintf(' Processing folder %s\n', thisFolder);
    filePattern =sprintf('%s/*.jpg', thisFolder);
    basefilenames = dir(filePattern);
    numberoffiles = length (basefilenames);
    if numberoffiles >= 1
        for f=1:numberoffiles
            fullfilename = fullfile(thisFolder, basefilenames(f).name);
            fprintf('Processing image file %s\n', fullfilename);
            FullFile = [FullFile, fullfilename];
        end
    else 
        fprintf('Folder %s has no image in it \n', thisFolder);
    end
end
FullFile = FullFile';

%-------------------------------------------------------------------------
%                       Get the control task images
%-------------------------------------------------------------------------
fantrand = randperm(50)';
FantasyImages={};

    FantasyFolder = sprintf('%s%s', Home, Fantasy);
    Files = sprintf('%s*.jpg', FantasyFolder);
    fantasy = dir(Files);
for k=1:length(fantrand)
    fantasyfilename = fullfile(FantasyFolder, fantasy(fantrand(k)).name);
    FantasyImages = [FantasyImages, fantasyfilename];
end

%-------------------------------------------------------------------------
%                              Fixation Cross
%-------------------------------------------------------------------------

% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

%-------------------------------------------------------------------------
%                           Experimental Task
%-------------------------------------------------------------------------

%Start Screen
exitTime = GetSecs + 30; 
     DrawFormattedText(window,...
     'Is this the first or second time you recall images?', 'center',...
     'center', black);
     Screen('Flip', window)       
     while GetSecs < exitTime
        [keyIsDown,secs, KeyCode] = KbCheck; 
        if KeyCode(key1)
            Recall = 1;
            exitTime = GetSecs;
        elseif KeyCode(key2)
            Recall = 2;
            exitTime = GetSecs;
        end
     end


DrawFormattedText(window, 'Press Space to Begin', 'center',...
    'center', black);
Screen('Flip', window);
KbWait;

%Experimental loop
p=1;
OnsetImg =[];
OnsetResponse =[];
input = [];
for k=1:40
    
    DrawFormattedText(window, 'New Recall', 'center', 'center', black);
    Screen('Flip', window);
    WaitSecs(1);
    
        %Draw a fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        Screen ('Flip', window);
        WaitSecs(1);
    
        %Get Image Location
        ImageLocation = (FullFile{p});
        Image = imread(ImageLocation);
    
        %Turn image into a texture
        imageTexture = Screen('MakeTexture', window, Image);
    
        %resize the image
        [s1, s2, s3]= size(Image);
        aspectratio = s2/s1;
        imageHeight = screenYpixels/1.5;
        imageWidth = imageHeight * aspectratio;
        theRect = [0 0 imageWidth imageHeight];
        dstRect = CenterRectOnPointd(theRect, xcenter, ycenter);
        
        %Draw the image to the screen
        Screen('DrawTextures', window, imageTexture, [], dstRect);
        Screen('Flip', window);
        %ouput value stimulus
        outp(address,byte);
        %onsets for each image presented
        OnsetImg = [OnsetImg GetSecs];
        % read back the value written to the printer port above
        input= [input inp(address)];
        WaitSecs(3);
        
        %Draw a fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        Screen ('Flip', window);
        WaitSecs(1);
        %Get response time of event recall
        OnsetTime = GetSecs;
        targetDuration = 20;
        exitTime = GetSecs + targetDuration;
        ReactionTime = [];
        GotResponse = 0;
        if GotResponse==0;  
            DrawFormattedText(window,...
            'Recall episode?\n\n\n Press space when finished' ,'center',...
            'center', black);
            Screen('Flip', window);
            OnsetTime = GetSecs;
             while GetSecs < exitTime
                 [keyIsDown,secs, KeyCode] = KbCheck; 
                 if KeyCode(spaceKey)
                     gotResponse =1;
                     response = find(KeyCode);
                     response = response(1);
                     ResponseTime = GetSecs;
                     exitTime = GetSecs;
                     break;
                     while KbCheck;
                     end
                 end
             end
             OnsetResponse = [OnsetResponse OnsetTime];
             if GotResponse ~=1
                 RT(k) = (ResponseTime - OnsetTime);
             else
                 RT(k) = nan;
             end
        end
        
        %iteration of P
        p=p+4;
        
     
end

%----------------------------------------------------------------------
%                           Results here
%----------------------------------------------------------------------

resultname = sprintf('/%sSubject_%d', ResultFolder, Subject);
Results = [cd resultname];

Encodingresults = sprintf('%s%sSubject_%d/Subject_%d.mat', Home, ResultFolder, Subject, Subject);
load (Encodingresults);
if Recall == 1
    resultsMatrix (:,13) = i;
    resultsMatrix (:,14) = RT;
    resultsMatrix (:,15) = OnsetImg;
    resultsMatrix (:,16) = OnsetResponse;
    resultsMatrix (:,17) = input;
    filename = sprintf('logfile_recall_1');
    path = fullfile(Results, filename);
    save(path);
elseif Recall == 2
    resultsMatrix (:,18) = i;
    resultsMatrix (:,19) = RT;
    resultsMatrix (:,20) = OnsetImg;
    resultsMatrix (:,21) = OnsetResponse;
    resultsMatrix (:,22) = input;
    filename = sprintf('logfile_recall_2');
    path = fullfile(Results, filename);
    save(path);
end

    filename = sprintf('/Subject_%d.txt', Subject);
    path = fullfile(Results, filename);
    file = fopen(path, 'w');
    
    for ii=1:size(resultsMatrix)
        fprintf(file, '%g\t', resultsMatrix(ii, :));
        fprintf(file, '\n');
    end
    fclose(file)
    
    filename = sprintf('Subject_%d.mat', Subject);
    path = fullfile(Results, filename);
    save(path, 'resultsMatrix');
    
   
    
sca;