function p = get(w,prop_name,varargin)
%WAVEFORMS/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object property or a
%   property stored in an array with the array index specified by N.
%   PROP_NAME can be one of the following:
%      'Trials' (number of trials)
%      'Number' (number of total waveforms, inherited from waveforms)
%      'HoldAxis' (inherited from waveforms)
%
%   VALUE = GET(OBJ,PROP_NAME,N) returns an object property or a
%      'TrialWaves' (number of waves in a trial N)
%
%   VALUE = GET(OBJ,PROP_NAME,N1,N2) returns an object property or a
%      'WavePoints' (need to specify trial in N1 and wave number 
%                     in N2)
%      'WaveTime' (need to specify trial in N1 and wave number 
%                     in N2)
%
%   Dependencies: None.

switch prop_name
case 'Trials'
	p = w.trials;
case 'TrialWaves'
	n1 = varargin{1};
	if n1>1
		p = w.lastwave(n1) - w.lastwave(n1-1);
	else
		p = w.lastwave(1);
	end
case 'WavePoints'
	n1 = varargin{1};
	n2 = varargin{2};	
	wavenum = ToWaveNumber(w,n1,n2);
	if wavenum~=0
		p = get(w.waveforms,prop_name,wavenum);
	else
		error('Out of range')
	end
case 'WaveTime'
	n1 = varargin{1};
	n2 = varargin{2};	
	wavenum = ToWaveNumber(w,n1,n2);
	if wavenum~=0
		p = get(w.waveforms,prop_name,wavenum);
	else
		error('Out of range')
	end
otherwise
	p = get(w.waveforms,prop_name);
end
