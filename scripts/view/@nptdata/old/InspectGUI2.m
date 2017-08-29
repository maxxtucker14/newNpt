function fig = InspectGUI(varargin)
%NPTDATA/InspectGUI Inspect object
%   FIG = InspectGUI(OBJ, VARARGIN) displays a graphical user interface to
%   step through data contained in OBJ.
%
%   The optional input arguments are:
%      holdaxis - specifies whether to hold the axis limits constant 
%                 across plots.
%      addObjs - specifies that the following cell array contains
%                additional objects that should be plotted at the
%                same time.
%      optArgs - specifies that the following cell array contains 
%                optional input arguments for the various objects.
%                If this option is not specified, and there is only
%                one object, the remaining arguments are assumed to
%                be optional input arguments.
%   Examples:
%   InspectGUI(rf,'addObjs',{rf},'optArgs',{{},{'recovery'}})
%   InspectGUI(bi,'addObjs',{pi,rt})
%
%   FIG = InspectGUI(OBJ,'holdaxis','addObjs',{OBJ1,OBJ2},'optArgs',{{}})


% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

load InspectGUI

h0 = figure('Units','characters', ...
    'Color',[0.8 0.8 0.8], ...
    'Colormap',mat0, ...
    'Position',[64.8 9.692307692307693 102.4 29.46153846153846], ...
    'Tag','Fig1');
h1 = uicontrol('Parent',h0, ...
    'Units','normalized', ...
    'Callback','InspectCB Previous', ...
    'Position',[0.216796875 0.02349869451697128 0.134765625 0.05483028720626632], ...
    'String','Previous', ...
    'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
    'Units','normalized', ...
    'Callback','InspectCB Next', ...
    'Position',[0.642578125 0.02088772845953003 0.134765625 0.05483028720626632], ...
    'String','Next', ...
    'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
    'Units','normalized', ...
    'Callback','InspectCB Number', ...
    'Position',[0.486328125 0.02349869451697128 0.115234375 0.05744125326370757], ...
    'Style','edit', ...
    'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
    'Units','normalized', ...
    'Position',[0.359375 0.02349869451697128 0.12109375 0.04438642297650131], ...
    'String','Number:', ...
    'Style','text', ...
    'Tag','StaticText1');
h1 = axes('Parent',h0, ...
    'CameraUpVector',[0 1 0], ...
    'CameraUpVectorMode','manual', ...
    'Color',[1 1 1], ...
    'ColorOrder',mat1, ...
    'Position',[0.072265625 0.1383812010443864 0.8828125 0.7806788511749347], ...
    'Tag','Axes1', ...
    'XColor',[0 0 0], ...
    'YColor',[0 0 0], ...
    'ZColor',[0 0 0]);

if nargout > 0, fig = h0; end

% by default, use the first argument as the object. This can be changed
% with the optional argument 'multipleObjs'.
obj{1} = varargin{1};

% first argument is the object so remove it
[varargin,num_args] = removeargs(varargin,1,1);

% parse optional arguments
Args = struct('HoldAxis',0,'MultObjs',{''},'AddObjs',{''},'Groups',[], ...
	'Dir','');
[Args,varargin] = getOptArgs(varargin,Args, ...
	'remove',{'HoldAxis','MultObjs','AddObjs','Groups'});
	
if(strcmp(Args.HoldAxis,'true'))
	s.holdaxis = 1;
else
	s.holdaxis = 0;
end

% parse input argument to see if we need to overide object's HoldAxis property
i = 1;
while(i <= num_args)
    if ischar(varargin{i})
        switch varargin{i}
            case('multObjs')
                obj = varargin{i+1};
                s.ev = event(1,get(obj{1},'Number'));
                [varargin,num_args] = removeargs(varargin,i,2);
                i = i - 1;
            case('addObjs')
                % objs = varargin{i+1};
                % obj = {obj{1}, objs{:}};
                obj = {obj{1}, varargin{i+1}{:}};
                [varargin,num_args] = removeargs(varargin,i,2);
                i = i - 1;
            case('Groups')
                s.groups = varargin{i+1};
                [varargin,num_args] = removeargs(varargin,i,2);
                i = i - 1;
            case('optArgs')
                s.optargs = varargin{i+1};
                [varargin,num_args] = removeargs(varargin,i,2);
                i = i - 1;
            case('dir')    
                s.dir = varargin{i+1};
                [varargin,num_args] = removeargs(varargin,i,2);
                i = i - 1;
        end
        i = i + 1;
    else
        % not a character, just skip over it
        i = i + 1;
    end
    
end


s.dir{1} = nptPWD;

% get total number of objects
nobj = length(obj);
% if there are multiple objects, initialize structure for number of 
% objects
if (nobj>1)
	ndir = length(s.dir);
	if (ndir~=nobj)
		% if there are not enough directories, use the first directory,
		% which is the current directory, to fill in the rest
		for i=(ndir+1):nobj
			s.dir{i} = s.dir{1};
		end
	end
	if ~isfield(s,'optargs')
		noptArgs = 0;
	else
		noptArgs = length(s.optargs);
	end
	if (noptArgs~=nobj)
		% there should be the same number of optArgs as objects
		% if an object does not have arguments, an empty cell array
		% should still be present. Need empty cell arrays instead
		% of empty numerica arrays created by cell(n,m) in order for
		% the optional arguments to be passed on properly
		for i=(noptArgs+1):nobj
			s.optargs{i} = {};
		end
	end
else
	if ~isfield(s,'optargs')
		if (num_args>0)
			% if there are remaining arguments, and there is only 1 object with
			% no optArgs, assume they are for the object
			s.optargs  = {varargin{:}};
		else
			% set optargs to empty cell array to prevent errors
			s.optargs = {{}};			
		end
	end
end

% pass optional arguments for the object as well so that the get
% function can figure events using the optional arguments that
% the plot function is getting
s.ev = event(1,get(obj{1},'Number',s.optargs{i}{:},varargin{:}));
s.holdaxis = get(obj{1},'HoldAxis');

if isfield(s,'groups')  %group subplots together
    numg = length(unique(s.groups))-1;
    ugroups = unique(s.groups);
    %calculate spacing
    bspace=.10; %bottom space
    tspace=.05;  %top space
    space = .05; %space between groups
    height = (1-bspace-tspace-space*numg)/length(s.groups);
    width =.9;
    left = .05;
    lastbottom = 1;
    counter=0;
    for ii = 1:length(unique(s.groups))
        for jj=1:length(find(s.groups==ugroups(ii)))
            counter=counter+1;
            if jj==1
                lastbottom = lastbottom - space;
            end
            bottom = lastbottom - height;
            eval(['h' num2str(counter) '=subplot(''position'',[left bottom width height]);'])
            cd(s.dir{counter})
            % pass optional arguments in a form that can be recognized as varargin
            s.obj{counter} = plot(obj{counter},1,s.optargs{counter}{:});
            if jj==1
                title(['Group' num2str(ugroups(ii))])
            end           
            if counter~=nobj
                %set(gca,'XTick',[])
            end
            lastbottom = bottom;
        end
    end
    for jj = counter+1:counter+length(find(isnan(s.groups)))
        lastbottom = lastbottom - space;
        bottom = lastbottom - height;
        eval(['h' num2str(jj) '=subplot(''position'',[left bottom width height]);'])
        cd(s.dir{jj})
        % pass optional arguments in a form that can be recognized as varargin
        s.obj{jj} = plot(obj{jj},1,s.optargs{jj}{:});
        if jj~=nobj
            %set(gca,'XTick',[])
        end
        lastbottom = bottom;
    end
else
    for ii=1:nobj
        cd(s.dir{ii})
        subplot(nobj,1,ii)
        % pass optional arguments in a form that can be recognized as varargin
        s.obj{ii} = plot(obj{ii},1,s.optargs{ii}{:});
    end
end
if s.holdaxis
    ax = axis;
    s.lm = limits(ax(3),ax(4));
end


%set all axis to the same x range
if nobj>1
    linkedzoom(gcf,'onx')
end



f=fieldnames(s.obj{1});
if sum(strcmp(f,'title'))==1
    set(gcf,'Name',getfield(s.obj{1},'title'))
end
if sum(strcmp(f,'sessionname'))==1
    set(gcf,'Name',getfield(s.obj{1},'sessionname'))
end
    


set(h0,'UserData',s);
