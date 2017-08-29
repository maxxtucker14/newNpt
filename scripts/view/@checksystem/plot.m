function obj = plot(obj,n,varargin)
%CHECKSYSTEM/PLOT Plots data in the CHECKSYSTEM object

% cd into proper directory
cd(obj.path{n})

% load the mat file
load('checksystem');

% set default values of trigLength and threshold
trigLength = 305;
threshold = 2500;

% check optional arguments
num_args = nargin - 2;
i = 1;
while(i <= num_args)
	if ischar(varargin{i})
		switch varargin{i}
		case('trigLength')
			% get value
			val = varargin{i+1};
			% remove argument from varargin
			[varargin,num_args] = removeargs(varargin,i,2);
			i = i - 1;
		case('threshold')
			% get value
			val = varargin{i+1};
			% remove argument from varargin
			[varargin,num_args] = removeargs(varargin,i,2);
			i = i - 1;
		end
		i = i + 1;
	else
		% not a character, just skip over it
		i = i + 1;
	end
end

PlotExpSystemResults(results,dmins,mmins,trigLength,threshold);
% get list of trials
ts = nptDir('*.0*');
% show name of last file
fprintf('Session: %s\n',ts(end).name);
% get selected data
if(~isempty(mmins))
	r = results(mmins(:,1),[1 5:8]);
	% get rid of lines with 0's 
	ri = find(r(:,2));
	r(ri,:)
end
h = axes('Position',[0 0 1 1],'Visible','off');
text(0.5,0.95,obj.path{n},'HorizontalAlignment','Center');
