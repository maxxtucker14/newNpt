function r = getSpikeCounts(obj,varargin)
%@ispikes/getSpikeCounts Return spike counts from each trial
%   R = getSpikeCounts(OBJ,VARARGIN)
%      DataStart - specifies start time for each trial in ms 
%                  (default: 1). If only 1 value is specified, that
%                  value is used for all trials.
%
%      DataEnd - specifies end time in ms (default: end). If only 1 
%                values is specified, that value is used for all 
%                trials.
%
%      BinSize - specifies bin size in ms to use to get spike counts
%                (default: DataEnd - DataStart).

Args = struct('DataStart',1,'DataEnd',[],'BinSize',[]);
Args = getOptArgs(varargin,Args);

% get number of trials
numTrials = obj.data.numTrials;
% initialize return structure
r = zeros(numTrials,1);

% if DataStart or DataEnd is only 1 value, assume that value is going to
% be used for all trials
if(length(Args.DataStart)==1)
	Args.DataStart = repmat(Args.DataStart,numTrials,1);
end
if(length(Args.DataEnd)==1)
	Args.DataEnd = repmat(Arsg.DataEnd,numTrials,1);
elseif(isempty(Args.DataEnd))
    % allocate memory for DataEnd array
    Args.DataEnd = repmat(NaN,numTrials,1);
end
if(~isempty(Args.BinSize))
	binsize = Args.BinSize;
end

% loop over all trials
for i = 1:numTrials
	% initialize DataEnd to last spike time if it is not set
	if(isnan(Args.DataEnd(i)))
        Args.DataEnd(i) = obj.data.trial(i).cluster(1).spikes(end);
	end
    if(isempty(Args.BinSize))
        binsize = Args.DataEnd(i) - Args.DataStart(i);
    end
	% set up bins for histcie
	bins = Args.DataStart(i):binsize:Args.DataEnd(i);
	% get spike counts in relevant data window
	r(i) = histcie(obj.data.trial(i).cluster(1).spikes,bins,'DropLast');
end
