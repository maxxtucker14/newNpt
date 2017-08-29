function obj = eyemvt(varargin)
% @eyemvt Constructor function for EYEMVT class
%   OBJ = eyemvt('auto') attempts to create a eyemvt object by 
%   using the data files SESSIONNAME_eye.000* (which are assumed to be 
%   in the current directory). The eyemvt object contains all the 
%   following fields for saccades and fixations and assessed as such:
% 
%   obj.data.sacStart: start of saccades [ms]
%   obj.data.sacEnd: end of saccades [ms]
%   obj.data.sacMaxVel: maximum velocity of saccades [degree/ms]
%   obj.data.sacMaxVelTime: occurence of the maximum velocity of the
%   saccades [ms]
%   obj.data.sacAmpl: Amplitude of the saccades [degree]
%   obj.data.sacSetIndex : index to keep tract of which saccades belong to
%   which trial and session. 
%   Format: [cummulative-session cummulative-trial trial event-#]
% 
%   obj.data.fixStart: start of fixations [ms] 
%   obj.data.fixEnd: end of fixations [ms] 
%   obj.data.fixMaxVel: maximum velocity of fixations [degree/ms] 
%   obj.data.fixMaxVelTime: occurence of the maximum velocity of the
%   fixations [ms]
%   obj.data.fixMeanVel: occurence of the mean velocity of the
%   fixations [ms]
%   obj.data.fixAmpl: Amplitude of the fixations [degree]
%   obj.data.fixSetIndex:index to keep tract of which fixations belong to
%   which trial and session 
%   
%   The data are raw vectors of all the saccades for a given session.
%
%   Dependencies: EyeMvtAlgo,nptdata.

Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0);
Args.flags = {'Auto'};
[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'eyemvt';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'em';

numArgin = nargin;
if(numArgin==0)
	% create empty object
	obj = createEmptyObject(Args);
elseif( (numArgin==1) & isa(varargin{1},Args.classname))
	obj = varargin{1};
else
	% create object using arguments
	if(Args.Auto)
        % change to the proper directory
        [pdir,cdir] = getDataDirs('eye','relative','CDNow');%dirLevel('eye','relative','CDNow');
        if(isempty(cdir))
            % if there is an eye subdirectory, we are probably in the session dir
            % so change to the eye subdirectory
            [r,a] = ispresent('eye','dir','CaseInsensitive');
            if r
                cdir = pwd;
                cd(a);
            end
        end
		% check for saved object
		if(ispresent(Args.matname,'file','CaseInsensitive') ...
			& (Args.RedoLevels==0))
			fprintf('Loading saved %s object...\n',Args.classname);
			l = load(Args.matname);
			obj = eval(['l.' Args.matvarname]);
		else
			% no saved object so we will try to create one
			% pass varargin in case createObject needs to instantiate
			% other objects that take optional input arguments
			obj = createObject(Args,modvarargin{:});
		end
        % change back to previous directory if necessary
        if(~isempty(cdir))
            cd(cdir)
        end
	end
end

function obj = createObject(Args,varargin)

efiles = nptDir('*_eye.*');
dnum = length(efiles);

% check if the right conditions were met to create object
if(dnum>0)
	% this is a valid object
	% these are fields that are useful for most objects
    [out,eye,status] = EyeMvtAlgo(varargin{:});
    if status == -1
        fprintf('Error computing the saccades and fixations, please have a closer look!!!!!!!!!!!')
        dbstop
    end
    data = out;
	data.numSets = out.fixSetIndex(end,2); % nbr of trial
	data.setNames{1} = pwd;
	
	% create nptdata so we can inherit from it
	n = nptdata(data.numSets,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	if(Args.SaveLevels)
		fprintf('Saving %s object...\n',Args.classname);
		eval([Args.matvarname ' = obj;']);
		% save object
		eval(['save ' Args.matname ' ' Args.matvarname]);
	end
else
	% create empty object
	obj = createEmptyObject(Args);
    fprintf('No *_eye.* files!!!!!!!!!!!!!!!\n')
end

function obj = createEmptyObject(Args)

% useful fields for most objects


% these are object specific fields

data.sacStart = [];
data.sacEnd = [];
data.sacMaxVel = [];
data.sacMaxVelTime = [];
data.sacAmpl = [];
data.sacSetIndex = []; % this a matrix n by 4 where the columns correspond to the session number(:,1), cummulative trials(:,2), real trials(:,3) and the event (:,4)

data.fixStart = [];
data.fixEnd = [];
data.fixMaxVel = [];
data.fixMaxVelTime = [];
data.fixMeanVel = [];
data.fixAmpl = [];
data.fixSetIndex = []; % this a matrix n by 4 where the columns correspond to the session number(:,1), cummulative trials(:,2), real trials(:,3) and the event (:,4)

data.numSets = 0;
data.setNames = '';
% create nptdata so we can inherit from it
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
