function [num_channels,sampling_rate,scan_order] = nptParseStreamerHeader(fid)

header_size=fread(fid, 1, 'int32');					% 4 bytes reserved for header size which is 73 bytes
num_channels=fread(fid, 1, 'uchar');				% 1 byte
sampling_rate=fread(fid, 1, 'uint32');				% 4 bytes
% check to make sure num_channels is valid before trying to use it
if ~isempty(num_channels)
   scan_order = fread(fid,num_channels,'uchar');	% 1 byte for each channel up to 64 channels
else
   scan_order = [];
end
% check to make sure header_size is valid before trying to use it
if ~isempty(header_size)
   fseek(fid, header_size, 'bof');						% skip to the end of the 64 bytes allocated for scan order
end


