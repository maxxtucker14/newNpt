function Waveform32to64(filename)
%function Waveform32to64(filename)
%
%convert older waveform.bin files with times written as uint32 so that the
%times are written as uint64.
%
%assumes file is in pwd


%read header
[hdrsz , num_spikes, num_cha, gain, ptswv] = ReadWaveformsHeader(filename);

fid = fopen(filename,'r','ieee-le');

%double check to make sure file is written with 32 bit times
fseek(fid,0,'eof');
filesize = ftell(fid);      %in bytes
if (filesize-100-2*ptswv*num_cha*num_spikes)/4 ==num_spikes
    fprintf('changing from uint32 to uint64 ...')
    
    status = fseek(fid,hdrsz+2*ptswv*num_cha*num_spikes,'bof');     %2 for int16
    times = fread(fid,num_spikes,'uint32');
    fclose(fid);
    
    %now write times as uint64
    fid=fopen(filename,'r+');
    status = fseek(fid,hdrsz+2*ptswv*num_cha*num_spikes,'bof');     %2 for int16
    fwrite(fid,times,'uint64');
    
end
fclose(fid);
fprintf('Converted %s to uint64\n',filename);