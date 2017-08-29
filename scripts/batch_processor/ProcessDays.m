function ProcessDays(varargin)
%ProcessDays	Process an animal's data.
%	ProcessDays looks in the current directory for subdirectories
%   and calls ProcessDay after changing directory to each subdirectory
%   found.
%
%   ProcessDays('days',{'062101','062202',}) calls ProcessDay only in
%   the subdirectories specified in the cell array following the 
%   'days' argument.
%   
%   ProcessDays(ARG1,ARG2,...) parses the argument list, and removes 
%   the 'days' argument if it is present, as well as the associated
%   cell array, and passes the rest to ProcessDay. 
%	   e.g. ProcessDays('extraction','days',{'062101','062202',}) 
%   will call ProcessDay('extraction').
%
%	Dependencies: nptDir, ProcessDay.

selecteddays = 0;
dlist = {};

if ~isempty(varargin)
	num_args = nargin;
	i = 1;
	while(i <= num_args)
		if(ischar(varargin{i}))
			switch varargin{i}
			case('days')
				selecteddays = 1;
				dlist = varargin{i+1};
				[varargin,num_args] = removeargs(varargin,i,2);
				i = i - 1;
			end
		end
		i = i + 1;
	end
end

dirlist=nptDir;
for i=1:size(dirlist,1)		%loop over days
	if dirlist(i).isdir
		if ~((selecteddays == 1) & (sum(strcmp(dirlist(i).name,dlist))==0))
			fprintf(['Processing Day ' dirlist(i).name '\n']);
			cd (dirlist(i).name)
			ProcessDay(varargin{:});
			cd ..
		end
	end
end
