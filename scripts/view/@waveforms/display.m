function display(w)
%WAVEFORMS/DISPLAY Command window display of a waveform object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\twaveforms object with %i waveforms with fields:\n',get(w,'Number'));
fprintf('\tnumWaves\n');
fprintf('\tdata[].wave\n');
fprintf('\tdata[].time\n');
