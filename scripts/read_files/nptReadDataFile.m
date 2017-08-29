function [data,num_channels,sampling_rate,datatype,points]=nptReadDataFile(rawfile)
%nptReadDataFile Function to read binary files similiar to Streamer files
%	[DATA,NUM_CHANNELS,SAMPLING_RATE,DATATYPE,POINTS] = nptReadDataFile(FILENAME)
% 	opens the file FILENAME and returns the data in a matrix DATA with 
%	the data for each channel in a row. The data is in millivolts. 
%	NUM_CHANNELS is the number of channels. SAMPLING_RATE is the 
%	sampling rate used in the data collection. DATATYPE is listed below. POINTS returns
%	the number of data points in each channel.
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


fid=fopen(rawfile,'r','ieee-le');
header_size=fread(fid, 1, 'int32');					% 4 bytes reserved for header size which is 73 bytes
num_channels=fread(fid, 1, 'uchar');				% 1 byte
sampling_rate=fread(fid, 1, 'uint32');				% 4 bytes
datatype = fread(fid,1,'int8');	% datatype assume for now float32
fseek(fid, header_size, 'bof');						% skip to the end 

[data,count]=fread(fid, [num_channels,inf], 'float32');
fclose(fid);

points = count/num_channels;