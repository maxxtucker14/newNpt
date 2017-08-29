function WriteWaveformsHeader(fid,num_spikes,num_channels)
%WriteWaveformsHeader(fid,num_spikes,num_channels)
%
%write header portion of extracted waveforms file
%header contains:
%   size of header - 100 bytes - uint32
%   number of spikes - variable - uint32
%   number of channels - 1 or 2 or 4 - uint8
%   gain in seconds - 1000000 - uint32
%   #points per waveform - 32 - uint8


fseek(fid,0,'bof');
fwrite(fid,100,'uint32');
fwrite(fid,num_spikes,'uint32');
fwrite(fid,num_channels,'uint8');
fwrite(fid,1000000,'uint32');
fwrite(fid,32,'uint8');
cpos = ftell(fid);
fwrite(fid,zeros(1,100-cpos),'int8');
