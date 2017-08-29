function p = get(w,varargin)
%WAVEFORMS/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME,N) returns an object property or a
%   property stored in an array with the array index specified by N.
%   PROP_NAME can be one of the following:
%      'WavePoints' (need to specify N)
%      'WaveTime' (need to specify N)
%      'Number' (inherited from nptdata)
%      'HoldAxis' (inherited from nptdata)
%
%   Dependencies: None.

Args = struct('WavePoints',[],'WaveTime',[]);
Args = getOptArgs(varargin,Args);

if(~isempty(Args.WavePoints))
	p = w.data(Args.WavePoints).wave;
elseif(~isempty(Args.WaveTime))
	p = w.data(Args.WaveTime).time;
else
	p = get(w.nptdata,varargin{:});
end
