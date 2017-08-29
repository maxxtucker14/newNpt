function [n,varargout] = get(e,varargin)
%EYES/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object property. PROP_NAME 
%   can be one of the following:
%      'SessionName' - name of session.
%      'Channel'- signal number inside the streamer file.
%      'Number' (inherited from nptdata)
%      'HoldAxis' (inherited from nptdata)
%
%   [DATA,POINTS] = GET(OBJ,'DataPixels',N) returns the data in pixels 
%   for trial N as well as the number of data points in POINTS.
%
%   [DATA,POINTS] = GET(OBJ,'DataDegrees',N) returns the data in 
%   degrees for trial N as well as the number of data points in POINTS.
%
%   Dependencies: None.

switch varargin{1}
case 'SessionName'
	n = e.sessionname;
case 'Channel'
	n = e.channel;
case {'DataPixels','DataDegrees'}
	% move to the right directory
    cwd = pwd;
	cd(e.nptdata.SessionDirs{1});
	[data,nc,sr,dt,points] = nptReadDataFile([e.sessionname '_eye.' sprintf('%04i',varargin{2})]);
    cd(cwd);
	if strcmp(varargin{1},'DataDegrees')
		[datav,datah] = pixel2degree(data(1,:),data(2,:));
		data = [datav;datah];
	end
	if nargout==1
		n = data;
	elseif nargout==2
		n = data;
		varargout(1) = {points};
	else
		error('Invalid number of outputs!');
	end
otherwise
	n = get(e.nptdata,varargin{1});
end
