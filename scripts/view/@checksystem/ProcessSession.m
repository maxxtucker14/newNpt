function robj = ProcessSession(obj,varargin)
%CHECKSYSTEM/ProcessSession	Process session data.
%   ROBJ = ProcessSession(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ.
%   It does the following:
%      a) Checks the local directory for the presence of a file named
%   checksystem.mat. 
%      b) If it is present, it returns a checksystem object with the 
%   current directory.
%      c) If it is not present, it creates a checksystem object, which
%   calls the nptCheckExpsystem function, and then returns a checksystem
%   object with the current directory.
%      d) ProcessSession(OBJ,'redo') will execute c) even if the file 
%   checksystem.mat is present.
%
%	Dependencies: removeargs, nptDir, ispresent, nptdata. 

redo = 0;

if ~isempty(varargin) 
    % subtract 1 since nargin includes the first argument which is the object
	num_args = nargin - 1;
	i = 1;
	while(i <= num_args)
		if ischar(varargin{i})
			switch varargin{i}
			case('redo')
				redo = 1;
			end
		end
		i = i + 1;
	end
end
	
% check for skip.txt
if (~checkMarkers(obj,redo,'session'))
	if (ispresent('checksystem.mat','file') & (redo == 0))
		d.sessions = 1;
		d.path{1} = pwd;
		n = nptdata(1,1);
		robj = class(d,'checksystem',n);
	else
		% try to create object
		robj = checksystem('auto',varargin{:});
	end
else	
	% skip this session so return empty object
	robj = checksystem;
end % if marker file exists
