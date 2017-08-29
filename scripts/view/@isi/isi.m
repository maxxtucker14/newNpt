function obj = isi(varargin)
%@isi Constructor function for ISI class
%   OBJ = isi('auto') attempts to create a ISI object by ...

Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0,'ComputeSurr',0,...
    'InterBI',50,'IntraBI',5,'AdjSpikes',0,'NoBurst',0);

Args.flags = {'Auto','ComputeSurr','AdjSpikes','NoBurst'};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'isi';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'isi';

numArgin = nargin;
if(numArgin==0)
	% create empty object
	obj = createEmptyObject(Args);
elseif( (numArgin==1) & isa(varargin{1},Args.classname))
	obj = varargin{1};
else
	% create object using arguments
	if(Args.Auto)
		% check for saved object
		if(ispresent(Args.matname,'file','CaseInsensitive') ...
			& (Args.RedoLevels==0))
			fprintf('Loading saved %s object...\n',Args.classname);
			l = load(Args.matname);
			obj = eval(['l.' Args.matvarname]);
			if(Args.ComputeSurr)
				% compute the isi for the surrogates if it is not already 
				% computed and save it but don't load it if it is already 
				% computed
				getSurrISI(obj,'NoLoad',modvarargin{:});
			end
		else
			% no saved object so we will try to create one
			% pass varargin in case createObject needs to instantiate
			% other objects that take optional input arguments
			obj = createObject(Args,modvarargin{:});
		end
	end
end

function obj = createObject(Args,varargin)

% try to instantiate object
if(Args.AdjSpikes)
    isp = adjspikes('auto',varargin{:});
    sptimes = isp.data.adjSpiketrain;
else
    isp = ispikes('auto',varargin{:});
    sptimes = isp.data.trial.cluster.spikes;
end
% [p,cwd] = getDataDirs('Session','CDNow');
cwd = pwd;
% cd ../.. % Move to the session level
sinfo = stiminfo('Auto');
% cd(cwd);
if(~isempty(sptimes))
	% this is a valid object
	data.numSets = 1;
	data.setNames{1} = cwd;
	data.isi = vecc(diff(sptimes));
    data.IntraBurstInterval = Args.IntraBI;
    data.InterBurstInterval = Args.InterBI;
    if(Args.NoBurst)
        data.BurstSpikesIndex = [];
        data.PercBurstSpikes = [];
        data.MeanFR = [];
    else
        [data.BurstSpikesIndex,data.PercBurstSpikes,data.MeanFR] = BurstActivityFinder(sptimes,sinfo,Args);
    end
	% create nptdata
	n = nptdata(1,0,cwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	if(Args.SaveLevels)
		fprintf('Saving %s object...\n',Args.classname);
		eval([Args.matvarname ' = obj;']);
		% save object
		eval(['save ' Args.matname ' ' Args.matvarname]);
	end
	if(Args.ComputeSurr)
		% compute the isi for the surrogates if it is not already computed
		% and save it but don't load it if it is already computed
		getSurrISI(obj,'NoLoad',varargin{:});
	end
else
	obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

data.numSets = 0;
data.setNames = '';
data.isi = [];
data.IntraBurstInterval = Args.IntraBI;
data.InterBurstInterval = Args.InterBI;
data.burst = [];
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
