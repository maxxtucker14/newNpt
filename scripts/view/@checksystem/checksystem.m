function obj = checksystem(varargin)
%CHECKSYSTEM Constructor function for CHECKSYSTEM object
%   OBJ = CHECKSYSTEM('auto') attemps to instantiate a CHECKSYSTEM 
%   object in the current directory. It looks for *.INI files and 
%   uses the session name from the INI file to run nptCheckExpSystem. 
%   The results are saved in checksystem.mat and the current directory
%   path is returned in the CHECKSYSTEM object. Optional arguments
%   for nptCheckExpSystem may be passed to this constructor after
%   the first argument, e.g. checksystem('auto',1:140,4:5).
%
%   OBJ = CHECKSYSTEM(SESSION_NAME) uses SESSION_NAME to create the
%   CHECKSYSTEM object. e.g. checksystem('clark08240201');
%
%   OBJ = CHECKSYSTEM instantiates an empty CHECKSYSTEM object.
%
%   OBJ contains the following fields:
%      OBJ.sessions - number of sessions contained in this object
%      OBJ.path() - paths of sessions in this object.
%
%   Dependencies: nptDir, removeargs, nptFileParts, nptCheckExpSystem
%   nptdata.

if nargin==0
	obj = CreateEmptyCheckSystem;
elseif ((nargin==1) & (isa(varargin{1},'checksystem')))
	obj = varargin{1};
else
	% default values for optional arguments
	auto = 0;
	redo = 0;
	saveobj = 0;
	
	% look for optional arguments
	num_args = nargin;
	i = 1;
	while(i <= num_args)
		if ischar(varargin{i})
			switch varargin{i}
			case('auto')
				auto = 1;
				% remove argument from varargin
				[varargin,num_args] = removeargs(varargin,i,1);
			case('redo')
				redo = 1;
				% remove this argument since it only applies to this class
				[varargin,num_args] = removeargs(varargin,i,1);
			case('save')
				saveobj = 1;
				% remove this argument since it only applies to this class
				[varargin,num_args] = removeargs(varargin,i,1);
			case('redolevels')
				% read the levels argument
				levels = varargin{i+1};
				if (levels==1)
					redo = 1;
					% remove arguments since this is the final level
					[varargin,num_args] = removeargs(varargin,i,2);
				elseif (levels>0)
					redo = 1;
					varargin{i+1} = levels - 1;
					i = i + 2;
				else
					% shouldn't have this but just in case
					% remove arguments
					[varargin,num_args] = removeargs(varargin,i,2);
				end
			case('savelevels')
				% read the levels argument
				levels = varargin{i+1};
				if (levels==1)
					saveobj = 1;
					% remove arguments since this is the final level
					[varargin,num_args] = removeargs(varargin,i,2);
				elseif (levels>0)
					saveobj = 1;
					varargin{i+1} = levels - 1;
					i = i + 2;
				else
					% shouldn't have this but just in case
					% remove arguments
					[varargin,num_args] = removeargs(varargin,i,2);
				end
			otherwise
				i = i + 1;
			end
		else
			i = i + 1;
		end
	end
	
	if auto
		% check current directory for data files
		a = nptDir('*.0001');
		if (isempty(a))
			% if no data files, create empty object
			obj = CreateEmptyCheckSystem;
		else
			% use session name to run nptCheckExpSystem
			[path,name,suffix] = nptFileParts(a.name);
			obj = CreateCheckSystem(name,varargin{:});
		end
	else
		% assume first argument is session name, and all subsequent 
		% arguments are supposed to be passed to nptCheckExpSystem
		obj = CreateCheckSystem(varargin{1},varargin{2:end});
	end
end

%---------------------------------------
function c = CreateEmptyCheckSystem

d.sessions = 0;
d.path = {};		
n = nptdata(0,1);
c = class(d,'checksystem',n);

%---------------------------------------
function c = CreateCheckSystem(name,varargin)

% run nptCheckExpSystem
[results,dmins,mmins] = nptCheckExpSystem(name,varargin{:});
% save results in checksystem.mat
save checksystem results dmins mmins
d.sessions = 1;
d.path{1} = pwd;
n = nptdata(1,1);
c = class(d,'checksystem',n);
