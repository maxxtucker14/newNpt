function sessionname = nptGetSessionName()
%nptGetSessionName Returns session name using current directory
%   SESSION_NAME = nptGetSessionName returns the session name
%   associated with the current directory. The current directory
%   is assumed to be named like /Data/Disco/071002/01. In this
%   the session name returned will be disco07100201.
%
%   Dependencies: None.

% get current directory, format should be Disco/071002/01
cwd = nptPWD;
% get length
cwdl = length(cwd);
% get animal name
[path,name] = nptFileParts(cwd(1:cwdl-10));
% make sure it is lowercase
animal = lower(name);
sessionname = [animal cwd(cwdl-8:cwdl-3) cwd(cwdl-1:cwdl)];
