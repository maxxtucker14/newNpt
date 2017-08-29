function [r,varargout] = get(obj,varargin)
%eyejitter/get Get function for EYEJITTER objects
%   [TRIALN,MEANXY] = get(OBJ,'StableTrials','MaxSD',SD) returns 
%   the trial numbers and the mean x-, y- position for trials with 
%   standard deviations below SD (default is 0.35).
%
%   [TRIALN,MEANX,MEANY] = get(OBJ,'StableTrials','MaxSD',THRESH)
%   returns the X and Y mean positions separately.
%
%   CENTERXY = get(OBJ,'CenterXY') returns the XY coordinates to
%   correspond to the center of the jitter in eye position. The default
%   method weighs each position by the 4th power of the number of
%   occurences but an alternative method can be used by specifying the 
%   'Centroid' argument.
%
%   [CENTERX,CENTERY] = get(OBJ,'CenterXY') returns the X and Y 
%   coordinates separately.

Args = struct('StableTrials',0,'MaxSD',0.35,'CenterXY',0);
Args = getOptArgs(varargin,Args,'flags',{'StableTrials','CenterXY'});

if(Args.StableTrials)
	r = find(obj.data.stdev<Args.MaxSD);
	% get the means
	m = obj.data.mean(r,:);
	if(nargout==2)
		% switch the columns so it is XY instead of YX
		varargout{1} = m(:,[obj.data.hchan obj.data.vchan]);
	elseif(nargout==3)
		varargout{1} = m(:,obj.data.hchan);
		varargout{2} = m(:,obj.data.vchan);
	end
elseif(Args.CenterXY)
	[n,x,nbins,xcenter,ycenter] = hist(obj,varargin{:});
	r = [xcenter ycenter];
	if(nargout==3)
		varargout{1} = xcenter;
		varargout{2} = ycenter;
	end
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.eyes,varargin{:});
end
