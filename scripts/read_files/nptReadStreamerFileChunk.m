function [data,num_channels,sampling_rate,scan_order,points]=nptReadStreamerFileChunk(rawfile,Binsize)
%nptReadStreamerFileChunk Function to read binary files from Data Streamer
%	[DATA,NUM_CHANNELS,SAMPLING_RATE,SCAN_ORDER,POINTS] 
%			= nptReadStreamerFileChunk(FILENAME,Binsize)
% 	opens the file FILENAME and returns the data in a matrix DATA with 
%	the data for each channel in a row. The data is in millivolts. 
%	NUM_CHANNELS is the number of channels recorded. SAMPLING_RATE 
%	is the sampling rate used in the data collection in points per 
%	second. SCAN_ORDER returns the channel numbers used during the 
%	recording. POINTS returns the number of data points in each 
%	channel.
%   Binsize is a vector specifing which chunk to read.  
%
%   eg.   [data,num_channels,sampling_rate,scan_order,points] ...
%                = nptReadStreamerFile('a101.bin',[1 500000]); 
%   will read points 1 through 500000.
%
%	Dependencies: nptParseStreamerHeader.

myerror = 0;
fid=fopen(rawfile,'r','ieee-le');
if fid==-1
   fprintf('Error opening %s.\n',rawfile);
   myerror = 1;
else
	[num_channels,sampling_rate,scan_order] = nptParseStreamerHeader(fid);
	if isempty(num_channels) | isempty(sampling_rate) | isempty(scan_order)
   		fprintf('Error reading header %s.\n',rawfile);
   	fclose(fid);
   	myerror = 1;
	end
end

if myerror==1
   data = [];
   num_channels = 0;
   sampling_rate = 0;
   scan_order = [];
   points = 0;
   return
end

fpos = ftell(fid);
status = fseek(fid,fpos+num_channels*(Binsize(1)-1)*2,'bof');
if status==-1
    error('data out of range')
else
[data,count]=fread(fid, [num_channels,Binsize(2)-Binsize(1)+1], 'int16');
end

points = count/num_channels;

fclose(fid);
