function status=nptWriteStreamerFileHeader(filename,sampling_rate,num_channels,scan_order)
%nptWriteStreamerFileHeader Function to write binary files from Data Streamer
%function status=nptWriteStreamerFileHeader(filename,sampling_rate,num_channels,scan_order)
%scanorder is optional


header_size=73;

fid=fopen(filename,'w','ieee-le');
if fid~=-1
   status=1;
end
if nargin==3
   scan_order=zeros(1,64);
   pad=[];
else
   %pad scan_order to 64 numbers
   pad=zeros(1,64 - size(scan_order,1));
end

fwrite(fid, header_size, 'int32');					% 4 bytes reserved for header size which is 73 bytes
fwrite(fid,num_channels, 'uchar');				% 1 byte
fwrite(fid,sampling_rate, 'uint32');				% 4 bytes
fwrite(fid,scan_order,'uchar');				% 1 byte for each channel up to 64 channels
fwrite(fid,pad,'int8');
fclose(fid);
