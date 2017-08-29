function [num_channels,sampling_rate,scan_order]=nptReadStreamerFileHeader(rawfile)
%nptReadStreamerFileHeader Function to read the header of binary files from Data Streamer
%	[NUM_CHANNELS,SAMPLING_RATE,SCAN_ORDER] 
%			= nptReadStreamerFileHeader(FILENAME)
% 	opens the file FILENAME and returns the information contained
%   in the header. NUM_CHANNELS is the number of channels recorded. 
%   SAMPLING_RATE is the sampling rate used in the data collection 
%   in points per second. SCAN_ORDER returns the channel numbers 
%   used during the recording. 
%	e.g. 
%		[num_channels,sampling_rate,scan_order] ...
%			= nptReadStreamerFileHeader('annie04240101.0057');
%	reads the header from trial 57 of a multi-trial session.
%	or
%	e.g. 
%		[num_channels,sampling_rate,scan_order] ...
%			= nptReadStreamerFileHeader('a101.bin');
%	reads the header from a single-trial session.
%
%	Dependencies: nptParseStreamerHeader.

myerror = 0;
fid=fopen(rawfile,'r','ieee-le');
if fid==-1
   fprintf('Error opening %s',rawfile);
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
   num_channels = 0;
   sampling_rate = 0;
   scan_order = [];
else
   fclose(fid);
end
