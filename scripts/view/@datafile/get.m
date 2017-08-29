function n = get(s,varargin)
%DATAFILE/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object property. PROP_NAME 
%   can be one of the following:
%      'SessionName' - name of session.
%      'Channel'- signal number inside the streamer file.
%
%   Dependencies: None.

Args = struct('SessionName',0,'Channel',0);
Args = getOptArgs(varargin,Args,'flags',{'SessionName','Channel'});

if(Args.SessionName)
	n = s.sessionname;
elseif(Args.Channel)
	n = s.channel;
else
	n = get(s.nptdata,varargin{:});
end
