%Core
close all ;
clearvars;
rng('shuffle')
commandwindow;

WhichPC = 'Lab'; %'Ludovico'; %'Ludovico' %path to script: 'C:\manips\TaskDesign'
ArduinoPort = ''; %Change to '' to activate dummy mode if nothing is connected
%and watch into the connected devices to see on what port the arduino is
%connected

%Name Folders for later Use
switch WhichPC
    case 'Ludovico'
        Home = 'C:\Users\Ludovico\Documents\MATLAB\TaskDesign_Salpe';
        addpath('C:\Users\Ludovico\Documents\MATLAB\TaskDesign_Salpe\ArduinoPort')
    case 'epimicro'
        Home = 'C:\manips\TaskDesign';
        addpath('C:\MATLAB_toolboxes\ArduinoPort')
    case 'Lab'
        Home = 'C:\Users\UB\Desktop\iEEG_Ludo\TaskDesign_Salpe';
        addpath ( 'C:\Users\UB\Desktop\iEEG_Ludo\TaskDesign_Salpe\ArduinoPort')
end
CloseArduinoPort
Fantasy      = 'FantasyImages';
Task         = 'ImagesTask';
ResultFolder = 'Results';

% OpenArduinoPort('COM3') (Look into the windows10 peripheriques)'com3') can change at each PC start
OpenArduinoPort(ArduinoPort) %if no arduino connected

%Setup PTB with default settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 2);

cd(Home)
%Define number of subject
TotalSubj   = dir('Results/Subj*'); %dir(fullfile('Results','Subj*'))
Subject     = length(TotalSubj);

%Set the keyboard info
spaceKey    = KbName('space');
escapeKey   = KbName('ESCAPE');
key1        = KbName('1');
key2        = KbName('2');
key3        = KbName('3');
key4        = KbName('4');

esc      =0 ;
Triggers =[];
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
Screen('TextSize', window, 40);

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

Imagesfolder = fullfile(Home, Task);%('%s%s', Home, Task);
topLevelFolder =(Imagesfolder);
if topLevelFolder == 0
    return;
end
SubFolders = genpath(topLevelFolder);
remain = SubFolders;
listFolderNames ={};
while true 
    [singleSubFolder, remain] = strtok(remain, ';');
    if isempty(singleSubFolder)
        break;
    end
    listFolderNames= [listFolderNames singleSubFolder];
end

%List of all subfolders containing images

listFolderNames             = listFolderNames(2:61);
%Randomize order of the folders in order to always have 3 different lists
%for the 3 sessions
randimages                  = randperm(60);
ListFolderNamesAll = {};
for k = 1:length(randimages)
    ListFolderNamesAll(k)   = listFolderNames(randimages(k));
end 
 

%Generate 3 lists for 3 sessions
Session1                    = ListFolderNamesAll(1:20);
Session2                    = ListFolderNamesAll(21:40);
Session3                    = ListFolderNamesAll(41:60);
OrderSeriesEncoding         = randimages';
seriesnumber = extractAfter(ListFolderNamesAll(1, :), 'ImagesTask\');
seriesnumber = str2double(seriesnumber);
seriesnumber = seriesnumber';
seriesnumber(:, 2) = 1:60;


 RecallDay2.Session1        = Session1;
 RecallDay2.Session2        = Session2;
 RecallDay2.Session3        = Session3;
 
 Results = fullfile(cd, ResultFolder, sprintf('Subject_%d',Subject));
if exist(Results, 'dir') < 1
    mkdir (Results);
end
filename                    = sprintf('RecallDay2.mat');
path2save                   = fullfile(Results, filename);
save(path2save, 'RecallDay2');
StructOutput.Day            = 2;
StructOutput.Enc            = 0;
%-------------------------------------------------------------------------
%                          Define Fixation Cross
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


  ResultsDay2.Recall           = [];
  ResultsDay2.TriggersRecall   = [];

for session = 1:3
    p=1;
   
    %----------------------------------------------------------------------
    %                        Values for Recall Task
    %----------------------------------------------------------------------
    TriggersRecall                  = [];
    StructOutput.Session            = session;
    RecallDay2.Recall               = [];
    RecallDay2.TriggersRecall       = [];
    
    %List of folder names to get the images in function fo the session
    %number.
    
    if session == 1
        listFolderNames             = Session1;
        recallseries                = seriesnumber (1:20, 1);
    elseif session ==2
        listFolderNames             = Session2;
        recallseries                = seriesnumber (21:40, 1);
    elseif session == 3
        listFolderNames             = Session3;
        recallseries                = seriesnumber (41:60, 1);
    end
    
    numberF = length(listFolderNames);
    basefilenames = dir();
    FullFile = {};
    for k =1:numberF
        thisFolder = listFolderNames{k};
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
    
     %Start Screen
   


    DrawFormattedText(window, 'Appuyez sur Espace pour commencer', 'center',...
    'center', black);
    TriggersRecall = [TriggersRecall; [120 GetSecs]];
    SendArduinoTrigger(120);
    TriggersRecall = [TriggersRecall; [29 GetSecs]];
    SendArduinoTrigger(29);
    TriggersRecall = [TriggersRecall; [4 GetSecs]];
    SendArduinoTrigger(4);
    Screen('Flip', window);
    KbWait;

    %Experimental loop
    p = 1;

    for k=1:20
        
    StructOutput.Order                      = k;
    DrawFormattedText(window, 'Nouveau Souvenir', 'center', 'center', black);
    Screen('Flip', window);
    TriggersRecall = [TriggersRecall; [35 GetSecs]];
    SendArduinoTrigger(35);
    WaitSecs(1);
    
        %Draw a fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        Screen ('Flip', window);
        TriggersRecall = [TriggersRecall; [40 GetSecs]];
        SendArduinoTrigger(40);
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
        %Flip image
        Screen('Flip', window);
         %Output trigger
        TriggersRecall = [TriggersRecall; [50 GetSecs]];
        SendArduinoTrigger(50);
        WaitSecs(3);
       
        
        %Draw a fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        TriggersRecall = [TriggersRecall; [40 GetSecs]];
        SendArduinoTrigger(40);
        Screen ('Flip', window);
        WaitSecs(1);
        %Get response time of event recall
        targetDuration = 80;
        exitTime = GetSecs + targetDuration;
        GotResponse = 0;
        if GotResponse==0;  
            DrawFormattedText(window,...
            'Pouvez vous retrouver le souvenir?' ,'center',...
            'center', black);
            TriggersRecall = [TriggersRecall; [55 GetSecs]];
            SendArduinoTrigger(55);
            Screen('Flip', window);
             while GetSecs < exitTime
                 [keyIsDown,secs, KeyCode] = KbCheck; 
                 if KeyCode(spaceKey)
                     gotResponse =1;
                     response = find(KeyCode);
                     response = response(1);
                     exitTime = GetSecs;
                     break;
                 elseif KeyCode (escapeKey)
                     esc=1;
                     break;
                     while KbCheck;
                     end
                 end
             end
             TriggersRecall = [TriggersRecall; [60 GetSecs]];
             SendArduinoTrigger(60);
             if esc==1
                 sca;
                 break
             end
        end
        
        %iteration of P
        p=p+4;
        if esc ==1
            sca;
           break;
        end
        
        %Results for each series with overwriting in case of crash. 
        RecallSession.Results(k,1) = recallseries(k);
        RecallSession.Results(k,2) = k;
        RecallSession.Triggers = TriggersRecall;
        
        filename    = sprintf('RecallSession%d_Day2.mat', session);
        path2save   = fullfile(Results, filename);
        save(path2save, 'RecallSession');
    end
    
    
 %-------------------------------------------------------------------------
 %                          Results for each session
 %-------------------------------------------------------------------------
 
   ResultsDay2.Recall           = [ResultsDay2.Recall RecallSession.Results];
   ResultsDay2.TriggersRecall   = [ResultsDay2.TriggersRecall ; RecallSession.Triggers];
 
    %Make a pause 
     DrawFormattedText(window, 'Pause, appuyez sur espace pour continuer!',...
            'center', 'center', black);
        TriggersRecall = [TriggersRecall; [100 GetSecs]];
        SendArduinoTrigger(100);
        Screen('Flip', window);
        KbWait;
       
        if session ==1
            TriggersSession1Recall = TriggersRecall;
        elseif session == 2
            TriggersSession2Recall = TriggersRecall;
        elseif session == 3
            TriggersSession3Recall = TriggersRecall; 
        end
        if esc == 1
            sca; 
            break
        end
end

%--------------------------------------------------------------------------
%                              Results
%--------------------------------------------------------------------------

TriggersRecall= [TriggersRecall; [66 GetSecs]];
SendArduinoTrigger(66);
TriggersRecall = [TriggersRecall; [6 GetSecs]];
SendArduinoTrigger(6);

% resultname = sprintf('/%sSubject_%d', ResultFolder, Subject);
% Results = fullfile(cd, resultname);

filename = sprintf ( 'RecallDay2.mat');
path2save = fullfile(Results, filename);
save(path2save, 'RecallDay2');

% filename = fullfile(Results,sprintf('logfile_day2'));
path2save = fullfile(Results, sprintf('logfile_day2'));
save(path2save);

CloseArduinoPort