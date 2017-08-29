function [p,varargout] = dirLevel(destLevel,varargin)
%dirLevel Return information about data directories.
%   dirLevel has been renamed to getDataDirs. dirLevel still works but may be
%   removed in the future. Use getDataDirs instead.

Args = struct('CellPrefix',0,'GroupPrefix',0,'SessionPrefix',0, ...
	'SitePrefix',0,'DayPrefix',0,'DaysPrefix',0,'ShortName',0, ...
	'GetClusterDirs',0);
Args.flags = {'CellPrefix','GroupPrefix','SessionPrefix','SitePrefix', ...
	'DayPrefix','DaysPrefix','ShortName','GetClusterDirs'};
Args = getOptArgs(varargin,Args);

if(Args.CellPrefix || Args.GroupPrefix || Args.SessionPrefix || Args.SitePrefix ...
	|| Args.DayPrefix || Args.DaysPrefix || Args.ShortName || Args.GetClusterDirs)
	[p,varargout] = getDataDirs(varargin{:},destLevel);
else
	[p,varargout] = getDataDirs(destLevel,varargin{:});
end
