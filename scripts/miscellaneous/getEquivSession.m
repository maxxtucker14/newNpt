function r = getEquivSession(varargin)
%getEquivSession Return session directory equivalent to current cluster
%   R = getEquivSession('EquivalentSessions',DIRS_CELL_ARRAY) returns
%   the directory equivalent to the current directory but for a
%   different session, i.e. for a different stimuli. The directories
%   in DIRS_CELL_ARRAY should be fully qualified since this function 
%   uses the function pwd to return the fully qualified current 
%   directory.

Args = struct('EquivalentSessions',{''});
[Args,varargin2] = getOptArgs(varargin,Args);

% get current directory
cwd = pwd;

% get site information
sited = getDataDirs('site');

% find entries in EquivalentSessions with the same site
esidx = strmatch(sited,Args.EquivalentSessions);
if isempty(esidx)
    r=[];
    return
end
% get group and cluster information
% find filesep positions in cwd
fsidx = strfind(cwd,filesep);
% get length of fsidx
fsidxl = length(fsidx);
% get string starting from the second last filesep
gcstr = cwd(fsidx(fsidxl-1):end);

% find entries in EquivalentSessions{esidx} with the same group and
% cluster name
gcstr = strrep(gcstr,'\','.');
ridx = regexp({Args.EquivalentSessions{esidx}},gcstr);
if isempty(ridx)
    r=[];
    return
elseif length(ridx)==1
    esidx2=1;
else
    esidx2 = find(~cellfun('isempty',ridx));
end
if(isempty(esidx2))
    r = [];
else
    r = Args.EquivalentSessions{esidx(esidx2(1))};
end
