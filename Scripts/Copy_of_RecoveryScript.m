%% Intro
%This is a recovery script in case of crash or any problem during a session
%in day 1 or 2. All the information necessary for this script to function
%has already been saved by the scripts day1 and day2. You only need to
%click "run" and this recovery script will do everything. Script created by
%Ludovico Saint Amour di Chanaz 14/11/2018, for any further information
%contact ludovico.s-adichanaz@hotmail.it. 

%% Core
close all ;
clearvars;
rng('shuffle')
commandwindow;

WhichPC = 'Lab'; %'Ludovico'; %'Ludovico' %path to script: 'C:\manips\TaskDesign'
ArduinoPort = ''; %'' if dummy mode
%(Look into the windows10 peripheriques)'com3') can change at each PC start

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

Fantasy      = 'FantasyImages';
Task         = 'ImagesTask';
ResultFolder = 'Results';

OpenArduinoPort(ArduinoPort); %if no arduino connected

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

screenNumber   = max(Screen('Screens'));
white          = WhiteIndex(screenNumber);
black          = BlackIndex(screenNumber);
grey           = white/2;

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
topPriorityLevel = MaxPriority(window);

%Centre coordinates fo the window
[xCenter, yCenter] = RectCenter(windowRect);

%Set the Blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%-------------------------------------------------------------------------
%                             TIMING INFORMATION
%-------------------------------------------------------------------------

%Interstimulus interval time in seconds and frames
isiTimeSecs   = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

%Numer of frames to wait before re-drawing
waitframes = 1;

%How long should the image stay up during flicker in time and frames
imageSecs   = 1;
imageFrames = round(imageSecs / ifi);

%Duration (in seconds) of the blanks between the images during flicker
blankSecs   = 0.25;
blankFrames = round(blankSecs / ifi);

%Make a vector which shows what we do on each frame
presVector = [ones(1, imageFrames) zeros(1, blankFrames)...
    ones(1, imageFrames) .*2 zeros(1, blankFrames)];
numPresLoopFrames = length(presVector);

%% Fixation cross
%-------------------------------------------------------------------------
%                          Define Fixation Cross
%-------------------------------------------------------------------------

% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords   = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords   = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;


%% Load important information
Results                     = fullfile(cd, ResultFolder, sprintf('Subject_%d',Subject));
filename                    = sprintf('StructOutput.mat');
load(fullfile(Results, filename));

filename                    = sprintf('Encoding.mat');
load(fullfile(Results, filename));

%Define important variables from what was loaded before loading the day 1
%or 2 data. 

Day                         = StructOutput.Day;
session                     = StructOutput.Session;
Enc                         = StructOutput.Enc;
Order                       = StructOutput.Order;
Session1                    = Encoding.Session1;
Session2                    = Encoding.Session2;
Session3                    = Encoding.Session3;
if Day == 1
    ResultsRecovery.Encoding            = [];
    ResultsRecovery.TriggersEncoding    = [];
end
ResultsRecovery.Recall                  = [];
ResultsRecovery.TriggersRecall          = [];

if Day == 1
    filename                = sprintf('RecallDay1.mat');
    load(fullfile(Results, filename));
    RecallSession1          = RecallDay1.Session1;
    RecallSession2          = RecallDay1.Session2;
    RecallSession3          = RecallDay1.Session3;
elseif Day == 2    
    filename                = sprintf('RecallDay2.mat');
    load(fullfile(Results, filename));
    RecallSession1          = RecallDay2.Session1;
    RecallSession2          = RecallDay2.Session2;
    RecallSession3          = RecallDay2.Session3;
end

%Start Screen

DrawFormattedText(window, 'Appuyer sur Espace pour commencer', 'center',...
    'center', black);
Screen('Flip', window);
KbWait;
Begin    = GetSecs;

for s = session:3
    
    %----------------------------------------------------------------------
    %                      Values for  Tasks
    %----------------------------------------------------------------------
    
    % Have all basic values reset 
    %Reset of p iteration
    p               = 1 + Order*4 -4
    %Send triggers to signal the beginning of a session
    Triggers                        = [Triggers; [120 GetSecs]];
    SendArduinoTrigger(120);
    Triggers                        = [Triggers; [29 GetSecs]];
    SendArduinoTrigger(29);
    Triggers                        = [Triggers; [4 GetSecs]];
    SendArduinoTrigger(4);
    
    %Reset the values necessary to write the results of each session.
    Engagement                          = [];
    Triggers                            = [];                   
    EncodingResults                     = [];                
    EncodingTriggers                    = [];              
    EncodingSession.Results             = [];
    EncodingSession.Triggers            = [];
    RecallResults                       = [];
    TriggersRecall                      = [];
    
    
    if Enc == 1 & Day == 1
        
    %% Encoding Task
        t                               = 1;
        StructOutput.Session            = session;
        StructOutput.Enc                = 1;  
        %List of folder names to get the images in function of the session
        %number.
    
        if session == 1
            listFolderNames             = Session1;
            series                      = extractAfter(listFolderNames(1, :), 'ImagesTask\');
            series                      = str2double(series);
            series                      = series';
            series(:, 2)                = 1:20;
        elseif session == 2
            listFolderNames = Session2;
            series                      = extractAfter(listFolderNames(1, :), 'ImagesTask\');
            series                      = str2double(series);
            series                      = series';
            series(:, 2)                = 1:20;
        elseif session == 3
            listFolderNames = Session3;
            series                      = extractAfter(listFolderNames(1, :), 'ImagesTask\');
            series                      = str2double(series);
            series                      = series';
            series(:, 2)                = 1:20;
        end
    
        numberF                         = length(listFolderNames);
        basefilenames                   = dir();
        FullName                        = {};
        for k =1:numberF
            thisFolder                  = listFolderNames{k};
            fprintf(' Processing folder %s\n', thisFolder);
            filePattern                 = sprintf('%s/*.jpg', thisFolder);
            basefilenames               = dir(filePattern);
            % basefilenames = [basefilenames; dir(filePattern)];
            numberoffiles               = length (basefilenames);
            if numberoffiles            >= 1
                for f=1:numberoffiles
                    fullfilename        = fullfile(thisFolder, basefilenames(f).name);
                    fprintf('Processing image file %s\n', fullfilename);
                    FullName            = [FullName, fullfilename];
                end
            else
                fprintf('Folder %s has no image in it \n', thisFolder);
            end
        end
        FullName                        = FullName';
    
        for k = Order: 20
            DrawFormattedText(window, 'Nouvel Episode', 'center', 'center', black);
            Screen('Flip', window);
            Triggers = [Triggers; [15 GetSecs]];
            SendArduinoTrigger(15);
%           OnsetBegin = [OnsetBegin GetSecs-Begin];
            WaitSecs(1);
        
            outputval=10;
        
            %Define an output structure with the characteristics of teh
            %session, encoding or retrieval and which series in order to
            %retrieve everything in case of a crash. 
        
        
            StructOutput.Order   = k;
            filename = sprintf('StructOutput.mat');
            path2save = fullfile(Results, filename);
            save(path2save, 'StructOutput');
        
            %Send trigger corresponding to a 100 to announce a new series, then
            %a trigger corresponding to the series number, in case anything
            %goes wrong in the script the information can still be recovered in
            %the data. 
        
            Triggers = [Triggers; [100 GetSecs]];
            SendArduinoTrigger(100);
            Triggers = [Triggers; [series(k) GetSecs]];
            SendArduinoTrigger(series(k));
        
            for f= 1:4
                %             %port to 0
                %             io64(port, address, 0);
                %Draw a fixation cross
            
                Screen('FillRect', window, grey);
                Screen('DrawLines', window, allCoords, lineWidthPix,...
                    white, [xCenter yCenter], 2);
                Screen ('Flip', window);
                Triggers = [Triggers; [20 GetSecs]];
                SendArduinoTrigger(20);
                WaitSecs(1);
            
                %Get Image Location
                ImageLocation = (FullName{p});
                Image = imread(ImageLocation);
            
                %Turn image into a texture
                imageTexture = Screen('MakeTexture', window, Image);
            
                %resize the image
                [s1, s2, s3]                    = size(Image);
                aspectratio                     = s2/s1;
                imageHeight                     = screenYpixels/1.5;
                imageWidth                      = imageHeight * aspectratio;
                theRect                         = [0 0 imageWidth imageHeight];
                dstRect                         = CenterRectOnPointd(theRect, xcenter, ycenter);
            
                %Draw the image to the screen
                Screen('DrawTextures', window, imageTexture, [], dstRect);
                Screen('Flip', window);
                %Send stimulus to the port
                Triggers                        = [Triggers; [outputval GetSecs]];
                SendArduinoTrigger(outputval);
                outputval                       = outputval+1;
                WaitSecs(2.5);
                %iteration of P
                p                               = p+1;
            end
        
        
            % Fixation cross
       
            Screen('FillRect', window, grey);
            Screen('DrawLines', window, allCoords, lineWidthPix, white,...
                [xCenter yCenter], 2);
            Screen ('Flip', window);
            Triggers = [Triggers; [20 GetSecs]];
            SendArduinoTrigger(20);
            WaitSecs(2);
        
        
        %---------------------------------------------------------------------
        %                      HOW ENGAGING
        %---------------------------------------------------------------------
        
        
        
        
            targDuration                        = 4;
            value                               = [];
            exitTime                            = GetSecs + targDuration;
            OnsetTime                           = GetSecs;
            GotResponse                         = 0;
            Triggers                            = [Triggers; [25 GetSecs]];
            SendArduinoTrigger(25);
            while GetSecs < exitTime
                DrawFormattedText (window,...
                '  Combien etait-ce engageant? \n\n 1    2    3    4',...
                'center', 'center', black);
                Screen('Flip', window);
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(key1)
                    value                       = 1;
                    exitTime                    = GetSecs;
                    GotResponse                 = 1;
                elseif keyCode(key2)
                    value                       = 2;
                    exitTime                    = GetSecs;
                    GotResponse                 = 1;
                elseif keyCode (key3)
                    value                       = 3;
                    exitTime                    = GetSecs;
                    GotResponse                 = 1;
                elseif keyCode(key4)
                    value                       = 4;
                    exitTime                    = GetSecs;
                    GotResponse                 = 1;
                elseif keyCode(escapeKey)
                    esc                         = 1;
                    break
                    exitTime                    = GetSecs;
                end  
            end
            Triggers = [Triggers; [26 GetSecs]];
            SendArduinoTrigger(26);
            if GotResponse == 0
                value = 0;
            end
        
            Engagement                          = [Engagement, value];
            EncodingResults(t , 1)              = series(k);
            EncodingResults(t , 2)              = k;
            EncodingResults(t , 3)              = Engagement(t);
            EncodingResults(: , 4)              = session;
            EncodingSession.Results             = EncodingResults;
            EncodingSession.Triggers            = Triggers;
            t                                   = t +1;
        
            filename    = sprintf('RecoveryEncodingSession%d.mat', session);
            path2save   = fullfile(Results, filename);
            save(path2save, 'EncodingSession');
            if esc == 1
                sca;
                break
            end  
        end
        
         
        DrawFormattedText(window, 'Appuyer sur une touche pour continuer vers la tâche souvenir',...
        'center', 'center', black);
        Screen('Flip', window);
        Triggers = [Triggers; [100 GetSecs]];
        SendArduinoTrigger(100);
        WaitSecs (1);
        KbWait;
        Enc                             = 0;
        Order = 1;
        
    
    elseif Enc == 0
        %% RecallTask
%--------------------------------------------------------------------------
%                               RECALL TASK
%--------------------------------------------------------------------------
        
    if session == 1
        listFolderNames     = RecallSession1;
        recallseries        = extractAfter(listFolderNames(1, :), 'ImagesTask\');
        recallseries        = str2double(recallseries); 
    elseif session ==2
        listFolderNames     = RecallSession2;
        recallseries        = extractAfter(listFolderNames(1, :), 'ImagesTask\');
        recallseries        = str2double(recallseries);   
    elseif session == 3
        listFolderNames     = RecallSession3;
        recallseries        = extractAfter(listFolderNames(1, :), 'ImagesTask\');
        recallseries        = str2double(recallseries);
    end
    
    %Make list of images for the Recall Task
    
    numberF = length(listFolderNames);
    basefilenames = dir();
    FullName = {};
    for k =1:numberF
        thisFolder = listFolderNames{k};
        fprintf(' Processing folder %s\n', thisFolder);
        filePattern =sprintf('%s/*.jpg', thisFolder);
        basefilenames = dir(filePattern);
        numberoffiles = length (basefilenames);
        if numberoffiles >= 1
            for f=1:numberoffiles
                fullfilename = fullfile(thisFolder, basefilenames(f).name);
                fprintf('Processing image file %s\n', fullfilename);
                FullName = [FullName, fullfilename];
            end
        else
            fprintf('Folder %s has no image in it \n', thisFolder);
        end
    
    end
  
    FullName = FullName';
    
    DrawFormattedText(window, 'Appuyer sur Espace pour commencer', 'center',...
        'center', black);
    Screen('Flip', window);
    Triggers = [Triggers; [30 GetSecs]];
    SendArduinoTrigger(30);
    WaitSecs(1);
    KbWait;
    
    %Experimental loop and var changes in case of crash. 
    StructOutput.Enc    = 0;
    p                   = 1 + Order*4 -4
    t                   = 1;
    
    for k= Order:20
        
        DrawFormattedText(window, 'Nouveau Souvenir', 'center', 'center', black);
        Screen('Flip', window);
        TriggersRecall = [TriggersRecall; [35 GetSecs]];
        SendArduinoTrigger(35);
        StructOutput.Order   = k;
        filename =  sprintf('StructOutput.mat');
        path2save = fullfile(Results, filename);
        save(path2save, 'StructOutput');
        
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
        ImageLocation = (FullName{p});
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
        TriggersRecall = [TriggersRecall; [50 GetSecs]];
        SendArduinoTrigger(50);
        WaitSecs(3);
        
        %Fixation cross
        Screen('FillRect', window, grey);
        Screen('DrawLines', window, allCoords, lineWidthPix,...
            white, [xCenter yCenter], 2);
        Screen ('Flip', window);
        TriggersRecall = [TriggersRecall; [40 GetSecs]];
        SendArduinoTrigger(40);
        WaitSecs(1);
        %Get response time of event recall
        OnsetTime = GetSecs;
        targetDuration = 80;
        exitTime = GetSecs + targetDuration;
        ReactionTime = [];
        GotResponse = 0;
        if GotResponse==0
            DrawFormattedText(window,...
                'Vous souvenez-vous de l episode?\n\n\n Appuyer sur espace quand terminé' ,'center',...
                'center', black);
            Screen('Flip', window);
            TriggersRecall = [TriggersRecall; [55 GetSecs]];
            SendArduinoTrigger(55);
            ResponseTime = [];
            OnsetTime = GetSecs;
            while GetSecs < exitTime
                [keyIsDown,secs, KeyCode] = KbCheck;
                if KeyCode(spaceKey)
                    GotResponse =1;
                    response = find(KeyCode);
                    response = response(1);
                    ResponseTime = GetSecs;
                    exitTime = GetSecs;
                    break;
                elseif KeyCode(escapeKey)
                    esc=1;
                    break;
                end
            end
            TriggersRecall = [TriggersRecall; [60 GetSecs]];
            SendArduinoTrigger(60);
            if esc==1
                break
            end
        end
         
        %iteration of P
        p=p+4;
        %Results for each series with overwriting in case of crash. 
        RecallSession.Results(t,1)      = recallseries(k);
        RecallSession.Results(t,2)      = k;
        RecallSession.Triggers          = TriggersRecall;
        
        filename    = sprintf('RecoveryRecallSession%d.mat', session);
        path2save   = fullfile(Results, filename);
        save(path2save, 'RecallSession');
        t                               = t + 1;
    end    
        if Day == 1
            Enc                             = 1;
        end
        Order                               = 1;
    end
    %% Session results
    %------------------------------------------------------------------
    %                      Results for each Session
    %------------------------------------------------------------------
    %Put the results under the form of numbers down here to have an
    %overview of the general results.
    if Day == 1
        ResultsRecovery.Encoding            = [ResultsRecovery.Encoding EncodingResults];
        ResultsRecovery.TriggersEncoding    = [ResultsRecovery.TriggersEncoding ; EncodingSession.Triggers];
        ResultsRecovery.Encoding(:,5)       = 1:60;
        ResultsRecovery.Encoding(:,6)       = Subject;
    end
    ResultsRecovery.Recall                  = [ResultsRecovery.Recall RecallSession.Results];
    ResultsRecovery.TriggersRecall          = [ResultsRecovery.TriggersRecall ; RecallSession.Triggers];
    ResultsRecovery.Recall(:,3)             = 1:60;
    
    
     %Make a pause
    WaitSecs(1);
    DrawFormattedText(window,...
        'Pause\n\n\n Appuyer sur espace pour continuer' ,'center',...
        'center', black);
        Screen('Flip', window); 
        TriggersRecall = [TriggersRecall; [100 GetSecs]];
        SendArduinoTrigger(100);
    
    KbWait;
end
%--------------------------------------------------------------------------
%                              All Results
%--------------------------------------------------------------------------



%We create a complete matrix with all the results for that session and
%subject
RecallImages                = [RecallSession1 RecallSession2 RecallSession3];
Recallseriesnumber          = Recallseriesnumber'
Recallseriesnumber(:, 2)    = 1:60;
EncodingImages              = [Session1 Session2 Session3];

filename = sprintf('RecoveryResultsDay%d.mat', Day);
path2save = fullfile(Results, filename);
save(path2save, 'ResultsRecovery');



TriggersRecall= [TriggersRecall; [66 GetSecs]];
SendArduinoTrigger(66);
TriggersRecall = [TriggersRecall; [6 GetSecs]];
SendArduinoTrigger(6);

filename = sprintf('logfile_recovery.mat');
path2save = fullfile(Results, filename);
save(path2save);

CloseArduinoPort