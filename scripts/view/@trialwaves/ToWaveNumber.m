function w = ToWaveNumber(obj,trial,wave)
%TRIALWAVES/ToWaveNumber Convert trial and wave info to waveform number
%   W = ToWaveNumber(OBJ,TRIAL,WAVE) returns the waveform number in a 
%   WAVEFORMS object corresponding to the TRIAL number and the WAVE 
%   number inside that trial. If TRIAL exceeds the number of trials
%   or if WAVE exceeds the number of waveforms in TRIAL, this function
%   will return 0.
%
%   Dependenceis: None.

if trial>1
	if trial>obj.trials
		w = 0;
	end

	ptrial = trial - 1;
	waves = obj.lastwave(trial) - obj.lastwave(ptrial);
	if wave > waves
		w = 0;
	elseif wave < 1
		w = 0;
	else
		w = obj.lastwave(ptrial) + wave;
	end
else
	waves = obj.lastwave(1);
	if wave > waves
		w = 0;
	elseif wave < 1
		w = 0;
	else
		w = wave;
	end
end
