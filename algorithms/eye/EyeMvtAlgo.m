function [out,eye,status] = EyeMvtAlgo(varargin)
%
% [out,eye,status] = EyeMvtAlgo(varargin)
% [eye,status] = fvtGenerateSessionEyeMovements(display_flag)
% This function determines which regions of an eye signal correspond to
% fixations and saccades.
% This function determines the regions for all trials in a session and then
% creates a structure containing the start and finish times in (milliseconds)
% for each of the events.  The structure is eye(trial).fixation(event#).start
% There are similiar fields for saccade start, finish.
%
% If display_flag is 1, the following will be displayed trial by trial:
%  Plot of the filtered and unfiltered instantaneous velocities, along with the relative thresholds
%  Plot of the raw component eye traces, overlaid with colored and filtered fixation and saccade sections
%  An x,y,t plot of the trial with colored fixation and saccades (currently commented out)
%  Plot of the "lazy saccade line" and where each saccade fell in relation to it
%  Messages which explain why appropriate sections were thrown out
%
% status is returned as a -1 if there is an error
%
% Assumptions:
% The pwd must be the eye folder.
%
% These are the optional input arguments:
% MinSacPR = 0.083;             %minimum saccade amplitude (5 min. of arc)
% SacThresh = 6;                %smallest maximum velocity allowed in order to be a saccade
% SmallSaccadeDecelThresh = -0.25;      %the deceleration value (in deg/s/s) that marks the end of small    saccades                                
% LazySaccade = 210;            %ignore saccades longer than this
% LazySLope = 55;               %slope of the line used to detect lazy saccades
% LazyIntersect = 60;           %y-intercept of the line used to detect lazy saccades; NOTE:  Changed from 49
% ShortFix = 50;                %the shortest fixation that can be unbounded.
% DecelerationThresh = -1;      %value of acceleration (in deg/s/s) that marks the end of a saccade
% MaxAccelerationThresh = 0.4;  %saccade max acceleration must be >= to this value in order to be kept
% EarlySaccade = 500;           %Period of time in which the first saccade can be thrown out
% IgnoreEarlySaccade = 1;       %flag that causes the first saccade within the EarlySaccade time limit
%                               %to be ignored (attempt to remove corrective saccades in fixational trials

Args = struct('MinSacPR',0.083,'SacThresh',6,'SmallSaccadeDecelThresh',-0.25, ...
	'LazySaccade',210,'LazySLope',55,'LazyIntersect',60,'ShortFix',50, ...
	'DecelerationThresh',-1, 'MaxAccelerationThresh',0.4, 'EarlySaccade', 500, ...
    'IgnoreEarlySaccade', 0,'TossLoneSac',0);
Args.flags = {'IgnoreEarlySaccade','TossLoneSac'};
Args = getOptArgs(varargin,Args);

warning off MATLAB:divideByZero

status = 1;
if(isempty(Args.NumericArguments))
    display_flag = 0;
else
    display_flag = 1;
end

if display_flag
    h1 = figure;
    set(h1,'Position', [1 29 1280 928]);
    zoom on
    h2 = figure;
    set(h2,'Position', [1 29 1280 928]);
    zoom on
%     h3 = figure;
%     set(h3,'Position', [1 29 1280 928]);
%     zoom on
    h4 = figure;
end

dirlist = nptDir('*_eye.0*');
numTrials = size(dirlist, 1);
out.numSets = numTrials;
trial = 1;

eye.sessionname = dirlist(1).name(1:length(dirlist(1).name) - 9);
%Look for an .ini file in the directory above.  If one is not present,
%assume that the trial is NOT free-viewing
cd ..
if ispresent([eye.sessionname, '.ini'], 'file') | ispresent([eye.sessionname, '.INI'], 'file')
    [iniInfo, status] = ReadRevCorrIni([eye.sessionname, '.ini']);
else
    iniInfo.win_movie = 0;
end
if ~isfield(iniInfo, 'win_movie')
    iniInfo.win_movie = 0;
end
cd eye

%%%%%%%%%%%%%%%Initialisation of the output variables
out.sacStart = [];
out.sacEnd = [];
out.sacMaxVel = [];
out.sacMaxVelTime = [];
out.sacAmpl = [];
out.sacSetIndex = [];

out.fixStart = [];
out.fixEnd = [];
out.fixMaxVel = [];
out.fixMaxVelTime = [];
out.fixMeanVel = [];
out.fixAmpl = [];
out.fixSetIndex = [];
countSac = 1;
countFix = 1;

temp.sacSetIndex = [];
temp.fixSetIndex = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while trial <= numTrials
    if display_flag
        fprintf('\nTrial Number %i\n', trial);
    else
        fprintf('%i ', trial);
    end
    
    %read data
    filename = dirlist(trial).name;
    [data, num_channels, samples_per_sec, datatype, points] = nptReadDataFile(filename);
    out.samplingRate = samples_per_sec;
    %change data from pixels to degrees
    [data(1,:) data(2,:)] = pixel2degree(data(1,:), data(2,:));
    
    if display_flag
        %plot unclassified raw component eye traces
        figure(h2)
        hold off
        plot(data(1,:), 'k')
        hold on
        plot(data(2,:), 'b')
    end
    
    %Older eye files that were produced with the calibration process prior
    %to 2003 may have NaN's in the signal when the monkey's eyes went
    %outside the calibrated region.
    %Here is the NaN strategy that we'll use:
    %Replace NaNs with surronding values and mark NaN positions.
    %Run through ordinary algorithm then replace the NaN fake fixations
    %and surrounding saccades with zeros in the true-false(tf) matrices.  
    
    NaNflag = 0;
    if sum(isnan(data), 2) > 0			%if this trial contains NAN's
        NaNflag = 1;
        n = isnan(data);
        [i,j] = find(n);
        if size(i,1) == (size(data, 2) * 2)	%then entire trial is NANs
            NaNstart = 1;
            NaNstop = size(data, 2) - 1;
            data(size(data, 2)) = 0;
        else
            j = j(1:2:length(j))';
            %how many NaN sections are there??
            j1 = [0 j(1:length(j) - 1)];	%shift j
            NaNstart = j(find((j - j1) > 1));
            j1 = [j(2:length(j)) 0];
            NaNstop = [j(find((j1 - j) > 1)) j(length(j))];
            if length(NaNstart) < length(NaNstop)
                NaNstart = [1 NaNstart];
            end
        end
        numNaN = length(NaNstart);
        
        for i = 1:numNaN
            if NaNstart(i) == 1
                data(1, NaNstart(i):NaNstop(i)) = data(1, NaNstop(i) + 1);		%incase NaNs start trial		
                data(2, NaNstart(i):NaNstop(i)) = data(2, NaNstop(i) + 1);				
            else
                data(1, NaNstart(i):NaNstop(i)) = data(1, NaNstart(i) - 1);		%or end trial
                data(2, NaNstart(i):NaNstop(i)) = data(2, NaNstart(i) - 1);
            end
        end
    end
    
    %FIR filter raw data 
    order = 6;
    b = ones(1, order)/order;
    filtered = filtfilt(b, 1, data');	%12th order running average(boxcar) with no delay
    
    %calculate actual trajectory velocity
    delta_vert = diff(filtered(:,1));
    delta_horiz = diff(filtered(:,2));
    distance = sqrt(delta_vert.^2 + delta_horiz.^2);
    unfilVel = distance * samples_per_sec;
    %filter velocity signal;
    order = 15;	
    b = ones(1, order)/order;
    realVel = filtfilt(b, 1, unfilVel);     %31st order running average(boxcar) with no delay
    
    if display_flag
        figure(h1)
        hold off
        plot(realVel, 'b.-')
        hold on
        plot(unfilVel, 'r.-')
        plot(diff(realVel), 'g.-')
        lh1 = line([length(realVel), 1], [Args.DecelerationThresh, Args.DecelerationThresh]);
        lh2 = line([length(realVel), 1], [Args.SmallSaccadeDecelThresh, Args.SmallSaccadeDecelThresh]);
        lh3 = line([length(realVel), 1], [Args.SacThresh, Args.SacThresh]);
        lh4 = line([length(realVel), 1], [Args.MaxAccelerationThresh, Args.MaxAccelerationThresh]);
        set(lh1, 'Color', 'g');
        set(lh2, 'Color', 'r');
        set(lh3, 'Color', 'b');
        set(lh4, 'Color', 'k');
        legend('Filtered Velocity (degrees/s)', 'Unfiltered Velocity (degrees/s)', ...
            'Filtered Acceleration (degrees/s/s)', ...
            ['Deceleration Threshold (' num2str(Args.DecelerationThresh) ' degrees/s/s)'], ...
            ['Small Saccade Deceleration Threshold (' num2str(Args.SmallSaccadeDecelThresh) ' degrees/s/s)'], ...
            ['Saccade Threshold (' num2str(Args.SacThresh) ' degrees/s)'], ...
            ['Max Acceleration Threshold (' num2str(Args.MaxAccelerationThresh) ' degrees/s/s)'])
        hold off
        
%         figure(h3)
%         hold off
%         plot3(filtered(:,2), filtered(:,1), 1:(length(filtered)))
%         title('Eye Scan Path')
    end
    
    %%%%%%%%%%%%%%%%% 	Recognition Rules 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  -  saccades are regions with large velocities, but longer than 5 minutes of arc
    %  -  saccades must reach an acceleration >= 0.4 deg/s/s (Args.MaxAcclerationThresh)
    %  -  saccades must be above a given veloctiy range, given their amplitude
    %  -  ignore all events at the start and end of a trial (if the trial is not fixating)
    %  -  ignore lazy saccades lasting more than 210 ms (Args.LazySaccade value from above)
    %  -  if the data has NANs then ignore the section and both saccades on either side
    %  -  ignore noise spikes in data
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Define the TrueFalse vector for saccades.
    saccadetf = realVel > Args.SacThresh;

    %create marker to define sections of saccades and fixation
    marker = [1];
    sacEnd = 0;
    sacStart = 0;
    flag = 0;       %start is a fixation
    for i = 1:length(saccadetf)
        if (flag == 0) & (saccadetf(i) == 1)
            marker = [marker i];
            flag = 1;
        elseif (flag == 1) & (saccadetf(i) == 0) & (i ~= length(saccadetf))
            %There's a possibility that only one point is across the
            %threshold.  If this occurs, exclude it.
            if (i > 2) && (saccadetf(i - 2) == 0)
                marker = marker(1:(end - 1));
            else
                marker = [marker (i - 1)];
            end
            flag = 0;
        elseif (flag == 1) & (saccadetf(i) == 0) & (i == length(saccadetf))
                    marker = [marker (i - 1) i];
        elseif (flag == 0) & (i == length(saccadetf))
            marker = [marker i];
        end
    end
    if saccadetf(1) == 1	%in case start of trial is a saccade, marker will begin with two 1's
        sacStart = marker(3);
        marker = [1, marker(4:end)];
    end
    if saccadetf(end) == 1	%in case end of trial is a saccade
        sacEnd = marker(end);
    end
    
    %%%%%%%%%%%%%%%%%%%%% 	Redefinition Rules    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  -  Find the FIRST acceleration peak in the ascending limb of the saccade velocity
    %  ---  Fit a line from the above point, with the same slope.  The beginning of the saccade
    %       is defined by this line's intersection with the saccade threshold.
    %  ---  If this intersection point occurs after the point of max acceleration, the point of max acceleration
    %       (or the one before it) is used instead
    %
    %  -  Find the LAST significant acceleration peak in the descending limb of the saccade velocity
    %  ---  The peak must cross Args.SmallSaccadeDecelThresh to be significant
    %  ---  If the saccade is "normal", the first point at  which the deceleration curve crosses
    %       Args.DecelerationThresh with a positive slope after this last peak is defined as the end of the saccade.
    %  ---  If the saccade is smaller, Args.SmallSaccadeDecelThresh is used instead of Args.DecelerationThresh
    %
    %  -  If the new endpoints don't fit between the bordering saacades, an error message is produced.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %redefine saccade starting and ending points 
    for i = 2:2:(length(marker) - 2)
        %Find the acceleration of the signal
        acc = diff(realVel(marker(i):marker(i + 1)));
        [upSlope, up] = max(acc);
        %Adjust the max acceleration index for its actual position,
        upInd = up + marker(i) - 1;
        ascending = acc(1:up);
        %If there is more than one peak in the ascending acceleration
        %curve, we want to use the first one for our fit.
        peaks = find(diff(ascending) <= 0);
        if ~isempty(peaks)       
            %There is more than one peak, but how many more?
            %Find the first peak, if there's more than one extra
            firstPeakEnd = (peaks(min(find(diff(peaks) > 1)))) + 1;
            if isempty(firstPeakEnd)    %(There was only one extra peak)
                firstPeakEnd = max(peaks) + 1;
            end
            originalUpSlope = upSlope;
            originalUp = up;
            originalUpInd = upInd;
            %Find the point/value of max acceleration of the first peak
            [upSlope, up] = max(acc(1:firstPeakEnd));
            upInd = up + marker(i) - 1;
            if up == 1
                %This is most likely an insignificant "blip."  Remove the
                %peak accordingly and repeat the peak finding algorithm.
                newAscending = acc(firstPeakEnd:originalUp);
                peaks = find(diff(newAscending) <= 0);
                if ~isempty(peaks)       
                    %There is more than one peak, but how many more?
                    %Find the first peak, if there's more than one extra
                    secondPeakEnd = peaks(min(find(diff(peaks) > 1)));
                    if isempty(secondPeakEnd)    %(There was only one extra peak)
                        secondPeakEnd = max(peaks);
                    end
                    %Find the point/value of max acceleration of the first peak
                    [upSlope, up] = max(acc(1:secondPeakEnd));
                    upInd = up + marker(i) + firstPeakEnd - 2;
                else
                    up = originalUp;
                    upInd = originalUp + marker(i) - 1;
                    upSlope = originalUpSlope;
                end
            end
        end
        %If the point of max acceleration occurs before SacThresh is crossed...
        if up == 1
            %Look at the data prior to where saccade threshold was crossed
            newAcc = diff(realVel(marker(i - 1):marker(i + 1)));
            [upSlope, up] = max(newAcc);
            newUpInd = up + marker(i - 1) - 1;
            if exist('originalUpInd', 'var') && (newUpInd == originalUpInd)
                %If we end up where we started, use the fit.
                upVel = realVel(upInd);        
                %And, using point-slope formula, find the point at which a line through
                %the point of max accel., at that slope, would cross Args.SacThresh
                newL = round(originalUpInd + ((Args.SacThresh - upVel)/originalUpSlope));
            else
                %Need to adjust the index for its actual position
                newL = up + marker(i - 1) - 2;
            end
        else
            %Find the velocity at that point,
            upVel = realVel(upInd);        
            %And, using point-slope formula, find the point at which a line through
            %the point of max accel., at that slope, would cross Args.SacThresh
            newL = round(upInd + ((Args.SacThresh - upVel)/upSlope));
        end
        
        %On the descending limb of the saccade, the maximum velocity
        %appears too large for accurate fitting.
        %Find the point at which the deceleration crosses the appropriate
        %deceleration threshhold instead.
        %However, if there is more than one peak in the descending
        %acceleration curve, we want to pick the crossing after the last
        %significant (greater than Args.MaxAccelerationThresh) peak as our saccade endpoint.
        [junk, down] = min(acc);
        %if there's a chance that the original saccade end occurs before
        %the point of maximum deceleration, expand the section of data accordingly.
        if down == length(acc)
            acc = diff(realVel(marker(i):marker(i + 2)));
            newAcc = acc;
            [junk, down] = min(acc);
            expand = 1;
        else
            expand = 0;
        end
        descending = acc(down:end);
        %Are there peaks in the acceleration between the max deceleration point
        %and saccade threshold crossing?
        reAccel = find(diff(descending) <= 0);
        if ~isempty(reAccel)
            %If so, find the indices of each..
            peaks = reAccel([0; find(diff(reAccel) ~= 1)] + 1);
            %Find the acceleration values at these peaks.
            peakValues = descending(peaks);
            %Find the LAST peak which is significant.
            whichPeak = max(find(peakValues >= Args.MaxAccelerationThresh));
            if ~isempty(whichPeak)
                %Adjust the index of the peak to index into "acc"
                lastPeak = peaks(whichPeak) + down - 1;
            else
                %If none of the peaks are significant, use the point of max
                %deceleration as a starting point to continue.
                lastPeak = down;
            end
        else
            %If there are no peaks, use the point of max
            %deceleration as a starting point to continue.
            lastPeak = down;
        end
        %Does this end section cross our threshold for normal saccades?
        decelCrossings = length(find(diff((acc(lastPeak:end)) >= Args.DecelerationThresh)));
        %There's a chance that the endpoint that we want occurs after
        %the original saccade end.
        if ~expand
            if acc(end) < Args.DecelerationThresh
                newAcc = diff(realVel(marker(i):marker(i + 2)));
            elseif ((decelCrossings == 0) & (acc(end) < Args.SmallSaccadeDecelThresh))
                %Accomplishes the same as above for small saccades
                newAcc = diff(realVel(marker(i):marker(i + 2)));
            else
                newAcc = acc;
            end
        end
        decel = find((newAcc(lastPeak:end)) <= Args.DecelerationThresh);
        decel2 = find((acc(lastPeak:end)) <= Args.DecelerationThresh);
        %Smaller saccades may not reach the usual deceleration threshold.
        if isempty(decel)
            decel = find((newAcc(lastPeak:end)) <= Args.SmallSaccadeDecelThresh);
        end
        if isempty(decel2)
            decel2 = find((acc(lastPeak:end)) <= Args.SmallSaccadeDecelThresh);
        end
        %In some cases, particularly if small saccades are being
        %ignored by using a high threshold, simply choosing the last
        %threshold crossing will pick the descending limb of the wrong saccade.
        %This line of code takes care of that.
        firstDecelCrossing = decel(min(find(diff(decel) ~= 1)));
        %Usually, though, picking the last crossing works
        if isempty(firstDecelCrossing) & ~isempty(decel)
            firstDecelCrossing = decel(end);
        end
        lastDecel2Crossing = max(decel2);
        %If neither threshold is crossed, use the original endpoint.
        if isempty(decel)
            newR = marker(i + 1);
        else
            crossings = sort([firstDecelCrossing lastDecel2Crossing]);
            finalCrossing = crossings(end);
            %Otherwise, adjust the index that we've found using the
            %algorithm.  The "-2" here adjusts for eah step that I had to
            %make into the acceleration vector.
            newR = marker(i) + lastPeak + finalCrossing - 2;
        end

        if (newL > marker(i - 1)) & (newL < marker(i + 1))     %make sure this still lies between the current markers
            marker(i) = newL;
        elseif display_flag
            fprintf('Trouble reassigning the beginning of saccade %i\n', i/2)
        end
        if ~isempty(newR) && ((newR > marker(i)) & (newR < marker(i + 2)))      %make sure this still lies between the current markers
            marker(i + 1) = newR;
        elseif display_flag
            fprintf('Trouble reassigning the end of saccade %i\n', i/2)
        end
    end  %for length of marker
    
    %Get rid of the saccades that are less than Args.MinSacPR (5 min' of arc) long.
    change = [];
    PR = [];
    for i = 2:2:length(marker) - 1
        dist = dist2(filtered([marker(i):marker(i+1)], :), filtered([marker(i):marker(i+1)], :));
        max_dist = max(max(dist));
        amp = sqrt(max_dist);
        if amp < Args.MinSacPR
            saccadetf(marker(i):marker(i + 1)) = zeros(1, marker(i + 1) - marker(i) + 1);
            change = [change i];
        else
            PR = [PR amp];
        end
    end
    if ~isempty(change)
        for i = length(change):-1:1
            marker = [marker(1:change(i) - 1) marker((change(i) + 2):length(marker))];
        end
    end
    
    %now fix saccadetf to correspond to the new markers
    saccadetf = zeros(length(filtered), 1);
    for i=2:2:(length(marker) - 1)
        saccadetf(marker(i):marker(i + 1)) = 1;
    end
    %make sure that our manner of differentiation didn't leave a single
    %zero at the end of the saccadetf vector
    if saccadetf(end - 1) & (saccadetf(end) == 0)
        saccadetf(end) = 1;
    end
    fixationtf = 1 - saccadetf;
    %Adjust "fixationtf" if the trial begins or ends with a saccade.
    if sacStart
        fixationtf(1:sacStart) = 0;
    end
    if sacEnd
        fixationtf(sacEnd:end) = 0;
    end
    
    %Replace sections that were originally NaN's with  zeros in the tf vectors
    if NaNflag
        NaNskip = [];
        for i = 1:numNaN
            [dummy ind] = min(abs(NaNstart(i) - marker));
            %ind is index of start of fixation before NaN
            if ind < length(marker)	%if it is during the last fixation then it will be ignored anyway
                if saccadetf(marker(ind) + 1) == 1
                    ind = [(ind - 2) (ind - 1) ind (ind + 1)];
                else
                    ind = [(ind - 1) ind (ind + 1) (ind + 2)];
                end
            end
            s = find(ind == 0);	%if at start of trial
            if ~isempty(s)
                ind = ind((s + 1):length(ind));
            end
            s = find(ind > length(marker));	%if at end of trial
            if ~isempty(s)
                ind = ind(1:(s - 1));
            end
            NaNskip = [NaNskip marker(ind(1)) marker(ind(length(ind)))];
        end
        for i=1:2:length(NaNskip)
            fixationtf(NaNskip(i):NaNskip(i + 1)) = 0;
            saccadetf(NaNskip(i):NaNskip(i + 1)) = 0;
        end
    end
    
    %ignore saccades that do not have a maximum acceleration of
    %MaxAccelerationThresh, and throw out surrounding fixations
    for i = 2:2:length(marker) - 1
        %Find the acceleration of the signal
        acc = diff(realVel(marker(i):marker(i + 1)));
        if max(acc) < Args.MaxAccelerationThresh
            saccadetf(marker(i):marker(i + 1)) = zeros(marker(i + 1) - marker(i) + 1, 1);
            if i == length(marker) - 1      %If looking at the last event, only worry about what was in front
                fixationtf(marker(i - 1):marker(i + 1)) = zeros(marker(i + 1) - marker(i - 1) + 1, 1);
                if display_flag
                    figure(h2)
                    hold on
                    plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 1), 'k.')
                    plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 2), 'k.')
                    hold off
                    fprintf('Data from %i to %i thrown out because the intervening saccade did not reach the acceleration threshold.\n', marker(i - 1), marker(i + 1))
                end
            else
                fixationtf(marker(i - 1):marker(i + 2)) = zeros(marker(i + 2) - marker(i - 1) + 1, 1);
                if display_flag
                    figure(h2)
                    hold on
                    plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 1), 'k.')
                    plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 2), 'k.')
                    hold off
                    fprintf('Data from %i to %i thrown out because the intervening saccade did not reach the acceleration threshold.\n', marker(i - 1), marker(i + 2))
                end
            end
        end
    end
    
    %%%%%%%%%%%%%%%%% 	Lazy Saccade Detection 	%%%%%%%%%%%%%%%%%%
    
    %ignore saccades that last more than 'Args.LazySaccade', and throw out
    %surrounding fixations
    for i = 2:2:length(marker) - 1
        if (marker(i + 1) - marker(i)) > Args.LazySaccade
            saccadetf(marker(i):marker(i + 1)) = zeros(marker(i + 1) - marker(i) + 1, 1);
            if i == length(marker) - 1      %If looking at the last event, only worry about what was in front
                fixationtf(marker(i - 1):marker(i + 1)) = zeros(marker(i + 1) - marker(i - 1) + 1, 1);
                if display_flag
                    figure(h2)
                    hold on
                    plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 1), 'k.')
                    plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 2), 'k.')
                    hold off
                    fprintf('Data from %i to %i thrown out because the intervening saccade was too long.\n', marker(i - 1), marker(i + 1))
                end
            else
                fixationtf(marker(i - 1):marker(i + 2)) = zeros(marker(i + 2) - marker(i - 1) + 1, 1);
                if display_flag
                    figure(h2)
                    hold on
                    plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 1), 'k.')
                    plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 2), 'k.')
                    hold off
                    fprintf('Data from %i to %i thrown out because the intervening saccade was too long.\n', marker(i - 1), marker(i + 2))
                end
            end
        end
    end
    
    %loop over marker
    if display_flag
        figure(h4);
        title('Lazy Saccade Detection')
        hold on
        tt = .02:.01:1;
        yy = (Args.LazySLope * tt) + Args.LazyIntersect;
        plot(tt, yy)
        xlabel('max velocity')
        ylabel('duration')
        hold on
    end
    
    %use max velocity and duration of saccade
    %if event falls above line dur = 55 * max_velocity + 49
    %this line was determined by examining scatterplots from multiple sessions

    for i = 1:length(marker) - 1
        if saccadetf(marker(i) + 1)
            section_v = filtered((marker(i)):(marker(i + 1)), 1);
            section_h = filtered((marker(i)):(marker(i + 1)), 2);
            vel_v = max(abs(diff(section_v, 1)));
            vel_h = max(abs(diff(section_h, 1)));
            mv = max(vel_v, vel_h);
            y = [((Args.LazySLope * mv) + Args.LazyIntersect) length(section_v)];
            if display_flag
                figure(h4)
                plot(max(vel_v, vel_h), y(2), 'r*')
                zoom on
            end
            if y(2) > y(1)  %then lazy saccade
                %remove saccade and neighboring events (if possible)
                saccadetf(marker(i):marker(i + 1)) = zeros(marker(i + 1) - marker(i) + 1, 1);
                if i == length(marker) - 1      %If looking at the last event, only worry about what was in front
                    fixationtf(marker(i - 1):marker(i + 1)) = zeros(marker(i + 1) - marker(i - 1) + 1, 1);
                    if display_flag
                        figure(h2)
                        hold on
                        plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 1), 'k.')
                        plot(marker(i - 1):marker(i + 1), filtered(marker(i - 1):marker(i + 1), 2), 'k.')
                        hold off
                        fprintf('Data from %i to %i thrown out because the intervening saccade was lazy.\n', marker(i - 1), marker(i + 1))
                    end
                else
                    fixationtf(marker(i - 1):marker(i + 2)) = zeros(marker(i + 2) - marker(i - 1) + 1, 1);
                    if display_flag
                        figure(h2)
                        hold on
                        plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 1), 'k.')
                        plot(marker(i - 1):marker(i + 2), filtered(marker(i - 1):marker(i + 2), 2), 'k.')
                        hold off
                        fprintf('Data from %i to %i thrown out because the intervening saccade was lazy.\n', marker(i - 1), marker(i + 2))
                    end
                end
            end
        end
    end
    
    %If the session is free-viewing, take off the start from every trial...
    if iniInfo.win_movie
        if saccadetf(1) == 1
            saccadetf(1:min(find(fixationtf))) = 0;
        elseif fixationtf(1) == 1
            fixationtf(1:min(find(saccadetf))) = 0;
        end
        
        %...and the finish from every trial
        if saccadetf(end) == 1
            if isempty(find(fixationtf))
                saccadetf=zeros(size(saccadetf));
            else
                saccadetf(max(find(fixationtf)):end) = 0;
            end
        elseif fixationtf(end) == 1
            finalFixStart = max(find(diff(fixationtf)));
            fixationtf(finalFixStart:end) = 0;
        end
    else
        %If the session is not free viewing, still check to see if the
        %trial begins or ends with a short fixation
        if fixationtf(1) & (marker(2) <= Args.ShortFix)
            fixationtf(1:marker(2)) = 0;
        end
        if fixationtf(end) & (length(fixationtf) - marker(end) <= Args.ShortFix)
            fixationtf(marker(end):length(fixationtf)) = 0;
        end
    end
    %If the session is fixating, and the Args.IgnoreEarlySaccade flag is
    %on, ignore the first saccade of the trial if it occurs in the first
    %Args.EarlySaccade seconds
    if (length(filtered) > Args.EarlySaccade) && ((iniInfo.win_movie == 0) & Args.IgnoreEarlySaccade ...
            & (sacStart == 0) & (marker(2) < Args.EarlySaccade))
        fixationtf(1:marker(3)) = 0;
        saccadetf(1:marker(3)) = 0;
        if display_flag
            fprintf('First fixation and saccade from 1 to %i was removed.\n', marker(3))
        end
    end
            
    %In order to remove all of the unbounded short saccades and fixations
    %we'll use iterations.
    change = 1;
    while change
        change = 0;
        %Remove lone sacccades and unbounded microsaccades
        for i = 2:(length(marker) - 1)
            %if there's no fixation on the left side...
            if (saccadetf(marker(i) + 1)) & (fixationtf(marker(i) - 1) == 0)
                ampv = abs(filtered(marker(i), 1) - filtered(marker(i + 1), 1));
                amph = abs(filtered(marker(i), 2) - filtered(marker(i + 1), 2));
                if (ampv < 0.5) & (amph < 0.5)      %if microsaccad-ish, remove
                    saccadetf(marker(i):marker(i + 1)) = 0;
                    if display_flag
                        fprintf('Small, unbounded saccade from %i to %i was removed.\n', marker(i), marker(i + 1))
                    end
                    change = 1;
                elseif fixationtf(marker(i + 1) + 1) == 0 & (Args.TossLoneSac)  %if the saccade is lone, remove
                    saccadetf(marker(i):marker(i + 1)) = 0;
                    if display_flag
                        fprintf('Lone saccade from %i to %i was removed.\n', marker(i), marker(i + 1))
                    end
                    change = 1;
                end
                %and/or the right side of the saccade
            elseif (saccadetf(marker(i) + 1)) & (marker(i + 1) < length(saccadetf))
                if fixationtf(marker(i + 1) + 1) == 0
                    ampv = abs(filtered(marker(i), 1) - filtered(marker(i + 1), 1));
                    amph = abs(filtered(marker(i), 2) - filtered(marker(i + 1), 2));
                    if (ampv < 0.5) & (amph < 0.5)      %if microsaccad-ish, remove
                        saccadetf(marker(i):marker(i + 1)) = 0;
                        if display_flag
                            fprintf('Small, unbounded saccade from %i to %i was removed.\n', marker(i), marker(i + 1))
                        end
                        change = 1;
                    end
                end
            end
            %Remove unbounded short fixations;  Note that although "lazy"
            %and long saccades have been removed, their markers remain.
            %If the fixation follows a saccade marker
            if fixationtf(marker(i) + 1) & (saccadetf(marker(i) - 1) == 0) & (marker(i + 1) - marker(i) <= Args.ShortFix)
                fixationtf(marker(i):marker(i + 1)) = 0;
                if display_flag
                    fprintf('Short, unbounded fixation from %i to %i was removed.\n', marker(i), marker(i + 1))
                end
                change = 1;
            elseif (fixationtf(marker(i) + 1)) & (marker(i + 1) == length(fixationtf))
                if (marker(i + 1) - marker(1) <= Args.ShortFix)
                    fixationtf(marker(i):marker(i + 1)) = 0;
                    if display_flag
                        fprintf('Short, unbounded fixation from %i to %i was removed.\n', marker(i), marker(i + 1))
                    end
                    change = 1;
                end
            elseif (fixationtf(marker(i) + 1)) & (saccadetf(marker(i + 1) + 1) == 0) & (marker(i + 1) - marker(i) <= Args.ShortFix)
                fixationtf(marker(i):marker(i + 1)) = 0;
                if display_flag
                    fprintf('Short, unbounded fixation from %i to %i was removed.\n', marker(i), marker(i + 1))
                end
                change = 1;
            end
        end
    end
    
    %doublecheck that all tf matices are not overlapping
    overlap = find(((fixationtf + saccadetf) ~= 0) & ((fixationtf + saccadetf) ~= 1));
    if ~isempty(overlap)
        status = -1;
        fprintf('Overlap Error %d', overlap);
        break;
    end
    
    
    
    %create eye structure
    saccadecounter = 0;
    saccadeflag = 0;
    fixationcounter = 0;
    fixationflag = 0;
    %create empty matrix incase no events happen
    eye.saccade(trial).start = [];
    eye.saccade(trial).finish = [];
    eye.fixation(trial).start = [];
    eye.fixation(trial).finish = [];
    %For now, I'll create this dummy field until downstream scripts can be
    %fixed to be "drift-free"
    eye.drift(trial).start = [];
    eye.drift(trial).finish = [];

    
    trialsac = 0;
    trialfix = 0;
    for i=1:length(saccadetf)
        if (saccadetf(i) == 1) & (saccadeflag == 0)
            saccadeflag = 1;
            trialsac = 1;
            saccadecounter = saccadecounter + 1;
            eye.saccade(trial).start(saccadecounter) = i;
            
            out.sacStart = [out.sacStart;i];
            
            tempSacSetIndex = [1 trial trial countSac]; 
            out.sacSetIndex = [out.sacSetIndex; tempSacSetIndex];
            countSac = countSac +1;
        elseif (saccadeflag == 1) & (saccadetf(i) == 0)
            eye.saccade(trial).finish(saccadecounter) = i;
            
            out.sacEnd = [out.sacEnd; i];
            saccadeflag = 0;
            %find max velocity during saccade
            [val, ind] = max(realVel(eye.saccade(trial).start(saccadecounter):i, :));
            eye.saccade(trial).max_velocity(:, saccadecounter) = [ind + eye.saccade(trial).start(saccadecounter) - 1; val];
            
            out.sacMaxVel = [out.sacMaxVel; val];
            out.sacMaxVelTime = [out.sacMaxVelTime; ind + eye.saccade(trial).start(saccadecounter) - 1];
            %find max acceleration during saccade
            eye.saccade(trial).max_acc(:, saccadecounter) = max(diff(realVel(eye.saccade(trial).start(saccadecounter):i, :)));
            
            %%%%%%%%%%%%%%%Computation of saccade amplitude
            
            saccade_section = filtered(eye.saccade(trial).start(saccadecounter):eye.saccade(trial).finish(saccadecounter), :);
            %Find the distances between every 2 points
            dist = dist2(saccade_section, saccade_section);
            max_dist = max(max(dist));
            PR = sqrt(max_dist);
            out.sacAmpl = [out.sacAmpl; PR];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif (saccadeflag == 1) & (i == length(saccadetf))
            eye.saccade(trial).finish(saccadecounter) = i;
            out.sacEnd = [out.sacEnd; i];
            %find max velocity during saccade
            [val, ind] = max(realVel(eye.saccade(trial).start(saccadecounter):i, :));
            eye.saccade(trial).max_velocity(saccadecounter) = [ind + eye.saccade(trial).start(saccadecounter) - 1; val];
            %find max acceleration during saccade
            eye.saccade(trial).max_acc(:, saccadecounter) = max(diff(realVel(eye.saccade(trial).start(saccadecounter):i, :)));
            out.sacMaxVel = [out.sacMaxVel; val];
            out.sacMaxVelTime = [out.sac.MaxVelTime; ind + eye.saccade(trial).start(saccadecounter) - 1];
             %%%%%%%%%%%%%%%Computation of saccade amplitude
            
            saccade_section = filtered(eye.saccade(trial).start(saccadecounter):eye.saccade(trial).finish(saccadecounter), :);
            %Find the distances between every 2 points
            dist = dist2(saccade_section, saccade_section);
            max_dist = max(max(dist));
            PR = sqrt(max_dist);
            out.sacAmpl = [out.sacAmpl; PR];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
            
        end
        
        if (fixationtf(i) == 1) & (fixationflag == 0)
            fixationflag = 1;
            trialfix = 1;
            fixationcounter = fixationcounter + 1;
            eye.fixation(trial).start(fixationcounter) = i;
            
            out.fixStart = [out.fixStart; i];
            
            tempFixSetIndex = [1 trial trial countFix]; 
            out.fixSetIndex = [out.fixSetIndex; tempFixSetIndex]; 
            countFix = countFix + 1;
            trialfix = 1;
        elseif (fixationflag == 1) & (fixationtf(i) == 0)
            eye.fixation(trial).finish(fixationcounter) = i;
            out.fixEnd = [out.fixEnd; i];
            
            buffer = 15;
            min_length = (buffer * 3) + 1;
            
            velocity = realVel(eye.fixation(trial).start(fixationcounter) + buffer : i - buffer, :);
            
            if  (eye.fixation(trial).finish(fixationcounter) - eye.fixation(trial).start(fixationcounter)) < min_length
                velocity = unfilVel(eye.fixation(trial).start(fixationcounter) : i, :);
            end
            
            [maxval, maxind] = max(velocity);
            out.fixMaxVelTime = [out.fixMaxVelTime; maxind + eye.fixation(trial).start(fixationcounter) - 1];
            out.fixMaxVel = [out.fixMaxVel; maxval];
            
            out.fixMeanVel = [out.fixMeanVel; mean(velocity)];
            
            fixationflag = 0;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%Amplitude
            fixation_section = filtered(eye.fixation(trial).start(fixationcounter) + buffer : eye.fixation(trial).finish(fixationcounter) - buffer, :);
            %Find the distances between every 2 points
            dist = dist2(fixation_section, fixation_section);
            max_dist = max(max(dist));
            PR = sqrt(max_dist);
            out.fixAmpl = [out.fixAmpl; PR];
            %%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif (fixationflag == 1) & (i == length(fixationtf))
            eye.fixation(trial).finish(fixationcounter) = i;
            out.fixEnd = [out.fixEnd; i];
            
            buffer = 15;
            min_length = (buffer * 3) + 1;
            if  (eye.fixation(trial).finish(fixationcounter) - eye.fixation(trial).start(fixationcounter)) < min_length
                buffer = 0;
            end
            velocity = realVel(eye.fixation(trial).start(fixationcounter) + buffer : i - buffer, :);
            
            [maxval, maxind] = max(velocity);
            out.fixMaxVelTime = [out.fixMaxVelTime; maxind + eye.fixation(trial).start(fixationcounter) - 1];
            out.fixMaxVel = [out.fixMaxVel; maxval];
            
            out.fixMeanVel = [out.fixMeanVel; mean(velocity)];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%Amplitude
            fixation_section = filtered(eye.fixation(trial).start(fixationcounter) + buffer : eye.fixation(trial).finish(fixationcounter) - buffer, :);
            %Find the distances between every 2 points
            dist = dist2(fixation_section, fixation_section);
            max_dist = max(max(dist));
            PR = sqrt(max_dist);
            out.fixAmpl = [out.fixAmpl; PR];
            %%%%%%%%%%%%%%%%%%%%%%%%%%
        end
         
    end
    if trialsac == 0 % case for no saccade in the trial
        out.sacStart = [out.sacStart;NaN];
        tempSacSetIndex = [1 trial trial 0]; 
        out.sacSetIndex = [out.sacSetIndex; tempSacSetIndex];
        out.sacEnd = [out.sacEnd; NaN];
        out.sacMaxVel = [out.sacMaxVel; NaN];
        out.sacMaxVelTime = [out.sacMaxVelTime; NaN];
        out.sacAmpl = [out.sacAmpl; NaN];
    end
    if trialfix == 0 % case for no fixation in the trial
        out.fixStart = [out.fixStart;NaN];
        tempfixSetIndex = [1 trial trial 0]; 
        out.fixSetIndex = [out.fixSetIndex; tempfixSetIndex];
        out.fixEnd = [out.fixEnd; NaN];
        out.fixMaxVel = [out.fixMaxVel; NaN];
        out.fixMaxVelTime = [out.fixMaxVelTime; NaN];
        out.fixAmpl = [out.fixAmpl; NaN];
        out.fixMeanVel = [out.fixMeanVel; NaN];
    end
    %%%%%%%%some indices to test the setIndex variable
%     tempSSI = [1 trial saccadecounter]; 
%     temp.sacSetIndex = [temp.sacSetIndex; tempSSI];
%     tempFSI = [1 trial fixationcounter]; 
%     temp.fixSetIndex = [temp.fixSetIndex; tempFSI]; 
    %%%%%%%%%%%%%%%%%%%%
    if display_flag
        figure(h2)
        hold on
        %plot results of classification
        saccade = filtered((1:end), :) .* [saccadetf, saccadetf];
        fixation = filtered((1:end), :) .* [fixationtf, fixationtf];
        
        i = find(saccadetf == 0);
        saccade(i,:) = 100;
        i = find(fixationtf == 0);
        fixation(i,:) = 100;
        
        plot(saccade(:,1), 'r.')
        plot(fixation(:,1), 'g.')
        plot(saccade(:,2), 'r.')
        plot(fixation(:,2), 'g.')
        
        a = axis;
        axis([a(1) a(2) -30 30]);
        legend('vertical raw','horizontal raw','saccade','fixation')
        title(filename)
        xlabel('Time (ms)');
        ylabel('Eye Position (degrees)')
        hold off
        zoom on
        
%         figure(h3)
%         hold on
%         a=axis;
%         plot3(saccade(:,2), saccade(:,1), 1:(length(saccade)), 'r.')
%         plot3(fixation(:,2), fixation(:,1), 1:(length(fixation)), 'g.')
%         hold off
%         axis(a);
%         zoom on
        
        figure(h1)
        zoom on
        
        % get keyboard input to see what to do next
        
        key = input('RETURN - Next Trial; p - Previous trial; N - Trial N; q - Quit: ','s');
        n = str2num(key);
        if strcmp(key,'p')
            trial = trial - 1;
            if trial<1
                trial = 1;
            end
        elseif strcmp(key,'q')
        	break;
        elseif ~isempty(n)
            if n>1 & n<=numTrials
                trial = n;
            end	
        else
            trial = trial + 1;
        end
        
    else 
        trial = trial + 1;
    end
end
fprintf('\n');
warning on MATLAB:divideByZero
