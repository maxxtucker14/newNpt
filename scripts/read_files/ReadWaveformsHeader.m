function [hdrsz , num_spikes, num_channels, gain, ptswv] = ReadWaveformsHeader(filename)
%[hdrsz , num_spikes, num_channels, gain, ptswv] = ReadWaveformsHeader(filename)
%
%headersize
%num_spikes
%num_channels
%gain for times
%points per waveform

fid = fopen(filename,'r','ieee-le');
if fid==-1
   fprintf('Error opening %s.\n',filename);
end
fseek(fid,0,'bof');
hdrsz = fread(fid,1,'uint32');
num_spikes = fread(fid,1,'uint32');
num_channels = fread(fid,1,'uint8');
gain = fread(fid,1,'uint32');
ptswv = fread(fid,1,'uint32');
fclose(fid);