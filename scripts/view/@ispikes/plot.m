function [vi,varargout] = plot(vi,varargin)
%ISPIKES/PLOT Plots interleaved spikes over raw traces
%   OBJ = PLOT(OBJ,N) plots a spike train for each cluster above the 
%   raw data for trial N. The raw data is assumed to be in the current 
%   directory. If the means and the thresholds used for the extraction 
%   are stored in the ISPIKES object, they are also plotted.
%
%    Dependencies: nptReadStreamerFile.

% get color order list. gcf will use current figure if there is one 
% or create one if there are no figures currently
Args = struct('showTitle',0,'showStreamer',0,'showISpikes',1,'chunkSize',[], ...
    'GroupPlots',0,'GroupPlotIndex',0,'Color','b','xLimits',[],'linkedZoom',0, ...
    'NoNumChunks',0,'Fast',0,'showLfp',0,'TickDir','in');
Args = getOptArgs(varargin,Args,'flags',{'showTitle','showStreamer','linkedZoom', ...
        'NoNumChunks','Fast','showLfp'});

if(~isempty(Args.NumericArguments))
    % get numeric argument
    n = Args.NumericArguments{1};
else
    % set default numeric argument
    n = 1;
end

if isempty(Args.chunkSize)
    chunkSize = vi.data.chunkSize * 1000;
else
    chunkSize = Args.chunkSize * 1000;
end
if chunkSize
    trial=1;
else
    trial=n;
end

clist = nptDefaultColors(1:100);
clistsize = size(clist,1);
cla;  reset(gca)


channel = vi.data.signal;
numTrials = vi.data.numTrials;
numClusters = vi.data.numClusters;
sessionname = vi.data.sessionname;
groupname = vi.data.groupname;
duration = vi.data.duration;

if(Args.Fast)
    stem(vi.data.trial.cluster.spikes)
elseif ~Args.showStreamer
    if(vi.data.numChunks && (~Args.NoNumChunks))
        for cluster = 1:numClusters
            %draw a line
            lineY = cluster - .51;
            lineY2 = cluster + .5;
            line([chunkSize*(n-1) chunkSize*n],[lineY lineY],'Color',Args.Color);
            if (vi.data.trial(trial).cluster(cluster).spikecount > 0)
                %draw the spikes
                spiketime = vi.data.trial(trial).cluster(cluster).spikes;%change from micro to milliseconds
                [y,ind] = find(spiketime>chunkSize*(n-1) & spiketime<chunkSize*n);
                for spikenum = ind
                    line([spiketime(spikenum) spiketime(spikenum)],[lineY lineY2],'Color',Args.Color);
                end
            end
        end
        xlim([chunkSize*(n-1) chunkSize*n])
    else
        durationms = duration * 1000;
        for cluster = 1:numClusters
            %draw a line
            lineY = cluster - .51;
            lineY2 = cluster + .5;
            line([0 durationms],[lineY lineY],'Color',Args.Color);
            spikecount = vi.data.trial(trial).cluster(cluster).spikecount;
            if spikecount > 0
                %draw the spikes
                spiketime = vi.data.trial(trial).cluster(cluster).spikes;
                for spikenum=1:spikecount
                    line([spiketime(spikenum) spiketime(spikenum)],[lineY lineY2],'Color',Args.Color);
                end
            end
        end

        %xlim([0 duration*1000])
        set(gca,'YTick',[]);
    end
    
    
    
    %Show Streamer
else
    % check to see if spike data contains means and thresholds
    if ~isempty(vi.data.means)
        plotmeans = 1;
    else
        plotmeans = 0;
    end
    
    %instantiate streamer object
    if sum([vi.data.numChunks vi.data.chunkSize])
       st = streamer(vi.data.sessionname,vi.data.signal,vi.data.numTrials,[vi.data.numChunks vi.data.chunkSize]);    
    else
        if Args.showLfp %means that ispikes must have been derived from the highpass files.
            sessionname = strrep(vi.data.sessionname,'highpass','lfp');
            st = streamer(sessionname,vi.data.signal,vi.data.numTrials); 
            plotmeans=0;
        else
            st = streamer(vi.data.sessionname,vi.data.signal,vi.data.numTrials); 
        end
    end

    plot(st,n,varargin{:});
    %axis auto
    hold on
    ax = axis;
    
    if plotmeans==1
        % plot mean
        tmean = vi.data.means(:,trial);
        tthreshold = vi.data.thresholds(:,trial);
        minus = tmean - tthreshold;
        clist = get(gca,'ColorOrder');
        clistsize = size(clist,1);
        for ii=1:size(tmean,1)
            line([ax(1) ax(2)],[tmean(ii) tmean(ii)],'Color',clist(mod(ii-1,clistsize)+1,:));
            line([ax(1) ax(2)],[minus(ii) minus(ii)],'Color',clist(mod(ii-1,clistsize)+1,:));
        end
    end
    ax = axis;
    cplotheight = (ax(4) - ax(3)) * 0.1;
    
    if Args.showISpikes
        if vi.data.numChunks
            for cluster = 1:numClusters
                %draw a line
                lineY = ax(4)+(cluster-1)*cplotheight;
                lineY2 = lineY + cplotheight;
                line([chunkSize*(n-1) chunkSize*n],[lineY lineY],'Color',Args.Color);
                if (vi.data.trial(trial).cluster(cluster).spikecount > 0)
                    %draw the spikes
                    spiketime = vi.data.trial(trial).cluster(cluster).spikes;%change from micro to milliseconds
                    [y,ind]=find(spiketime>chunkSize*(n-1) & spiketime<chunkSize*n);
                    for spikenum=ind
                        line([spiketime(spikenum) spiketime(spikenum)],[lineY lineY2],'Color',Args.Color);
                    end
                end
            end
        else
            for cluster = 1:numClusters
                %draw a line
                lineY = ax(4)+(cluster-1)*cplotheight;
                line(ax(1:2),[lineY lineY],'Color',Args.Color);
                lineY2 = lineY + cplotheight;
                spikecount = vi.data.trial(trial).cluster(cluster).spikecount;
                if spikecount > 0
                    %draw the spikes
                    spiketime = vi.data.trial(trial).cluster(cluster).spikes;
                    for spikenum=1:spikecount
                        line([spiketime(spikenum) spiketime(spikenum)],[lineY lineY2],'Color',Args.Color);
                    end
                end
            end
        end
    end
end

if(Args.GroupPlots>1)
    set(gca,'YTick',[]);
    if(Args.GroupPlotIndex>1)
        set(gca,'XTick',[]);
    end
end

set(gca,'TickDir',Args.TickDir)

varargout{1} = {'Args',Args,'handle',gca};
