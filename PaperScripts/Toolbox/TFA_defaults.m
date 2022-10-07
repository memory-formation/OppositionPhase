data_clean = config.dataset;
if isfield(config, 'allfiles') == 0
    config.allfiles = 1;
end
if isfield(config, 'keeptrials') == 0
    config.keeptrials = 'no';
end
if isfield (config, 'foi') == 0
    config.foi          = 'all';
end
if isfield (config, 'method') == 0
    config.method = 'mtmconvol';
end
switch config.method
    case 'mtmconvol'
        width = [];
        switch config.foi
            case 'all'
                foi             = 3:2:200;
                timwin          = ones(1,size(foi,2)).*0.30
                if isfield (config, 'taper') == 0 
                    config.taper = 'hanning';
                end
            case 'beta' 
                foi             = 10:1:30;
                timwin          = 5./foi
                if isfield (config, 'taper') == 0 
                    config.taper = 'hanning';
                end
            case 'med'
                foi             = 4:1:29;
                timwin          = 5./foi;
                if isfield (config, 'taper') == 0 
                    config.taper = 'hanning';
                end
            case 'high'
                foi             = 30:5:140;
                timwin          = ones(1,size(foi,2)).*0.40;
                config.taper    = 'dpss';
                if isfield (config, 'multitaper') == 0
                    tapsmofrq   = 10;

                else
                    tapsmofrq   = config.multitaper*foi   ;
                end
            case 'superhigh'
                foi             = 30:5:300;
                timwin          = ones(1,size(foi,2)).*0.40;
                config.taper    = 'dpss'
                if isfield (config, 'multitaper') == 0
                    tapsmofrq   = 10;

                else
                    tapsmofrq   = config.multitaper*foi   ;
                end
            case 'sthigh'
                foi             = 30:4:150;
                timwin          = ones(1,size(foi,2)).*0.20;
                config.taper    = 'dpss';
                if isfield (config, 'multitaper') == 0
                    tapsmofrq   = 10;

                else
                    tapsmofrq   = config.multitaper;
                end
                if isfield (config, 'taper') == 0 
                    config.taper = [];
                end
            case 'theta' 
                foi             = 6:0.5:10;
                timwin          = 7./foi;
                if isfield(config, 'taper') == 0 
                    config.taper = 'hanning';
                end
            case 'staresina'
                foi                     = 30:5:120;
                timwin                  = ones(1, size(foi, 2)).*0.40;
                if isfield (config, 'multitaper') == 0
                    tapsmofrq   = 10;

                else
                    tapsmofrq   = config.multitaper*foi   ;
                end
                if isfield (config, 'taper') == 0 
                    config.taper = [];
                end
        end
    case 'wavelet'
        config.taper = [];
        switch config.foi
            case'high'
                width           = 15;
                foi             = 60:4:160;
                timwin          = ones(1,size(foi,2)).*0.30
            case 'low' 
                foi             = 2:1:29;
                timwin          = 5./foi
                width = 5
            case 'med'
                foi             = 2:1:40;
                timwin          = 7./foi;
                width = 7
            case'staresina'
                foi                     = 30:5:100;
                timwin                  = ones(1, size(foi, 2)).*0.40;
                width                   = 15;
        end
end
        
if isfield (config, 'channel') == 0
    config.channel = 'all';
end
if isfield (config, 'baselinetype') == 0
    config.baselinetype = 'normal';
end
if isfield(config, 'TFRdata') == 0
    config.TFRdata = 'no'
end
switch config.baselinetype
    case 'custom'
        if isfield (config, 'Subject') == 0 || isfield (config, 'Mode') == 0
            error 'This type fo baseline requires the subject number and the Mode'
        end
end
if isfield (config, 'structure') == 0
    config.structure = 'Hippocampus';
end
if isfield (config, 'antpost') == 0
    antpost = 'all';
else 
    antpost = config.antpost;
end
if isfield(config, 'toi') == 0
    if isfield (config,'lowpass') ~= 0 
        config.toi = [-1 : 1/config.lowpass: 4];
    else
        space               = data_clean.time{1}(2) - data_clean.time{1}(1);
        config.toi          = [-1 : space : 3.5];
    end
end
