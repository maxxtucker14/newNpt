function InspectDatFile(filename)
%InspectDatFile	Plots extracted waveforms
%	INSPECTDATFILE(FILENAME) reads the DAT file specified in 
%	FILENAME and plots each waveform along with the time
%	of the waveform.
%
%	Dependencies: @waveforms,@waveforms/Inspect.

[path,name] = nptFileParts(filename);
waveforms = waveforms(name);

Inspect(waveforms)
