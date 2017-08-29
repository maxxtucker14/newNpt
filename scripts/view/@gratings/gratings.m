function obj = gratings(varargin)
%gratings/gratings Constructor function for GRATINGS class
%   OBJ = gratings('auto') attempts to instantiate an object of the 
%   GRATINGS class.

% default value for optional arguments
Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0);
[Args,varargin] = getOptArgs(varargin,Args,'flags',{'Auto'}, ...
			'subtract',{'RedoLevels','SaveLevels'}, ...
			'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}});

if(nargin==0)
	% create empty object
	obj = createEmptyObject;
elseif( (nargin==1) & isa(varargin{1},'gratings') )
	obj = vararing{1};
else
	% create object using arguments
	if(Args.Auto)
		% check for saved object
		if(ispresent('gratings.mat','file','CaseInsensitive') & (Args.RedoLevels==0))
			fprintf('Loading saved gratings object...\n');
			l = load('gratings.mat');
			obj = l.gr;
		else
			% no saved object so we will try to create one
			% look for _stimuli.bin file
			ifile = nptDir('*.ini','CaseInsensitive');
			obj = createObject(ifile,Args);
		end
	else
		switch(nargin)
		case 1
			v1 = varargin{1};
			if(ischar(v1))
				% if is character, try using it as the INI file
				ifile = nptDir(v1,'CaseInsensitive');
				obj = createObject(ifile,Args);
			else
				error('Argument should be name of INI file!')
			end
		otherwise
			error('Wrong number of input arguments!')
		end
	end
end

function obj = createObject(ifile,Args)

% get size of ifile
sifile = size(ifile,1);
if(sifile>1)
	fprintf('Warning: More than 1 INI file found. Using first one found...\n');
end
if(sifile>0)
	% read ini file. status should be 0 if everything went okay
	[r,status] = ReadIniGrating(ifile(1).name);
	if(status)
		% there was a problem so return empty object
		obj = createEmptyObject;
	else
		% inherit from mapfields object so we can draw fields in plot function
		mf = mapfields('auto');
		% set number of stimuli in nptdata of mapfields instead of numRFs
		mf = set(mf,'Number',1);	
		d.data = r;
		obj = class(d,'gratings',mf);
		if(Args.SaveLevels)
			fprintf('Saving gratings object...\n');
			gr = obj;
			save gratings gr
		end
	end
else
	% create empty object
	obj = createEmptyObject;
end

function obj = createEmptyObject

data.sessionname = '';
% create empty mapfields object
mf = mapfields;
d.data = data;
obj = class(d,'gratings',mf);
