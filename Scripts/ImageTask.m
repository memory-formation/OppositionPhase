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
Subject = length(TotalSubj)+1;

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
listFolderNames = listFolderNames(2:61);
numberF = length(listFolderNames);
basefilenames = dir();
i=randperm(length(listFolderNames));
FullFile = {};
for k =1:numberF
    thisFolder = listFolderNames{i(k)};
    fprintf(' Processing folder %s\n', thisFolder);
    filePattern =sprintf('%s/*.jpg', thisFolder);
    basefilenames = dir(filePattern);
   % basefilenames = [basefilenames; dir(filePattern)];
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

DrawFormattedText(window, 'Press Space to Begin', 'center',...
    'center', black);
Screen('Flip', window);
KbWait;


%Experimental loop
p=1;
Engagement=[];
OnsetBegin = [];
OnsetImg1 = [];
OnsetImg2 = [];
OnsetImg3 = [];
OnsetImg4 = [];
input1 = [];
input2 = [];
input3 = [];
input4 = [];
OnsetControl = [];
OnsetTimes = [];
for k=1:2
    DrawFormattedText(window, 'New Episode', 'center', 'center', black);
    Screen('Flip', window);
    OnsetBegin = [OnsetBegin GetSecs];
    WaitSecs(1);
    
    for f= 1:4
        
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
        %Send stimulus to the port
        outp(address,byte);
        %Get seconds at each image (onsets)
        OnsetTimes(f) = GetSecs;
        % read back the value written to the printer port above
        input=inp(address);
        WaitSecs(3);
        %iteration of P
        p=p+1;
        
    end
    
    %Put results of each iteration into a matrix
    OnsetImg1 = [OnsetImg1 OnsetTimes(1)];
    OnsetImg2 = [OnsetImg2 OnsetTimes(2)];
    OnsetImg3 = [OnsetImg3 OnsetTimes(3)];
    OnsetImg4 = [OnsetImg4 OnsetTimes(4)];
    input1 = [input1 input(1)];
    input2 = [input2 input(2)];
    input3 = [input3 input(3)];
    input4 = [input4 input(4)];
    
    Screen('FillRect', window, grey);
    Screen('DrawLines', window, allCoords, lineWidthPix, white,...
        [xCenter yCenter], 2);
    Screen ('Flip', window);
    WaitSecs(3);
    
    
    %---------------------------------------------------------------------
    %                      HOW ENGAGING 
    %---------------------------------------------------------------------
 
    
   
    
    targDuration = 5;
    value=[];
    exitTime = GetSecs + targDuration;
    OnsetTime = GetSecs;
    while GetSecs < exitTime
        DrawFormattedText (window,...
            '  How engaging? \n\n 1    2    3    4',...
            'center', 'center', black);
        Screen('Flip', window);
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(key1)
            value=1;
            exitTime = GetSecs;
        elseif keyCode(key2)
            value = 2;
            exitTime = GetSecs;
        elseif keyCode (key3)
            value =3;
            exitTime = GetSecs;
        elseif keyCode(key4)
            value = 4;
            exitTime = GetSecs;
        elseif keyCode(escapeKey)
            k=40
            exitTime = GetSecs;
        end
        Engagement = [Engagement, value];
        
    end
    
    
    %---------------------------------------------------------------------
    %                       Set the control task
    %---------------------------------------------------------------------
    
    DrawFormattedText (window,...
        'New Imagination! Imagine a new sitaution!',...
        'center', 'center', black);
    Screen('Flip', window);
    WaitSecs(1);
    
    Screen('FillRect', window, grey);
    Screen('DrawLines', window, allCoords, lineWidthPix, white,...
        [xCenter yCenter], 2);
    Screen ('Flip', window);
    WaitSecs(1);
        
    ImageLocation = (FantasyImages{k});
    Image = imread(ImageLocation);
    %Turn image into a texture
    imageTexture = Screen('MakeTexture', window, Image);
   
    %resize the image
    [s1, s2, s3]= size(Image);
    aspectratio = s2/s1;
    imageHeight = screenYpixels;
    imageWidth = imageHeight * aspectratio;
    theRect = [0 0 imageWidth imageHeight];
    dstRect = CenterRectOnPointd(theRect, xcenter, ycenter);
        
    %Draw the image to the screen
    Screen('DrawTextures', window, imageTexture, [], dstRect);
    Screen('Flip', window);
    OnsetControl = [OnsetControl GetSecs];
    WaitSecs(10);

    if k==20
        DrawFormattedText(window, 'Press Space to Continue!',...
            'center', 'center', black);
        Screen('Flip', window);
        KbWait;
    end
    
end

    %---------------------------------------------------------------------
    %                            RESULTS HERE
    %---------------------------------------------------------------------
    % Make a  matrix which which will hold all of our results
    resultsMatrix = [];
    resultsMatrix(:, 1) = i';
    resultsMatrix(:, 2) = Engagement;
    resultsMatrix(:, 3) = OnsetBegin;
    resultsMatrix(: ,4) = OnsetImg1;
    resultsMatrix(:, 5) = OnsetImg2; 
    resultsMatrix(:, 6) = OnsetImg3;
    resultsMatrix(:, 7) = OnsetImg4;
    resultsMatrix(:, 8) = OnsetControl;
    resultsMatrix(:, 9) = input1;
    resultsMatrix(:, 10) = input2;
    resultsMatrix(:, 11) = input3;
    resultsMatrix(:, 12) = input4;

    % Make a directory for the results
    resultname = sprintf('/%sSubject_%d', ResultFolder, Subject);
    Results = [cd resultname];
    if exist(Results, 'dir') < 1
          mkdir (Results);
    end
    
    
    filename = sprintf('Subject_%d.mat', Subject);
    path = fullfile(Results, filename);
    save(path, 'resultsMatrix');
    
    filename = sprintf('logfile_encoding');
    path = fullfile(Results, filename);
    save(path);
    
sca;

    