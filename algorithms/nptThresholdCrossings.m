function crossings = nptThresholdCrossings(data,threshold,varargin)
%nptThresholdCrossings Return points where data crossed threshold
%   CROSSINGS = nptThresholdCrossings(DATA,THRESHOLD) returns the 
%   indices where DATA crossed THRESHOLD. By default, the function
%   returns crossings in both directions and does not distinguish 
%   between them. If the first point is larger/smaller than THRESHOLD
%   it will be included as a threshold crossing. 
%
%   If DATA is a matrix, CROSSINGS will be a 2 column matrix with the
%   row number of the crossing in column 1 and the column number in 
%   column 2. The crossings will also be listed in order of the columns
%   in DATA.
%
%   CROSSINGS = nptThresholdCrossings(...,'ignorefirst') ignores
%   the first point.
%
%   CROSSINGS = nptThresholdCrossings(DATA,THRESHOLD,'rising') 
%   returns only the crossings in the rising phase. 
%
%   CROSSINGS = nptThresholdCrossings(DATA,THRESHOLD,'falling')
%   returns only the crossings in the falling phase.
%
%   CROSSINGS = nptThresholdCrossings(DATA,THRESHOLD,'separate')
%   returns CROSSINGS as a structure with the following fields:
%      CROSSINGS.rising
%      CROSSINGS.falling
%   Note that the optional arguments 'rising', 'falling', and 
%   'separate' are mutually exclusive and the function will only use
%   the last argument specified.
%
%   Dependencies: None.

% initialize variables
rise = 0;
fall = 0;
separate = 0;
both = 1;
compare1st = 1;

num_args = nargin - 2;
i = 1;
while(i <= num_args)
	if ischar(varargin{i})
		switch varargin{i}
		case('rising')
			rise = 1;
			both = 0;
		case('falling')
			fall = 1;
			both = 0;
		case('ignorefirst')
			compare1st = 0;
		case('separate')
			separate = 1;
			both = 0;
		end
	end
	i = i + 1;
end
	
% find points above threshold and take difference to find the transitions
above = data>threshold;
dDiff = diff(above);

% check to see if data is a vector
if isvector(data)
	% check to see if data is a row vector
	rv = isrowvector(data);
	
	if rise | separate | both
		% need to add 1 since diff shifts everything by 1 point
		rcrossings = find(dDiff>0) + 1;
		if (data(1)>threshold & compare1st)
			% can't use veccat here because rcrossings might be just 1 point
			% which means veccat might know know whether to create row or column vectors
			if rv
				rcrossings = [1 rcrossings];
			else
				rcrossings = [1; rcrossings];
			end
		end
	end
	if fall | separate | both
		% need to add 1 since diff shifts everything by 1 point
		fcrossings = find(-dDiff>0) + 1;
		if (data(1)<threshold & compare1st)
			% can't use veccat here because rcrossings might be just 1 point
			% which means veccat might know know whether to create row or column vectors
			if rv
				fcrossings = [1 fcrossings];
			else
				fcrossings = [1; fcrossings];
			end
		end
	end
	
	if rise
		crossings = rcrossings;
	elseif fall
		crossings = fcrossings;
	elseif separate
		crossings.rising = rcrossings;
		crossings.falling = fcrossings;
	elseif both
		if rv
			crossings = sort([rcrossings fcrossings]);
		else
			crossings = sort([rcrossings; fcrossings]);
		end
	end
else
	% data is a matrix, operate on columns
	if rise | separate | both
		[rxr,rxc] = find(dDiff>0);
		if compare1st
			d1 = find(data(1,:)>threshold);
			% need to add 1 to rxr since diff shifts everything by 1 point
			rcrossings = sortrows([(rxr+1) rxc;ones(size(d1)) d1],[2 1]);
		else
			rcrossings = sortrows([(rxr+1) rxc],[2 1]);
		end
	end
	if fall | separate | both
		[fxr,fxc] = find(-dDiff>0);
		if compare1st
			d1 = find(data(1,:)<threshold);
			% need to add 1 to fxr since diff shifts everything by 1 point
			fcrossings = sortrows([(fxr+1) fxc;ones(size(d1)) d1],[2 1]);
		else
			fcrossings = sortrows([(fxr+1) fxc],[2 1]);
		end
	end

	if rise
		crossings = rcrossings;
	elseif fall
		crossings = fcrossings;
	elseif separate
		crossings.rising = rcrossings;
		crossings.falling = fcrossings;
	elseif both
		crossings = sortrows([rcrossings;fcrossings],[2 1]);
	end
end