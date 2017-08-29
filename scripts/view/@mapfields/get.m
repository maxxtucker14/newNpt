function [r,varargout] = get(obj,varargin)
%mapfields/get Get function for MAPFIELDS objects
%   PTS = get(OBJ,'Points') returns the coordinates of all fields in
%   the form [x1,y1,x2,y2,x3,y3,x4,y4].
%
%   PTS = get(OBJ,N,'Points') returns the coordinates of all fields 
%   from the Nth session.
%
%   PTS = get(OBJ,N,'Points','Field',M) returns the M-th field from
%   the N-th session. M is 1-indexed
%
%   PTS = get(OBJ,'Points','Mark',M) returns the coordinates of only
%   the fields marked with M. M can be either 0, 1, or 2 or some 
%   combintation of the above. The fixation field, which usually has a
%   mark of 0, is excluded.
%
%   PTS = get(OBJ,'Points','Marked') returns the coordinates of the
%   fields with marks not equal to 0.
%
%   PTS = get(OBJ,'Points','Fix') returns the coordinates of the
%   fixation spot.
%
%   CENTERXY = get(OBJ,'CenterXY') returns the coordinates of the center
%   of all fields. The same optional input arguments as above are 
%   valid.
%
%   [CENTERX,CENTERY] = get(OBJ,'CenterXY') returns the center 
%   coordinates separately.
%
%   N = get(OBJ,'NumRFs') returns the number of fields.
%
%   INDICES = get(OBJ,N,'Indices') returns the indices for the fields
%   from the n-th session. 
%
%   [FIX,FIXY] = get(OBJ,'FixCenterXY') returns the fixation
%   center coordinates from the same session for each field specified.
%
%   N = get(OBJ,'SessionRFNumber') returns the field numbers from the
%   session for each field specified.
%
%   [XPIXELS,YPIXELS] = get(OBJ,'PixelsPerDegree') returns the pixels
%   per degree for the x and y dimensions.

Args = struct('Points',0,'Mark',[],'Fix',0,'CenterXY',0,'NumRFs',0, ...
	'Field',0,'Indices',0,'Marked',0,'FixCenterXY',0, ...
	'SessionRFNumber',0,'PixelsPerDegree',0,'ScreenWidthDegrees',40, ...
	'ScreenHeightDegrees',30);
Args = getOptArgs(varargin,Args,'flags',{'Fix','Points','CenterXY', ...
	'NumRFs','Indices','Marked','FixCenterXY','SessionRFNumber', ...
	'PixelsPerDegree'});

% set variables to default
r = [];
s = 0;

if(Args.PixelsPerDegree)
	% get conversion factors between pixels and degrees
	xdeg = obj.data.ScreenWidth(1)/Args.ScreenWidthDegrees;
	ydeg = obj.data.ScreenHeight(1)/Args.ScreenHeightDegrees;
	if(nargout==1 | nargout==0)
		r = [xdeg ydeg];
	elseif(nargout==2)
		r = xdeg;
		varargout{1} = ydeg;
	end
	return
end

if(~isempty(Args.NumericArguments))
	if(obj.data.sessions>1)
		% interpret numeric argument as session number
		s = Args.NumericArguments{1};
	elseif(~Args.Field)
		% interpret numeric argument as field number instead of session
		% number if Field argument is empty and there is only 1 session
		Args.Field = Args.NumericArguments{1};
	end
	% restrict fields for further search
	if(s~=0)
		sfFields = (obj.data.numRFIndex(s)+1):obj.data.numRFIndex(s+1);
	else
		sfFields = 1:obj.data.numRFIndex(end);
	end
else
	% make sure we don't encounter an error when an empty object is being 
	% used by ProcessSession to get AnalysisLevel, which will be returned 
	% by nptdata/get.m
	rfi = obj.data.numRFIndex;
	if(~isempty(rfi))
		sfFields = 1:rfi(end);
	else
		sfFields = [];
	end
end

if(~isempty(Args.Mark))
	% find indices with mark
	n1 = [];
	for i = 1:length(Args.Mark)
		n1 = [n1; find(obj.data.mark(sfFields)==Args.Mark(i))];
	end
	% fixation mark is usually 0 but it shouldn't really be included
	nfix = find(obj.data.type(sfFields(n1)));
	n = setdiff(sfFields(n1),nfix);
elseif(Args.Marked)
	% find all fields with mark not equal to 0
	n = sfFields(find(obj.data.mark(sfFields)));
elseif(Args.Fix)
	% find fixation
	n = sfFields(find(obj.data.type(sfFields)));
elseif(Args.Field)
	n = vecc(sfFields(Args.Field));
else
	% return everything
	n = sfFields(:);
end

if(Args.Points)
	r = obj.data.pts(n,:);
elseif(Args.CenterXY)
	cx = obj.data.centerx(n);
	cy = obj.data.centery(n);				
	if(nargout==1 | nargout==0)
		r = [cx cy];
	elseif(nargout==2)
		r = cx;
		varargout{1} = cy;
	end
elseif(Args.NumRFs)
    r = length(n);
elseif(Args.Indices)
	r = n;
elseif(Args.FixCenterXY)
    % preallocate memory so we don't change variable size inside the 
    % loop
	cx = zeros(size(n));
	cy = cx;
	for i = 1:length(n)
		% find first index in numRFIndex which is greater than n(i)
		si = find(obj.data.numRFIndex>=n(i));
		si = si(1);
        % get the number of the last field that is not in the same 
        % session
        silast = obj.data.numRFIndex(si-1);
		% find fixation in the fields that were in the same session
		sifix = find(obj.data.type((silast+1):obj.data.numRFIndex(si)));
        % get overall index
        sifix2 = silast + sifix;
		% get the centerx and centery for that field
		cx(i) = obj.data.centerx(sifix2);
		cy(i) = obj.data.centery(sifix2);
	end
	if(nargout==1 | nargout==0)
		r = [cx cy];
	elseif(nargout==2)
		r = cx;
		varargout{1} = cy;
	end
elseif(Args.SessionRFNumber)
    % preallocate memory so we don't change variable size inside the 
    % loop
	rn = zeros(size(n));
	for i = 1:length(n)
		% find first index in numRFIndex which is greater than n(i)
		si = find(obj.data.numRFIndex>=n(i));
		si = si(1);
        % get the number of the last field that is not in the same 
        % session
        silast = obj.data.numRFIndex(si-1);
        rn(i) = n(i) - silast;
	end
	r = rn;
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
