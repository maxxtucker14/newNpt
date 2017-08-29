function sdata = datafile(varargin)
%DATAFILE Constructor function for the DATAFILE class
%   S = DATAFILE(SESSIONNAME,CHANNEL) instantiates a DATAFILE object
%   using the signal specified by CHANNEL in the data file 
%   SESSIONNAME.0001 (which is assumed to be in the current directory). 
%   This function performs a directory listing in the current directory 
%   to determine the number of trials in the session.
%
%   S = DATAFILE(SESSIONNAME,CHANNEL,NUMBER_TRIALS) also instantiates a 
%   DATAFILE object but it takes the number of trials as an argument
%   instead of performing a directory listing. 
%
%   The object contains the following fields:
%      SDATA.sessionname
%      SDATA.channel
%      SDATA.numTrials
%      SDATA.holdaxis
%
%   Dependencies: nptdata.

% property of nptdata base class
holdAxis = 1;

switch nargin
case 0
	s.sessionname = '';
	s.channel = 1;
    s.numTrials = 0;
    n = nptdata(0,holdAxis);
	sdata = class(s,'datafile',n);
case 1
	if (isa(varargin{1},'datafile'))
		sdata = varargin{1};
	else
		error('Wrong argument type')
	end
case 2
	s.sessionname = varargin{1};
	s.channel = varargin{2};
	% get list of files
	filelist = nptDir([s.sessionname '*.0*']);
	numTrials = size(filelist,1);
    n = nptdata(numTrials,holdAxis);
	sdata = class(s,'datafile',n);
case 3
	s.sessionname = varargin{1};
	s.channel = varargin{2};
	numTrials = varargin{3};
    n = nptdata(numTrials,holdAxis);
	sdata = class(s,'datafile',n);
otherwise
	error('Wrong number of input arguments')
end
