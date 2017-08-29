function obj = ispikes(varargin)
%ISPIKES Constructor function for the interleaved spikes (ISPIKES) class
%
%
%   SPIKE = ISPIKES(varargin) instantiates an ISPIKES
%   object that stores all the spike trains by trials and
%   clusters. This function opens a .CUT file
%   a waveforms.bin file and a .HDR file (named
%   GROUPNAME.HDR) in the current directory and uses data from these
%   3 files to create the spike data. The USESORT argument (0 or 1)
%   specifies if a .cut is to be used or not. If a cut file is NOT to
%   be used (i.e. USESORT = 0)  all spikes from the waveforms.bin are
%   added to the cluster numbered MUACLUSTER. Default is USESORT=1.
%   For example,
%      annie0424010101 = ispikes('Group','0001')
%
%   creates spike data for a session with a .CUT file.
%
%   SPIKE = ISPIKES(varargin) instantiates an ISPIKES
%   object that stores all the spike trains by trials and
%   clusters. This function opens a .GDF file (named GROUPNAME1.GDF),
%   a .DAT file (named GROUPNAME.DAT) and a .HDR file (named
%   GROUPNAME.HDR) in the current directory and uses data from these
%   3 files to create the spike data. The USESORT argument (0 or 1)
%   specifies if a .GDF is to be used or not. If a GDF file is to be
%   used (i.e. USESORT = 1) and MUACLUSTER is 0, any spikes from DAT that
%   are not in GDF will be stored in a new cluster. Otherwise, the
%   missing spikes are added to the	cluster numbered MUACLUSTER.
%   SPIKE is a structure with the following fields:
%      SPIKE.data.title
%      SPIKE.data.sessionname	data file from which the spikes were extracted
%      SPIKE.data.groupname		signal groupnumber (specified in descriptor.txt file)
%      SPIKE.data.cellname
%      SPIKE.data.duration	duration used to form continuous trial
%      SPIKE.data.min_duration
%      SPIKE.data.signal	signal number in the data file
%      SPIKE.data.means	means for all trials
%      SPIKE.data.thresholds	thresholds used in extraction for all trials
%      SPIKE.data.numChunks
%      SPIKE.data.chunkSize
%      SPIKE.data.trial(trial).cluster(clusternum).spikecount
%      SPIKE.data.trial(trial).cluster(clusternum).spikes()
%      SPIKE.data.numTrials
%      SPIKE.data.numClusters
%
%   Spiketimes are stored in milliseconds with microsecond precision.
%   For example,
%      annie0424010101 = ispikes('Group','0001','UseSort',0)
%
%   creates spike data for a session with no .GDF file.
%
%   And,
%      annie0424010101 = ispikes('Group','0001','MuaCluster',3)
%
%   creates spike data for a session with a .GDF file. Spikes
%   that are missing from the .GDF file are added to cluster
%   number 3.
%
%   SPIKE = ISPIKES('auto') loads the already saved
%   ispikes object from the pwd.
%
%   Dependencies: private/GenerateSessionSpikeTrains
%                 and private/GenerateSessionDatSpikeTrains.


Args = struct('RedoLevels',0,'SaveLevels',0, ...
    'Auto',0,'Group','','MuaCluster',0,'UseSort',1,'Resave',0, ...
    'ShortName',0);

Args = getOptArgs(varargin,Args, ...
    'flags',{'Auto','Resave','ShortName'}, ...
    'shortcuts',{'redo',{'RedoLevels',1};'save',{'SaveLevels',1}}, ...
    'subtract',{'RedoLevels','SaveLevels'});

% variable defaults
shortName = 0;

if nargin==0
    % create empty object
    obj = createEmptyObject;
elseif( (nargin==1) & (isa(varargin{1},'ispikes')) )
    obj = varargin{1};
elseif Args.RedoLevels==0
    % check for saved object
    if isempty(Args.Group)
        dirlist = nptDir('*ispikes.mat','CaseInsensitive');
        % set ShortName so if we need to resave, it will use the right name
        shortName = 1;
    else
        dirlist = nptDir(['*' Args.Group '_ispike.mat'],'CaseInsensitive');
        dirlist = [dirlist nptDir(['*' Args.Group '_spike.mat'],'CaseInsensitive')];
    end
    if size(dirlist,1)> 1
        warning('More than one ispikes file found.  Loading %s\n',dirlist(1).name)
    end
    if ~isempty(dirlist)
        fprintf('Loading %s\n',dirlist(1).name);
        lastwarn('');
        try
            % load saved object and exit
            % use '-mat' in case the suffix is in uppercase which confuses
            % Matlab and it then tries to load it as an ASCII file
            l = load(dirlist(1).name,'-mat');
            if(~isempty(lastwarn))
                error('Outdated ispikes object...');
            end
            obj = l.sp;
        catch
            % since there was an old object, we want to resave the
            % the new object
            Args.SaveLevels = 1;
            obj = createObject(Args);
        end
        if(Args.Resave)
            if(shortName)
                Args.ShortName = 1;
            end
            saveObject(obj,Args);
        end
    else
        obj = createObject(Args);
    end
elseif Args.RedoLevels
    obj = createObject(Args);
end





function obj = createEmptyObject
% property of nptdata base class
holdAxis = 1;

s.data.title = '';
s.data.sessionname = '';
s.data.groupname = '';
s.data.cellname = '';
s.data.duration = 0;
s.data.min_duration = 0;
s.data.signal = [];
s.data.means = [];
s.data.thresholds = [];
s.data.numChunks = 0;
s.data.chunkSize = 0;
s.data.trial = [];
s.data.numTrials = 0;
s.data.numClusters = 0;

nd = nptdata(holdAxis,0);
obj = class(s,'ispikes',nd);




function obj = createObject(Args)


% property of nptdata base class
holdAxis = 1;

% check to see if we are trying to create a new object in the cluster
% directory. Moved this section from try-catch section above since it
% was having problems when RedoLevels was not 0.
[p,n,e] = fileparts(pwd);
if strmatch('cluster',n) %if we are in the cluster folder...
    clusterDir = pwd;
    cd('..')
    [p,n,e] = fileparts(pwd);
    group = n(6:9);
    cd(['..' filesep 'sort'])
    groupObj = ispikes('Group',group,'save');
    % call separate to recreate cell ispikes objects and
    % save them
    objs = separate(groupObj,'save');
    % figure out which one was the one we were trying to
    % instantiate
    % get the clutername
    [p,f] = nptFileParts(clusterDir);
    % remove the cluster from f and find match
    objsIndex = strmatch(strrep(f,'cluster',''),cn,'exact');
    % return updated object that was originally being
    % instantiated
    obj = objs{objsIndex};
    % return to original directory
    cd(clusterDir)
else
    % not in cluster directory so check for other cases
    if isempty(Args.Group)
        warning('Must specify a group or use separate.  Creating empty object');
        obj = createEmptyObject;
        return
    end
    if ~isempty(nptDir(['*' Args.Group 'waveforms.bin']))
        s.data = GenerateSessionSpikeTrains(Args.Group,Args.UseSort);
        if Args.UseSort==0 % Used when Mclust is not used to create the MUA cluster
            if isempty(s.data.cellname)
                s.data.cellname='01m';
            end
        end
        if s.data.numChunks
            nd = nptdata(s.data.numChunks,holdAxis);
        else
            nd = nptdata(s.data.numTrials,holdAxis);
        end
        obj = class(s,'ispikes',nd);
    elseif ~isempty(nptDir([Args.Group '.dat']))
        s.data = GenerateSessionDatSpikeTrains(Args.Group,Args.UseSort,Args.MuaCluster);
        s.data.cellname='';
        s.data.numChunks=0;
        s.data.chunkSize = 0;
        nd = nptdata(s.data.numTrials,holdAxis);
        obj = class(s,'ispikes',nd);
    else
        error('Error!  No waveforms.bin or dat files in pwd.')
    end
end
if Args.SaveLevels & Args.UseSort
    saveObject(obj,Args);
end




function saveObject(sp,Args)
if(Args.ShortName)
    filename = 'ispikes.mat';
    fprintf('Saving ispikes object...\n');
else
    % remove _highpass if present from the session name before saving file
    filename = [strrep(sp.data.sessionname,'_highpass','') 'g' sp.data.groupname '_ispike.mat'];
    fprintf('Saving ispikes object as %s...\n',filename);
end
save(filename,'sp')

