function r = get(s,varargin)
%ISPIKES/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object 
%   property. PROP_NAME can be one of the following:
%      'SessionName' - name of session.
%      'Channel' - signal number inside streamer file.
%      'Duration'
%      'MinDuration'
%      'TotalClusters'
%      'MeansPresent'
%      'TrialMean','Trial',t
%      'TrialThreshold','Trial',t
%      'TrialClusterSpikeCount','Trial',t,'Cluster',c
%      'TrialClusterSpikeTime','Trial',t,'Cluster',c,'Spike',s
%
%   Dependencies: None.

Args = struct('SessionName',0,'GroupName',0,'Duration',0,'Channel',0, ...
    'MinDuration',0,'TotalClusters',0,'MeansPresent',0,'TrialMean',0, ...
    'TrialThreshold',0,'TrialClusterSpikeCount',0,'TrialClusterSpikeTime',0, ...
    'GroupPlotProperties',0,'Trial',0,'Cluster',0,'Spike',0,'chunkSize',0);
Args = getOptArgs(varargin,Args,'flags',{'SessionName','GroupName', ...
        'Duration''Channel','MinDuration','TotalClusters','MeansPresent', ...
        'TrialMean','TrialThreshold','TrialClusterSpikeCount', ...
        'TrialClusterSpikeTime'});

if(Args.SessionName)
   r = s.data.sessionname;
elseif(Args.GroupName)
    r = s.data.groupname;
elseif(Args.Duration)
    r = s.data.duration;
elseif(Args.Channel)
    r = s.data.signal;
elseif(Args.MinDuration)
    r = s.data.min_duration;
elseif(Args.TotalClusters)
    r = s.data.numClusters;
elseif(Args.MeansPresent)
    if ~isempty(s.data.means)
        r = 1;
    else
        r = 0;
    end
elseif(Args.TrialMean)
    r = s.data.means(Args.Trial);
elseif(Args.TrialThreshold)
    r = s.data.thresholds(Args.Trial);
elseif(Args.TrialClusterSpikeCount)
    r = s.data.trial(Args.Trial).cluster(Args.Cluster).spikecount;		
elseif(Args.TrialClusterSpikeTime)
    r = s.data.trial(Args.Trial).cluster(Args.Cluster).spikes(Args.Spike);		
elseif(Args.GroupPlotProperties>0)
    if(Args.GroupPlotProperties>1)
        r.separate = 'Vertical';
    else
        r.separate = 'No';
    end
elseif(Args.chunkSize)
    r=getChunkInfo(s.data.sessionname,Args.chunkSize);
else
    r = get(s.nptdata,varargin{:});
end
