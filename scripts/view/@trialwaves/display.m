function display(w)
%WAVEFORMS/DISPLAY Command window display of a waveform object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\ttrialwaves object with %i trials with fields:\n',w.trials);
fprintf('\ttrials\n');
fprintf('\tlastwave\n');
fprintf('\twaveforms\n');
