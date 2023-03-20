%Core
close all ;
clearvars;
commandwindow; 
%Setup PTB with default settings
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

%Name Folders for later Use
Home = ('C:\Users\Ludovico\Documents\MATLAB\TaskDesign\');
Fantasy = ('FantasyImages/');
Task = ('SampleImages');
ResultFolder = ('Results/');
cd C:\Users\Ludovico\Documents\MATLAB\TaskDesign\

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
%List of all subfolders containing images

listFolderNames = listFolderNames(2:3);

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

%-------------------------------------------------------------------------
%                           Experimental Task
%-------------------------------------------------------------------------

%Start Screen

DrawFormattedText(window, 'Appuyer sur Espace pour commencer', 'center',...
    'center', black);
Screen('Flip', window);
KbWait;

 
    %----------------------------------------------------------------------
    %                      Values for Encoding Task
    %----------------------------------------------------------------------
    
    %Have all basic values reset
    %Iteration for each image in each session
    p=1;
    %Engagement value
    Engagement=[];
    %Onsets and stimuli imput to the print port
    OnsetBegin = [];
    OnsetImg1 = [];
    OnsetImg2 = [];
    OnsetImg3 = [];
    OnsetImg4 = [];
    input1 = [];
    input2 = [];
    input3 = [];
    input4 = [];
    OnsetTimes = [];
    
    
   %----------------------------------------------------------------------
   %                    Experimental Task
   %----------------------------------------------------------------------
    
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
    for k=1:2
        DrawFormattedText(window, 'New Episode', 'center', 'center', black);
        Screen('Flip', window);
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
            WaitSecs(2.5);
            %iteration of P
            p=p+1;
        end
        
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix, white,...
        [xCenter yCenter], 2);
        Screen ('Flip', window);
        WaitSecs(3);
    
    %---------------------------------------------------------------------
    %                      HOW ENGAGING 
    %---------------------------------------------------------------------
 
    
   
    
        targDuration = 3;
        value=[];
        esc=0;
        exitTime = GetSecs + targDuration;
        OnsetTime = GetSecs;
        GotResponse =0;
        while GetSecs < exitTime
            DrawFormattedText (window,...
            '  Combien etait-ce engageant? \n\n 1    2    3    4',...
            'center', 'center', black);
            Screen('Flip', window);
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(key1)
                value=1;
                exitTime = GetSecs;
                GotResponse = 1;
            elseif keyCode(key2)
                value = 2;
                exitTime = GetSecs;
                GotResponse = 1;
            elseif keyCode (key3)
                value =3;
                exitTime = GetSecs;
                GotResponse = 1;
            elseif keyCode(key4)
                value = 4;
                exitTime = GetSecs;
                GotResponse = 1;
            elseif keyCode(escapeKey)
                esc=1;
              break
                exitTime = GetSecs;
            elseif GotResponse == 0
                value = nan;
            end
            Engagement = [Engagement, value];
        end
        if esc== 1
            break
        end
    end
    
     %----------------------------------------------------------------------
    %Pause between encoding and Recall
     DrawFormattedText(window, 'Appuyez sur espace pour aller a la tache souvenir',...
         'center', 'center', black);
        Screen('Flip', window);
    KbWait;
    
    %----------------------------------------------------------------------
    %                            Recall Task
    %----------------------------------------------------------------------
    
     %Make list of images for the Recall Task
    
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
    
    
    %Start Screen
    %exitTime = GetSecs + 30; 
    %DrawFormattedText(window,...
    %'Is this the first or second time you recall images?', 'center',...
    %'center', black);
    %Screen('Flip', window)       
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


    DrawFormattedText(window, 'Appuyer sur Espace pour commencer la tâche souvenir', 'center',...
    'center', black);
    Screen('Flip', window);
    WaitSecs(1);
    KbWait;
    
    %Experimental loop
    p=1;
    OnsetImg =[];
    OnsetResponse =[];
    input = [];

    for k=1:2
    
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
        %outp(address,byte);
        %onsets for each image presented
        %OnsetImg = [OnsetImg GetSecs];
        % read back the value written to the printer port above
       % input= [input inp(address)];
        WaitSecs(3);
        
        %Draw a fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        Screen ('Flip', window);
        WaitSecs(1);
        %Get response time of event recall
        %OnsetTime = GetSecs;
        targetDuration = 20;
        exitTime = GetSecs + targetDuration;
        %ReactionTime = [];
        GotResponse = 0;
        if GotResponse==0;  
            DrawFormattedText(window,...
            'Vous souvenez-vous de l episode?\n\n\n Appuyer sur Espace quand terminé' ,'center',...
            'center', black);
            Screen('Flip', window);
            ResponseTime = [];
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
                 elseif KeyCode(escapeKey)
                     esc=1;
                     break;
                     while KbCheck;
                     end
                 end
             end
             if esc==1
                     break
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
    sca;