
%Core
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

%%%%%%%%%%%%%%%%%%%
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
Subject     = length(TotalSubj)+1;

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
%% Experimental image list
%-------------------------------------------------------------------------
%                          Experimental image list
%-------------------------------------------------------------------------

%Get the image files for the experiment and randomize the series
%the files will be in order (1/2/3/4) but the series will be randomized
%each time

Imagesfolder   = fullfile(Home,Task);  
topLevelFolder =(Imagesfolder);
if topLevelFolder == 0
    return;
end
SubFolders      = genpath(topLevelFolder);
remain          = SubFolders;
listFolderNames ={};
while true
    [singleSubFolder, remain] =strtok(remain, ';');
    if isempty(singleSubFolder)
        break;
    end
    listFolderNames = [listFolderNames singleSubFolder];
end
listFolderNames = listFolderNames(2:61);
%extract the number of the series to register the order during encoding and
%retrieval. 

%List of all subfolders containing images


%Randomize order of the folders in order to always have 3 different lists
%for the 3 sessions
randimages          = randperm(60);
ListFolderNamesAll  = {};
for k = 1:length(randimages)
    ListFolderNamesAll(k) = listFolderNames(randimages(k));
end
seriesnumber = extractAfter(ListFolderNamesAll(1, :), 'ImagesTask\');
seriesnumber = str2double(seriesnumber);
seriesnumber = seriesnumber';
seriesnumber(:, 2) = 1:60;
%Generate 3 lists for 3 sessions
Session1 = ListFolderNamesAll(1:20);
Session2 = ListFolderNamesAll(21:40);
Session3 = ListFolderNamesAll(41:60);
Triggers = [];

%Randomise series again for the recall session
for k = 1:3
    r= randperm(20);
    if k == 1 
        for i=1:20
            RecallSession1(i) = Session1(r(i));
        end
    elseif k == 2
        for i=1:20
            RecallSession2(i) = Session2(r(i));
        end
    elseif k == 3
        for i=1:20
            RecallSession3(i) = Session3(r(i));
        end
    end
end

%Register the list of series under a same structure
    Encoding.Session1       = Session1;
    Encoding.Session2       = Session2;
    Encoding.Session3       = Session3;
    
    RecallDay1.Session1     = RecallSession1;
    RecallDay1.Session2     = RecallSession2;
    RecallDay1.Session3     = RecallSession3;
 
    
%Create a folder for the results of that subject
Results = fullfile(cd, ResultFolder, sprintf('Subject_%d',Subject));
if exist(Results, 'dir') < 1
    mkdir (Results);
end
    
%Save the structures for Encoding and recall    
     

filename                    = sprintf('Encoding.mat');
path2save                   = fullfile(Results, filename);
save(path2save, 'Encoding');

filename                    = sprintf('RecallDay1.mat');
path2save                   = fullfile(Results, filename);
save(path2save, 'RecallDay1');
%Register the seriesnumbers and order of the series for encoding for the
%results




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

%-------------------------------------------------------------------------
%                           Experimental Task
%-------------------------------------------------------------------------

%Start Screen

DrawFormattedText(window, 'Appuyer sur Espace pour commencer', 'center',...
    'center', black);
Screen('Flip', window);
KbWait;
Begin    = GetSecs;
%% Experimental loop
ResultsSession1                 = [];
ResultsSession2                 = [];
RestulsSession3                 = [];
Recallseriesnumber              = [];
StructOutput.Day                = 1;
ResultsDay1.Encoding            = [];
ResultsDay1.TriggersEncoding    = [];
ResultsDay1.Recall              = [];
ResultsDay1.TriggersRecall      = [];


for session = 1:3
 
    %----------------------------------------------------------------------
    %                      Values for  Tasks
    %----------------------------------------------------------------------
    
    % Have all basic values reset 
    %Reset of p iteration
    p=1;
    
    %Send triggers to signal the beginning of a session
    Triggers                        = [Triggers; [120 GetSecs]];
    SendArduinoTrigger(120);
    Triggers                        = [Triggers; [29 GetSecs]];
    SendArduinoTrigger(29);
    Triggers                        = [Triggers; [4 GetSecs]];
    SendArduinoTrigger(4);
    
    %Reset the values necessary to write the results of each session.
    Engagement                      = [];
    Triggers                        = [];                   
    EncodingResults                 = [];                
    EncodingTriggers                = [];              
    EncodingSession.Results         = [];
    EncodingSession.Triggers        = [];
    RecallResults                   = [];
    TriggersRecall                  = [];
    
    % Define the struct output variable that will be saved in order to
    % retrieve the information inc ase of crash. marks the session number
    % and the state of encoding (1 if it is encoding 0 if it's retrieval.
    % This value is changed at teh beginning of each task)
    StructOutput.Session            = session;
    StructOutput.Enc                = 1;  
    %List of folder names to get the images in function of the session
    %number.
    
    if session == 1
        listFolderNames = Session1;
        series = seriesnumber(1:20);
    elseif session == 2
        listFolderNames = Session2;
        series = seriesnumber(21:40);
    elseif session == 3
        listFolderNames = Session3;
        series = seriesnumber(41:60);
    end
    
    numberF = length(listFolderNames);
    basefilenames = dir();
    FullName = {};
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
                FullName = [FullName, fullfilename];
            end
        else
            fprintf('Folder %s has no image in it \n', thisFolder);
        end
    end
    FullName = FullName';
    
    %% Encoding session
    for k=1:20
        DrawFormattedText(window, 'Nouvel Episode', 'center', 'center', black);
        Screen('Flip', window);
        Triggers = [Triggers; [15 GetSecs]];
        SendArduinoTrigger(15);
%         OnsetBegin = [OnsetBegin GetSecs-Begin];
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
            Triggers = [Triggers; [outputval GetSecs]];
            SendArduinoTrigger(outputval);
            outputval=outputval+1;
            WaitSecs(2.5);
            %iteration of P
            p=p+1;
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
        
        
        
        
        targDuration = 4;
        value=[];
        exitTime = GetSecs + targDuration;
        OnsetTime = GetSecs;
        GotResponse =0;
        Triggers = [Triggers; [25 GetSecs]];
        SendArduinoTrigger(25);
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
            end  
        end
        Triggers = [Triggers; [26 GetSecs]];
            SendArduinoTrigger(26);
        if GotResponse == 0
            value =nan;
        end
%--------------------------------------------------------------------------
%                               RESULTS ENCODING
%--------------------------------------------------------------------------
        
        %Put all the results per session in a single structure that is
        %reset in every new session and save it under a .mat structure file
        % in order to be able to retrieve a single session later on. In
        % case the script crashes this will enable us to have the data of a
        % session. Since the file is saved at every new series it allows us
        % to have a precision up to the series if anything goes wrong. 
        
        
        Engagement                      = [Engagement, value];
        EncodingResults(k , 1)          = series(k);
        EncodingResults(k , 2)          = k;
        EncodingResults(k , 3)          = Engagement(k)
        EncodingResults(: , 4)          = session;
        EncodingSession.Results         = EncodingResults;
        EncodingSession.Triggers        = Triggers;
        
        
        filename    = sprintf('EncodingSession%d.mat', session);
        path2save   = fullfile(Results, filename);
        save(path2save, 'EncodingSession');
        if esc == 1
            sca;
            break
        end     
    end
    
    
    %----------------------------------------------------------------------
    %% Pause between encoding and Recall
    %----------------------------------------------------------------------
    
    
    DrawFormattedText(window, 'Appuyer sur une touche pour continuer vers la tâche souvenir',...
        'center', 'center', black);
    Screen('Flip', window);
    Triggers = [Triggers; [100 GetSecs]];
    SendArduinoTrigger(100);
    WaitSecs (1);
    KbWait;
    
    %% Recall Task
    %----------------------------------------------------------------------
    %                            Recall Task
    %----------------------------------------------------------------------
    
    %Randomise Images for recall task and save their order under a name for
    %the results (RecallSession%s)
    
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
    StructOutput.Enc = 0;
    p=1;
    
    for k=1:20
        
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
        RecallSession.Results(k,1) = recallseries(k);
        RecallSession.Results(k,2) = k;
        RecallSession.Triggers = TriggersRecall;
        
        filename    = sprintf('RecallSession%d.mat', session);
        path2save   = fullfile(Results, filename);
        save(path2save, 'RecallSession');
        
    end
    
    %% Session results
    %------------------------------------------------------------------
    %                      Results for each Session
    %------------------------------------------------------------------
    %Put the results under the form of numbers down here to have an
    %overview of the general results.
    
   ResultsDay1.Encoding         = [ResultsDay1.Encoding EncodingResults];
   ResultsDay1.TriggersEncoding = [ResultsDay1.TriggersEncoding ; EncodingSession.Triggers];
   ResultsDay1.Recall           = [ResultsDay1.Recall RecallSession.Results];
   ResultsDay1.TriggersRecall   = [ResultsDay1.TriggersRecall ; RecallSession.Triggers];
   ResultsDay1.Encoding(:,6)    = Subject;
    
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

filename = sprintf('ResultsDay1.mat');
path2save = fullfile(Results, filename);
save(path2save, 'ResultsDay1');

filename = sprintf('EncodingImages.mat');
path2save = fullfile(Results, filename);
save(path2save, 'EncodingImages');

filename = sprintf('RecallImages.mat');
path2save = fullfile(Results, filename);
save(path2save, 'RecallImages');



TriggersRecall= [TriggersRecall; [66 GetSecs]];
SendArduinoTrigger(66);
TriggersRecall = [TriggersRecall; [6 GetSecs]];
SendArduinoTrigger(6);

filename = sprintf('logfile_day1');
path2save = fullfile(Results, filename);
save(path2save);

CloseArduinoPort
sca;
