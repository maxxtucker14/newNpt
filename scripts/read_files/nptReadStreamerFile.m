function [data,num_channels,sampling_rate,scan_order,points]=nptReadStreamerFile(rawfile,varargin)
%nptReadStreamerFile Function to read binary files from Data Streamer
%	[DATA,NUM_CHANNELS,SAMPLING_RATE,SCAN_ORDER,POINTS] 
%			= nptReadStreamerFile(FILENAME)
% 	opens the file FILENAME and returns the data in a matrix DATA with 
%	the data for each channel in a row. The data is in millivolts. 
%	NUM_CHANNELS is the number of channels recorded. SAMPLING_RATE 
%	is the sampling rate used in the data collection in points per 
%	second. SCAN_ORDER returns the channel numbers used during the 
%	recording. POINTS returns the number of data points in each 
%	channel.
%	e.g. 
%		[data,num_channels,sampling_rate,scan_order,points] ...
%			= nptReadStreamerFile('annie04240101.0057');
%	reads the data from trial 57 of a multi-trial session.
%	or
%	e.g. 
%		[data,num_channels,sampling_rate,scan_order,points] ...
%			= nptReadStreamerFile('a101.bin');
%	reads the data from a single-trial session.
%
%   The number of channels in a data file is usually stored in its 
%   header. However, occasionally the number of channels stored in 
%   the header is incorrect. If the number of data points is not a 
%   multiple of the number of channels specified in the header, the 
%   data is padded with zeros to return an even sized matrix with 
%   NUM_CHANNELS rows and a warning will be printed out on the 
%   screen. You can call this function again with the optional 
%   argument NUM_CHANNELS to over-ride the number of channels 
%   specified in the header:
%   e.g. 
%      [data,num_channels,sampling_rate,scan_order,points] ...
%         = nptReadStreamerFile('annie04240101.0057',5);
%   will read the data file in assuming there are 5 channels. A
%   warning will still be printed out on the screen if the number
%   of data points is not a multiple of NUM_CHANNELS.
%
%	Dependencies: nptParseStreamerHeader.
%
%   See also: nptReshapeData.

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

% check for presence of optional argument NUM_CHANNELS
if nargin==2
   num_channels = varargin{1};
end

[data,count]=fread(fid, [num_channels,inf], 'int16');

% sometimes num_channels is wrong in the header and as a result some points
% are truncated because Matlab tries to return an even sized matrix. So we 
% want to check to make sure count is a multiple of num_channels
extraPts = rem(count,num_channels);
if extraPts~=0
	fprintf('Warning: Uneven number of data points across channels\n')
	padPts = num_channels-extraPts;
	% read the data in again but this time in 1 row so we get everything
	clear data
	frewind(fid);
	fseek(fid,fpos,'bof');
	[data,count] = fread(fid, [1,inf], 'int16');
	% now pad the number of points to make it a multiple of num_channels
	data = [data zeros(1,padPts)];
	% now reshape data into num_channels
	points = (count+padPts)/num_channels;
	data = reshape(data,num_channels,points);
else
	points = count/num_channels;
end

fclose(fid);
