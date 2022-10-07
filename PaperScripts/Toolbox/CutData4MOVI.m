
%cut data with latency in function of the type of desired data
switch acc1
    case 'all'
        for subj = 1:numel(subjc)
            for img = 1:numel(event1)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat1_cltr{subj, img} = ft_selectdata(cfg, AllDat1{subj, img});
            end
        end
        
    case 'acc'
        for subj = 1:numel(subjc)
            for img = 1:numel(event1)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat1_cltr{subj, img} = ft_selectdata(cfg, AllDat1_acc{subj, img});
            end
        end
    case 'nacc'
        for subj = 1:numel(subjc)
            for img = 1:numel(event1)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat1_cltr{subj, img} = ft_selectdata(cfg, AllDat1_nacc{subj, img});
            end
        end
end


switch acc2
    case 'all'
        for subj = 1:numel(subjc)
            for img = 1:numel(event2)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat2_cltr{subj, img} = ft_selectdata(cfg, AllDat2{subj, img});
            end
        end
        
    case 'acc'
        for subj = 1:numel(subjc)
            for img = 1:numel(event2)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat2_cltr{subj, img} = ft_selectdata(cfg, AllDat2_acc{subj, img});
                
            end
        end
        
    case 'nacc'
        for subj = 1:numel(subjc)
            for img = 1:numel(event2)
                cfg = [];
%                 cfg.latency = timeint;
                AllDat2_cltr{subj, img} = ft_selectdata(cfg, AllDat2_nacc{subj, img});
            end
        end
end

