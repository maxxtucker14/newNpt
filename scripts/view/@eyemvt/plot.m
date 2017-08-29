function obj = plot(obj,varargin)
%@eyemvt/plot Plots data from EYEMVT object
%   OBJ = plot(OBJ,N,VARARGIN) plots statistics on the eye traces.
%   
%   . The following optional input arguments are valid:
%      Fix - flag that specifies the plotting of fixation instead of the default 
%            saccades.
%      Hist - flag that specifies the plotting of an histogram and should
%             be followed by any of the following:
%
%           FixMeanVel -  the plotting the mean velocities of the fixations.
%           MaxVel - the plotting of the maximum velocity 
%           Dur - the plotting of the duration of saccades/fixation 
%           MaxVelTime - the plotting of the occurence of the maximum velocity 
%           Ampl - the plotting of the amplitude of saccades/fixations 
%     
%           bins - parameter that specifies the number of bins to use in the
%             histograms
%           binsEdges - parameter that specifies the limits of the bins in the
%                  histograms
%      PlotVelAcc - flag that specifies the plotting of the eye movements 
%                   velocity, filtered and with the acceleration 
%
%   OBJ = plot(OBJ,N) plots the eye traces of trial N.
%
%   

Args = struct('Fix',0,'Hist',0,'FixMeanVel',0,'MaxVel',0,'Dur',0,'MaxVelTime',0,'Ampl',0,'PlotVelAcc',0,'bins',20,'binsEdges',[]);
Args.flags = {'Fix','Hist','FixMeanVel','MaxVel','Dur','MaxVelTime','Ampl','PlotVelAcc'};
[Args,varargin2] = getOptArgs(varargin,Args,'remove',{'Hist'});


% set default variables
% if there are numeric arguments, we are probably using the first form

if(Args.Fix)
    SetIndex = obj.data.fixSetIndex;
    MaxVel = obj.data.fixMaxVel;
    Start = obj.data.fixStart;
    End = obj.data.fixEnd;
    MaxVelTime = obj.data.fixMaxVelTime;
    Ampl = obj.data.fixAmpl;
else
    SetIndex = obj.data.sacSetIndex;
    MaxVel = obj.data.sacMaxVel;
    Start = obj.data.sacStart;
    End = obj.data.sacEnd;
    MaxVelTime = obj.data.sacMaxVelTime;
    Ampl = obj.data.sacAmpl;
end

[numevents,dataindices,Mark] = get(obj,'Number',varargin2{:});

if (Args.Hist) % histogram case
    if (~isempty(Args.NumericArguments))
        n = Args.NumericArguments{1};
        ind  = find(dataindices(:,4) == n);
        limit = dataindices(ind,1);
    else 
        n = numevents;
        limit = dataindices(:,1);
    end
    
    
    if (Args.MaxVel) 
        if (isempty(Args.binsEdges))
            [H N] = hist(MaxVel(limit),Args.bins);
        else
            [H N] = histcie(MaxVel(limit),Args.binsEdges);
            H = H';
            N = N';
        end
        
        labels = 'Maximum Velocity [degrees/microsec]';
    end
    if (Args.Dur) 
        if (isempty(Args.binsEdges))
            [H N] = hist(End(limit)-Start(limit),Args.bins);
        else
            [H N] = hist(End(limit)-Start(limit),Args.binsEdges);
            H = H';
            N = N';
        end
        
        labels = 'Duration [microsec]';
    end
    if (Args.MaxVelTime) 
        if (isempty(Args.binsEdges))
            [H N] = hist(MaxVelTime(limit),Args.bins);
        else
            [H N] = hist(MaxVelTime(limit),Args.binsEdges);
            H = H';
            N = N';
        end
        labels = 'Time [microsec]';
    end
    if (Args.Ampl) 
        if (isempty(Args.binsEdges))
            [H N] = hist(Ampl(limit),Args.bins);
        else
            [H N] = hist(Ampl(limit),Args.binsEdges);
            H = H';
            N = N';
        end 
        labels = 'Amplitude [degrees]';
    end
    if(Args.FixMeanVel) 
        if (isempty(Args.binsEdges))
            [H N] = hist(obj.data.fixMeanVel(limit),Args.bins);
        else
            [H N] = hist(obj.data.fixMeanVel(limit),Args.binsEdges);
            H = H';
            N = N';
        end
        labels = 'Mean Velocity [degrees/microsec]';
    end 
    if (isempty(Args.binsEdges))
        bar(N,H)
    else
        bar(Args.binsEdges,H,'histc')
    end
    xlabel(labels)
    ylabel('#')
    
elseif  (~Args.Hist) % case when the data are presented trial by trial
    if (~isempty(Args.NumericArguments))
        trialn = dataindices(Args.NumericArguments{1},3);
    else 
        trialn = dataindices(1,3);
    end
    
    % find first row that has this trial number in setIndex
    
    rfix = find(obj.data.fixSetIndex(:,2) == dataindices(Args.NumericArguments{1},2)); 
    rsac = find(obj.data.sacSetIndex(:,2) == dataindices(Args.NumericArguments{1},2)); 
    if (~isempty(rsac))
        chosenr = rsac;
        chosenIndex = obj.data.sacSetIndex;
        
    else
        chosenr = rfix;
        chosenIndex = obj.data.fixSetIndex;
    end
    sessionn = find(chosenIndex(:,2) == dataindices(Args.NumericArguments{1},2));
    
    
    pathd = obj.nptdata.SessionDirs{chosenIndex(sessionn(1),1)};
    
    
    wind = find(pathd == '\'); % to deal with obj creawted in windows machines
    unix = find(pathd == '/');
    if isempty(wind)
        platform = unix;
        cd(pathd)
    else
        platform = wind;
    end
   
    directory = pathd(platform(end)+1 : end);
    [pdir,cdir] = getDataDirs('eye','relative','CDNow');% cd(directory)
    if(isempty(cdir))
            % if there is an eye subdirectory, we are probably in the session dir
            % so change to the eye subdirectory
            [r,a] = ispresent('eye','dir','CaseInsensitive');
            if r
                cdir = pwd;
                cd(a);
            end
        end
    eobj = eyes('auto',varargin2{:}); 
    [data] = get(eobj,'DataDegrees',chosenIndex(chosenr(1),3));
    
    if(~Args.PlotVelAcc)
        plot(eobj,chosenIndex(chosenr(1),3));
        hold on
        
        for saccade = 1 : length(rsac)
            xstart = obj.data.sacStart(rsac(saccade));
            xend = obj.data.sacEnd(rsac(saccade));
            if(~isnan(xstart))
                plot([xstart-1:xend-1],data(1,xstart:xend),'rx');
                plot([xstart-1:xend-1],data(2,xstart:xend),'rx');
                if (Mark == 1) & (dataindices(Args.NumericArguments{1},1) == rsac(saccade))
                    text(xstart+10,(data(1,xstart)+data(2,xstart))/2,sprintf('saccade n#%d',rsac(saccade)));
                end
            end
        end
        %%%%%%%%%%%%%%%%Fixation
        
        for fixation = 1 : length(rfix)
            xstart = obj.data.fixStart(rfix(fixation));
            xend = obj.data.fixEnd(rfix(fixation));
            if(~isnan(xstart))
                plot([xstart-1:xend-1],data(1,xstart:xend),'yo');
                plot([xstart-1:xend-1],data(2,xstart:xend),'yo');
                %         if (~isempty(Args.fixSelected)) & (~isempty(find(rfix(fixation) == Args.fixSelected)))
                %             text(xstart+10,(data(1,xstart)+data(2,xstart))/2,sprintf('fixation n#%d',rfix(fixation))); 
                %         end
            end
        end
        % do something specific to this object
        hold off
    end
    
    if(Args.PlotVelAcc)
        
        order = 6;
        b = ones(1, order)/order;
        filtered = filtfilt(b, 1, data');
        delta_vert = diff(filtered(:,1));
        delta_horiz = diff(filtered(:,2));
        distance = sqrt(delta_vert.^2 + delta_horiz.^2);
        unfilVel = distance * obj.data.samplingRate;
        order = 15;	
        b = ones(1, order)/order;
        realVel = filtfilt(b, 1, unfilVel);  
        
        plot(realVel, 'b.-')
        hold on
        plot(unfilVel, 'r.-')
        plot(diff(realVel), 'g.-')
        
        legend('Filtered Velocity (deg/s)', 'Unfiltered Velocity (deg/s)', ...
            'Filtered Acceleration (deg/s/s)')
        hold off
        xlabel('Time [ms]')
        
    end
end
