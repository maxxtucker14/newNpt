function obj = eyejitter(varargin)
%eyejitter Contructor function for EYEJITTER object
%   OBJ = eyejitter(EYES) instantiates an EYEJITTER object using a
%   EYES object. The EYEJITTER object contains the mean eye position
%   and the standard deviation of the cartesian distances from the
%   mean for all trials. By default, data from the entire trial is
%   included in the analysis.
%
%   OBJ = eyejitter('auto') attempts to instantiate an EYEJITTER
%   object by first attempting to create an EYE object.
%
%   The optional input arguments are:
%      ONsets - followed by number specifying the start of the analysis
%               in ms (default: 1). Can also be followed by the string
%               'PresenterTrigger', which means that the onsets will be
%               obtained from the presTrigOnsetsMS variable stored in 
%               timing.mat file created by ProcessSession. 
%      OFFsets - followed by number specifying the start of the analysis
%                in ms (default: end).
%      Duration - followed by number specifying the duration of the
%                 window following the onset.
%      RedoLevels  followed by number argument specifying levels.This 
%                  creates an EYEJITTER object if levels is greater than
%                  0 even if there is a eyejitter.mat file present. 
%                  Levels is subtracted by 1 and passed on to all parent 
%                  objects.
%
%      redo        essentially the same as ('redolevels',1).
%
%      SaveLevels  followed by number argument specifying levels. This 
%                  saves the EYEJITTER object in the file eyejitter.mat
%                  with variable name 'bi' if levels is greater than
%                  0. Levels is subtracted by 1 and passed on to all 
%                  parent objects.
%
%      save        essentially the same as ('savelevels',1).
%
%   The object contains the following fields:
%      OBJ.data.onsets()
%      OBJ.data.offsets()
%      OBJ.data.mean() - with y in the first column and x in the second.
%      OBJ.data.stdev()
%      OBJ.data.hchan
%      OBJ.data.vchan
%      OBJ.data.onsetArg
%
%   obj = eyejitter('auto');
%   obj = eyejitter(eyes);

% default values for optional arguments
Args = struct('ONsets',[],'OFFsets',[],'RedoLevels',0,'SaveLevels',0, ...
			'Auto',0,'Duration',[],'HChan',2,'VChan',1);
[Args,varargin] = getOptArgs(varargin,Args,'flags',{'Auto'}, ...
			'shortcuts',{'redo',{'RedoLevels',1};'save',{'SaveLevels',1}}, ...
			'subtract',{'RedoLevels','SaveLevels'});

% initialize data structure
data.datastart = Args.ONsets;
data.dataend = Args.OFFsets;
data.mean = [];
data.stdev = [];
data.hchan = Args.HChan;
data.vchan = Args.VChan;
data.onsetArg = '';

% set default variables
changedDir = 0;

if(nargin==0)
	% create empty object
	e = eyes;
	d.data = data;
	obj = class(d,'eyejitter',e);
elseif( (nargin==1) & (isa(varargin{1},'eyejitter')) )
	obj = varargin{1};
else
	% create object using arguments
	if(Args.Auto)
		% if there is an eye subdirectory, we are probably in the session dir
		% so change to the eye subdirectory
		[r,a] = ispresent('eye','dir','CaseInsensitive');
		if r
			cd(a);
			changedDir = 1;
		end
		% check for saved object
		if(ispresent('eyejitter.mat','file','CaseInsensitive') & (Args.RedoLevels==0))
			fprintf('Loading saved eyejitter object...\n');
			l = load('eyejitter.mat');
			obj = l.ej;
		else
			% no saved object so we will try to create one
			% try to create eyes object
			e = eyes('auto','pixels');
			obj = EyesToEyeJitter(data,e,Args);
		end % if(ispresent('eyejitter.mat',...
		% change directory back to orignial if necessary
		if changedDir
			cd ..
		end
	else % if(Args.Auto)
		switch(nargin)
		case 1
			if(isa(varargin{1},'eyes'))
				e = varargin{1};
				% if there is an eye subdirectory, we are probably in the session dir
				% so change to the eye subdirectory
				[r,a] = ispresent('eye','dir','CaseInsensitive');
				if r
					cd(a);
					changedDir = 1;
				end
				obj = EyesToEyeJitter(data,e,Args);
				% change directory back to orignial if necessary
				if changedDir
					cd ..
				end
			end
		otherwise
			error('Wrong number of input arguments!')
		end
	end
end

function obj = EyesToEyeJitter(data,e,Args)
%@eyejitter/EyesToEyeJitter(DATA,EYES,Args)

% set default variabels
nooffsets = 0;

if(~isempty(e))
	% get number of trials
	n = e.numTrials;

	% check if ONsets is 'PresenterTrigger'
	if(ischar(Args.ONsets) && strcmp(Args.ONsets,'PresenterTrigger'))
		% load timing.mat file created by ProcessSession
		a = load(['..' filesep e.sessionname 'timing.mat']);
		% check if presTrigOnsetsMS is present
		if(isfield(a,'presTrigOnsetsMS'))
			data.datastart = round(a.presTrigOnsetsMS);
		else
			% calculate presTrigOnsetsMS based on sampling rate
			% check if there is a .0001 file present
			datafile = nptDir(['..' filesep '*.0001']);
			if(~isempty(datafile))
				[data,nc,sr] = nptReadStreamerFile(['..' filesep datafile(1).name]);
			else
				fprintf('Warning: Could not find *.0001 file!\n');
				fprintf('Warning: Using 30000 as sampling rate.\n');
				sr = 30000;
			end
			srms = sr/1000;
			% subtract 1 since presTrigOnsets is in datapoints and the
			% first datapoint is 0 ms
			data.datastart = round((a.presTrigOnsets-1)/srms);
		end
		data.onsetArg = Args.ONsets;
	end
	
	% check if duration is specified
	if(~isempty(Args.Duration))
		data.dataend = data.datastart + Args.Duration;
	end
	
	% get size of datastart and dataend
	dss = length(data.datastart);
	des = length(data.dataend);
	% make sure we have the right number of onsets if onsets are specified
	if(dss~=0)
		if(dss~=n)
			error('Warning: Size of onsets have to equal number of EYE files!');
		end
	else
		% no onsets specified so set all onsets to 1
		data.datastart = ones(n,1);
	end
	% make sure we have the right number of offsets if offsets are specified
	if(des~=0)
		if(des~=n)
			error('Warning: Size of offsets have to equal number of EYE files!');
		end
	else
		% no offsets specified so set flag to set offsets
		nooffsets = 1;
	end
	% initialize mean and stdev arrays
	data.mean = zeros(n,2);
	data.stdev = zeros(n,1);
	% add 1 to datastart and dataend to go from time to index
	data.datastart = data.datastart + 1;
	% this will do nothing if dataend is empty, which is fine since it
	% will be filled later inside the loop
	data.dataend = data.dataend + 1;
	% loop over all trials
	for i = 1:n
		% get data
		[edata,points] = get(e,'DataPixels',i);
		% set offset if it is not specified
		if(nooffsets)
			data.dataend(i) = points;
		end
		[data.mean(i,1:2),data.stdev(i)] = getPositionMeanStd(edata(:, ...
			data.datastart(i):data.dataend(i))');
	end
	d.data = data;
	% set HoldAxis in e object to 0
	e = set(e,'HoldAxis',0);
	obj = class(d,'eyejitter',e);
	if(Args.SaveLevels)
		fprintf('Saving eyejitter object...\n');
		ej = obj;
		save eyejitter ej
	end
else
	% create empty object
	e = eyes;
	d.data = data;
	obj = class(d,'eyejitter',e);
end
