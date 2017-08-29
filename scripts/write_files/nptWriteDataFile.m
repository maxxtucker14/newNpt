function status=nptWriteDataFile(filename,sampling_rate,data)
%function status=nptWriteDataFile(filename,sampling_rate,data)
%writes binary files with similiar header as a Streamer file
%
% datatype is as follows:
% 1 => 'uchar';  
% 2 => 'schar';   
% 3 => 'int8';    
% 4 => 'int16';  
% 5 => 'int32';   
% 6 => 'int64';   
% 7 => 'uint8';   
% 8 => 'uint16';  
% 9 => 'uint32';  
% 10 => 'uint64';  
% 11 => 'single';  
% 12 => 'float32'; 
% 13 => 'double';  
% 14 => 'float64'; 

 
datatype=12;
header_size=73;
num_channels=size(data,1);

fid=fopen(filename,'w','ieee-le');
if fid~=-1
   status=1;
end

fwrite(fid, header_size, 'int32');		% 4 bytes reserved for header size which is 73 bytes
fwrite(fid,num_channels, 'uchar');		% 1 byte
fwrite(fid,sampling_rate, 'uint32');	% 4 bytes
fwrite(fid,datatype,'int8');				% 1 byte for datatype
fwrite(fid,zeros(1,63),'int8');			% skip to the end of headersize


fwrite(fid, data, 'float32');
fclose(fid);
