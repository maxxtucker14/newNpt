function edata = eyes(varargin)
%EYES Constructor function for the EYES class
%   E = EYES(SESSIONNAME) instantiates an EYES object
%   using the data file SESSIONNAME_eye.0001.  Both eye channels are plotted.
%   This function automatically cds to the eye directory and 
%   performs a directory listing to determine the 
%   number of trials in the session.  The data is plotted by default in 'degrees' but 
%   can be plotted in 'pixels' also.
%
%   E = EYES(SESSIONNAME,CHANNEL) instantiates a EYE object
%   using the signal specified by CHANNEL in the data file SESSIONNAME_eye.0001
%   
%   E = EYES(SESSIONNAME,CHANNEL,UNITS) instantiates a EYE object
%   using the signal specified by CHANNEL in the data file SESSIONNAME_eye.0001
%   
%   E = EYES(SESSIONNAME,CHANNEL,UNITS,NUMBER_TRIALS) also instantiates a 
%   EYE object but it takes the number of trials as an argument
%   instead of performing a directory listing. 
%
%   E = EYES('auto',VARARGIN) attempts to instantiate an EYE object by 
%   looking for files with the '_eye.0*' pattern. If the sub-directory 
%   EYE exits, this function changes directory before continuing. The 
%   following optional input arguments are valid:
%      'channels' - followed by number or array specifying the channels
%                   to be used (default: [1 2]).
%      'pixels' - flag indicating that the units should be pixels instead
%                 of degrees, which is the default.
%
%   The object contains the following fields:
%      EDATA.sessionname
%      EDATA.channel
%      EDATA.units
%      EDATA.numTrials
%      EDATA.holdaxis
%
%   Dependencies: nptdata.

% property of nptdata
holdAxis = 1;

% set default arguments
Args = struct('auto',0,'pixels',0,'channels',[1 2]);
Args = getOptArgs(varargin,Args,'flags',{'auto','pixels'});

[p,cdir] = getDataDirs('eye','CDNow');

if(nargin==0)
	edata = CreateEmptyEyesObject;
elseif( (nargin==1) & (isa(varargin{1},'eyes')) )
	edata = varargin{1};
else
	if(Args.auto)
		% if there is an eye subdirectory, we are probably in the session dir
		% so change to the eye subdirectory
		filelist = nptDir('*_eye.0*','CaseInsensitive');
     		if(~isempty(filelist))
			% get session name from first filename
			fname = filelist(1).name;
			k = strfind(lower(fname),'_eye.0');
			e.sessionname = fname(1:(k-1));
			e.channel = Args.channels;
			if(Args.pixels)
				e.units = 'pixels';
			else
				e.units = 'degrees';
			end
			numTrials = size(filelist,1);
			n = nptdata(numTrials,holdAxis,p);
			edata = class(e,'eyes',n);
		else
			% no files here so just return empty object
			edata = CreateEmptyEyesObject;
		end
		
	else % if(Args.auto)
		switch(nargin)
		case 1
			e.sessionname = varargin{1};
			e.channel = [1 2];
			e.units = 'degrees';
			% get list of files
			filelist = nptDir([e.sessionname '_eye.0*']);
           	numTrials = size(filelist,1);
			n = nptdata(numTrials,holdAxis,p);
			edata = class(e,'eyes',n);
		case 2
			e.sessionname = varargin{1};
			e.channel = varargin{2};
			e.units = 'degrees';
			% get list of files
            filelist = nptDir([e.sessionname '_eye.0*']);
			numTrials = size(filelist,1);
			n = nptdata(numTrials,holdAxis,p);
			edata = class(e,'eyes',n);
		case 3
			e.sessionname = varargin{1};
			e.channel = varargin{2};
			e.units = varargin{3};
			filelist = nptDir([e.sessionname '_eye.0*']);
			numTrials = size(filelist,1);
			n = nptdata(numTrials,holdAxis,p);
			edata = class(e,'eyes',n);
		case 4
			e.sessionname = varargin{1};
			e.channel = varargin{2};
			e.units = varargin{3};
			numTrials = varargin{4};
			n = nptdata(numTrials,holdAxis,p);
			edata = class(e,'eyes',n);
		
		otherwise
		   error('Wrong number of input arguments')
		end % switch(nargin)
	end % if(Args.auto)
end % if(nargin==0)

if(~isempty(cdir))
    cd(cdir)
end


function obj = CreateEmptyEyesObject

e.sessionname = '';
e.channel = [1 2];
e.units ='';
n = nptdata(0,1);
obj = class(e,'eyes',n);
