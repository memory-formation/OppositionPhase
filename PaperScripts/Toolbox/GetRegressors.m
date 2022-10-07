function Regressors = GetRegressors(config)
%Define Home
Home                = '/media/ludovico/DATA/iEEG_Ludo';
Results             = 'Results';
SubjFold            = sprintf('Subject_%d', config.Subject);
OrderMat            = 'Order_mat';

%define type of regressors wanted and extract behavioral data
%Accuracy: classic regressors with accuracy score 
%Similarity: for Similarity analysis, matches by series number 
%Single image: gives accuracy for each single image, not accuracy based on
%series.
switch config.regressors
    case 'Accuracy'
        filename = 'OrderseriesAccuracy.mat';
        
        Orderfile = fullfile(Home, Results, SubjFold, OrderMat, filename);
        load(Orderfile)
        
        Regressors.Subject          = export.Subj;
        Regressors.Series           = export.seriesnumber;
        if config.eventvalue <30
            Regressors.Trials       = export.OrderEnc;
        elseif config.eventvalue > 35 
            if config.day == 1
                Regressors.Trials   = export.Orderrec1;
            else
                Regressors.Trials   = export.Orderrec2;
            end
        end
        if config.recfrom == 1
            Regressors.Accuracy     = export.Accuracy_day1;
        elseif config.recfrom == 2
            Regressors.Accuracy     = export.Accuracy_day2;
        end
        Regressors.Engagement       = export.Eng;
    case 'img'
        fprintf('Work in progress, please visit this function to improve it')
    case 'Similarity'
        filename = 'OrderseriesAccuracy.mat';
        Orderfile = fullfile(Home, Results, SubjFold, OrderMat, filename);
        load(Orderfile)

                
        Regressors.Subject          = export.Subj;
        if config.eventvalue <30
            Regressors.Trials       = export.OrderEnc;
        elseif config.eventvalue > 35 
            if config.day == 1
                Regressors.Trials   = export.Orderrec1;
            else
                Regressors.Trials   = export.Orderrec2;
            end
        end
        if config.recfrom == 1
            Regressors.Accuracy     = export.Accuracy_day1;
        else
            Regressors.Accuracy     = export.Accuracy_day2;
        end
        Regressors.Engagement       = export.Eng;
        Regressors.seriesnumber     = export.seriesnumber;
    case 'SingleImage'
        filename = 'ImagesRecalled.mat';
        
        Orderfile = fullfile(Home, Results, SubjFold, OrderMat, filename);
        load(Orderfile)
        Regressors.Subject          = export.Subj;
         if config.eventvalue <30
            Regressors.Trials       = export.OrderEnc;
        elseif config.eventvalue > 35 
            if config.day == 1
                Regressors.Trials   = export.Orderrec1;
            else
                Regressors.Trials   = export.Orderrec2;
            end
        end
        Regressors.ImageAccDay1(1, :)          = export.Img1_orig;
        Regressors.ImageAccDay1(2, :)          = export.Img2_orig;
        Regressors.ImageAccDay1(3, :)          = export.Img3_orig;
        Regressors.ImageAccDay1(4, :)          = export.Img4_orig;
        
        Regressors.ImageAccDay2(1, :)          = export.Img1_orig2;
        Regressors.ImageAccDay2(2, :)          = export.Img2_orig2;
        Regressors.ImageAccDay2(3, :)          = export.Img3_orig2;
        Regressors.ImageAccDay2(4, :)          = export.Img4_orig2;
        
        
        
    otherwise
        fprintf('Work in progress, please visit this function to improve it')
end
