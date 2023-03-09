switch config.ROI
    case 'Hippocampus'
        
        Chans               = {[],[],'Ha2g_3-Ha2g_4', 'HmT3_2-HmT3_3', 'HaT2_2-HaT2_3', 'HaT1_3-HaT1_4', [], 'HMd1-HMd2',...
            'HA1-HA2', 'HM2-HM3', [], [], [], [], 'HA2-HA3', [], 'AmT2_1-AmT2_2', 'HaT1_2-HaT1_3', 'HPL1-HPL2'};
        subjc  = [3 4 5 6 8 9 10 15 17 19];
    case'middletemporal'
        

  
        subjc  = [ 4 5 6 8 9 10 15 17 19];
        Chans               = {[],'HaT2_6-HaT2_7',[], 'HmT3_5-HmT3_6', 'HaT2_6-HaT2_7', 'HmT2_11-HmT2_12', 'HP10-HP11'...
            , 'HMi11-HMi12', 'TP8-TP9', 'HP8-HP9', [], [], [], 'OC10-OC11', 'HA10-HA11', [], 'T2Bg_6-T2Bg_7'...
            , 'TBp_6-TBp_7', 'HTSL6-HTSL7'};
        
end

%pat 19 has also HAL10-HAL11 for med temporal
%pat 8 PLTd9-PLTd10 and HMi11-HMi12
%pat 15 HA10-HA11 has many artifacts