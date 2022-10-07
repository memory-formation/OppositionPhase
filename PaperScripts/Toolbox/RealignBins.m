function [angbin1 angbin2] = RealignBins(ampbin1, ampbin2, config)
%input is ampbin a 2D matrix of subj x bins or trials x bins
%config possibilities are:
%config.r_type = 'absolute': centers distrib 1 on zero and distrib 2
%relative to distrib 1
%
%config.r_type = 'absolute_pos': centers distrib 1 on zero and distrib 2
%relative to distrib 1, but also shifter to positive angles: if some
%patients have a difference of angles with condition 1 that is negative it
%will be symmetrically shifted towards the dominant sign direction(positive
%or negative angles)
%
%config.r_type = 'mean': centers distrib 1 on the average angle across
%patients of distribution 1 and distrib 2 relative to distrib 1
%
%config.r_type = 'mean_pos': centers distrib 1 on the average angle
%preference across participants and distrib 2 relative to distrib 1,
%with symmetrical shift to either positive or negative preference of
%distribution 2
%
%config.r_type = '2means' : centers distrib1 on the average preference angle
%across patients of distribution 1 and distribution 2 on the average 
%preference angle across patients of distribution 2

if ~isfield(config, 'figbin'); config.figbin = 'no'; end

for s = 1:size(ampbin1, 1)
    ampbin1(s, :) = ampbin1(s, :)./sum(ampbin1(s, :));
    ampbin2(s, :) = ampbin2(s, :)./sum(ampbin2(s, :));
end
nbins = size(ampbin1, 2);
if size(ampbin2) ~= nbins
    error 'number of bins is different in dataset 1 and 2'
end
position=zeros(1,nbins); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbins;
for j=1:nbins
    position(j) = -pi+(j-1)*winsize;
end


a_m_1 = mean(ampbin1, 1);
an_1 = angle(mean(a_m_1.*exp(sqrt(-1)*position),2));
a_m_2 = mean(ampbin2, 1);
an_2 = angle(mean(a_m_2.*exp(sqrt(-1)*position),2));
[~, angle_pref1] = min(abs(position-an_1));
[~, angle_pref2] = min(abs(position-an_2));
zerobin = nbins/2+1;

switch config.r_type
    case'absolute'
        %realigns with max of angbin1 centered on 0
        %angbin2 realigned relative to ang1
        for s = 1:size(ampbin1, 1)
            tmp1 = ampbin1(s, :);
            tmp2 = ampbin2(s, :);
            antmp1 = angle(mean(tmp1.*exp(sqrt(-1)*position),2));
            antmp2 = angle(mean(tmp2.*exp(sqrt(-1)*position),2));
            [~, anprf1] = min(abs(position-antmp1));
            [~, anprf2] = min(abs(position-antmp2));
            nshift1 = zerobin-anprf1;
            angbin1(s, :) = circshift(tmp1, nshift1);
            angbin2(s, :) = circshift(tmp2, nshift1);
        end
    case 'absolute_pos'
        for s = 1:size(ampbin1, 1)
            tmp1 = ampbin1(s, :);
            tmp2 = ampbin2(s, :);
            antmp1 = angle(mean(tmp1.*exp(sqrt(-1)*position),2));
            antmp2 = angle(mean(tmp2.*exp(sqrt(-1)*position),2));
            [~, anprf1] = min(abs(position-antmp1));
            [~, anprf2] = min(abs(position-antmp2));
            nshift1 = zerobin-anprf1;
            angbin1(s, :) = circshift(tmp1, nshift1);
            angbin2(s, :) = circshift(tmp2, nshift1);
            
            % mirror-flip relative to y-axis
            antmp_pos = angle(mean(angbin2(s, :).*exp(sqrt(-1)*position)));
            % mirror-flip relative to y-axis
            if (antmp_pos <= 0 & antmp_pos >= -pi)
                % find the closest position to the
                angbin2(s, :) = symshift(angbin2(s, :), 1);
                flag(s) = -1;
            else
                angbin2(s, :) = angbin2(s, :);
                flag(s) = 1;
            end
        end
        if mean(flag)<=0
            for s = 1:size(ampbin2, 1)
                angbin2(s, :) = symshift(angbin2(s, :), -1);
            end
        end
    case'mean'
        %realigns with max of angbin1 set on the mean across patients
        %requires config.meanvec
        %angbin2 is realigned relative to angbin 1 regardless of direction
        for s = 1:size(ampbin1, 1)
            tmp1 = ampbin1(s, :);
            tmp2 = ampbin2(s, :);
            antmp1 = angle(mean(tmp1.*exp(sqrt(-1)*position),2));
            antmp2 = angle(mean(tmp2.*exp(sqrt(-1)*position),2));
            [~, anprf1] = min(abs(position-antmp1));
            [~, anprf2] = min(abs(position-antmp2));
            nshift1 = angle_pref1-anprf1;
            angbin1(s, :) = circshift(tmp1, nshift1);
            angbin2(s, :) = circshift(tmp2, nshift1);
        end
    case '2means'
        for s = 1:size(ampbin1, 1)
            tmp1 = ampbin1(s, :);
            tmp2 = ampbin2(s, :);
            antmp1 = angle(mean(tmp1.*exp(sqrt(-1)*position),2));
            antmp2 = angle(mean(tmp2.*exp(sqrt(-1)*position),2));
            [~, anprf1] = min(abs(position-antmp1));
            [~, anprf2] = min(abs(position-antmp2));
            nshift1 = angle_pref1-anprf1;
            nshift2 = angle_pref2-anprf2;
            angbin1(s, :) = circshift(tmp1, nshift1);
            angbin2(s, :) = circshift(tmp2, nshift2);
        end
    case 'mean_pos'
        for s = 1:size(ampbin1, 1)
            tmp1 = ampbin1(s, :);
            tmp2 = ampbin2(s, :);
            antmp1 = angle(mean(tmp1.*exp(sqrt(-1)*position),2));
            antmp2 = angle(mean(tmp2.*exp(sqrt(-1)*position),2));
            [~, anprf1] = min(abs(position-antmp1));
            [~, anprf2] = min(abs(position-antmp2));
            nshift1 = angle_pref1-anprf1;
            angbin1(s, :) = circshift(tmp1, nshift1);
            angbin2(s, :) = circshift(tmp2, nshift1);
            antmp_pos = angle(mean(angbin2(s, :).*exp(sqrt(-1)*position)));% current phase angle after realignment
            
            % mirror-flip relative to y-axis
            if (antmp_pos <= 0 & antmp_pos >= -pi)
                % find the closest position to the
                angbin2(s, :) = symshift(angbin2(s, :), 1);
                flag(s) = -1;
            else
                angbin2(s, :) = angbin2(s, :);
                flag(s) = 1;
            end
        end
        if mean(flag)<=0
            for s = 1:size(ampbin2, 1)
                angbin2(s, :) = symshift(angbin2(s, :), -1);
            end
        end
    case 'no'
        angbin1 = ampbin1;
        angbin2 = ampbin2;
end

for s = 1:size(angbin1, 1)
    angbin1(s, :) = angbin1(s, :)./sum(angbin1(s, :)) - 1/nbins ;
    angbin2(s, :) = angbin2(s, :)./sum(angbin2(s, :)) - 1/nbins ;
end

switch config.figbin
    case'yes'
        angbin_avg1 = mean(angbin1, 1);
        angbin_avg1 = angbin_avg1./sum(angbin_avg1);
        angbin_avg1 = angbin_avg1 - 1/nbins;
        angbin_avg2 = mean(angbin2, 1);
        angbin_avg2 = angbin_avg2./sum(angbin_avg2);
        angbin_avg2 = angbin_avg2 - 1/nbins;
        angbin_avg1 = smoothbin(angbin_avg1, 3);
        angbin_avg2 = smoothbin(angbin_avg2, 3);
        
        figure;
        b1 = bar(position, angbin_avg1, 'FaceColor', 'k', 'EdgeColor', 'k', 'LineWidth', 2);
        set(gca,'xlim',[position(1) position(end)])
        b1.FaceAlpha = 0.3;
        hold on;
        b2 = bar(position, angbin_avg2, 'FaceColor', 'r', 'EdgeColor', 'r', 'LineWidth', 2);
        b2.FaceAlpha = 0.3;
        xlabel('Phase (rad)')
        ylabel(sprintf('Hippocampus \n Amplitude (z)'))
        yline(0, 'linewidth', 3)
        %         ylim([-2 2])
end
