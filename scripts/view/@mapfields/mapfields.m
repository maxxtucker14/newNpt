function obj = mapfields(varargin)
%@mapfields/mapfields Constructor function for MAPFIELDS class
%   OBJ = mapfields('auto') attempts to instantiate a MAPFIELDS
%   object by looking in the current directory for the INI file
%   to obtain receptive field information.
%
%   OBJ = mapfields(INI_FILENAME) instantiates a MAPFIELDS object
%   using INI_FILENAME.
%      e.g. obj = mapfields('clark08130304.ini');

% default values for optional arguments
Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0);
[Args,varargin] = getOptArgs(varargin,Args,'flags',{'Auto'}, ...
			'subtract',{'RedoLevels','SaveLevels'}, ...
			'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}});

if(nargin==0)
	% create empty object
	obj = createEmptyObject;
elseif( (nargin==1) & isa(varargin{1},'mapfields') )
	obj = varargin{1};
else
	% create object using arguments
	if(Args.Auto)
		% check for saved object
		if(ispresent('mapfields.mat','file','CaseInsensitive') & (Args.RedoLevels==0))
			fprintf('Loading saved mapfields object...\n');
			l = load('mapfields.mat');
			obj = l.mf;
		else
			% no saved object so we will try to create one
			% look for INI file
			ifile = nptDir('*.ini','CaseInsensitive');
			obj = createObject(ifile,Args.SaveLevels);
		end
	else
		switch(nargin)
		case 1
			v1 = varargin{1};
			if(ischar(v1))
				% if is character, try using it as the INI file
				ifile = nptDir(v1,'CaseInsensitive');
				obj = createObject(ifile,Args.SaveLevels);
			else
				error('Argument should be filename of INI file!')
			end
		otherwise
			error('Wrong number of input arguments!')
		end
	end
end

function obj = createObject(ifile,saveobj)

% get size of ifile
sifile = size(ifile,1);
if(sifile>1)
	fprintf('Warning: More than 1 INI file found. Using first one found...\n');
end
if(sifile>0)
	data = ReadIniRF(ifile(1).name);
	% convert session name to cell array so multiple sessions can be 
	% stored more easily
	data.sessionname = {data.sessionname};
	% do the same for presenter version, date and time
	data.PresenterVersion = {data.PresenterVersion};
	data.Date = {data.Date};
	data.Time = {data.Time};
	% get number of RFs
	nRFs = data.numRFs;
	% set number of sessions to 1
	data.sessions = 1;
	% set numRFIndex so we can add objects together
	data.numRFIndex = [0; nRFs];
	n = nptdata(1,0,pwd);
	d.data = data;
	obj = class(d,'mapfields',n);
	if(saveobj)
		fprintf('Saving mapfields object...\n');
		mf = obj;
		save mapfields mf
	end
else
	% create empty object
	obj = createEmptyObject;
end

function obj = createEmptyObject

data.sessionname = '';
data.numRFs = 0;
data.numRFIndex = [];
n = nptdata(0,0);
d.data = data;
obj = class(d,'mapfields',n);
