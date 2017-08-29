function n = get(s,prop_name,varargin)
%STREAMER/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object property. PROP_NAME 
%   can be one of the following:
%      'SessionName' - name of session.
%      'Channel'- signal number inside the streamer file.
%
%   Dependencies: None.

switch prop_name
case 'SessionName'
	n = s.sessionname;
case 'Channel'
	n = s.channel;
otherwise
	n = get(s.nptdata,prop_name);
end
