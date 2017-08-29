function ConvertWaveforms(filename, duration)



samplingRate=30000;
if duration==17
    binsize=500000;
else
    error('wrong duration');
end

% change duration to micro-seconds for use with time in waveforms data
duration = duration*10^6;


times = ReadWaveformsFile(filename,[],6);   %microseconds
times = ConvertTimes(times,duration,binsize,samplingRate);

%read header
[hdrsz , num_spikes, num_cha, gain, ptswv] = ReadWaveformsHeader(filename);
fid=fopen(filename,'r+');
    status = fseek(fid,hdrsz+2*ptswv*num_cha*num_spikes,'bof');     %2 for int16
    fwrite(fid,times,'uint64');

fclose(fid);
fprintf('Converted %s times\n',filename);
