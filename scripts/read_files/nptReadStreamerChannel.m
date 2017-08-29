function [data,num_channels,sampling_rate,scan_order,points]=nptReadStreamerChannel(rawfile,channel)
%nptReadStreamerChannel Function to read binary files from Data Streamer
%	[DATA,NUM_CHANNELS,SAMPLING_RATE,SCAN_ORDER,POINTS] 
%			= nptReadStreamerChannel(FILENAME,CHANNEL)
% 	opens the file FILENAME and returns the data for CHANNEL in
%	DATA. The data is in millivolts. NUM_CHANNELS is the number of 
%	channels recorded. SAMPLING_RATE is the sampling rate used in 
%	the data collection in points per second. SCAN_ORDER returns 
%	the channel numbers used during the recording. POINTS returns 
%	the number of data points in each channel.
%	e.g. 
%		[data,num_channels,sampling_rate,scan_order,points] ...
%			= nptReadStreamerChannel('annie04240101.0057',3);
%	reads the data for the 3rd signal from trial 57 of a multi-trial 
%	session.
%	or
%	e.g. 
%		[data,num_channels,sampling_rate,scan_order,points] ...
%			= nptReadStreamerChannel('a101.bin',2);
%	reads the data for the 2nd signal from a single-trial session.
%
%	Dependencies: nptReadStreamerFile.

[all_data,num_channels,sampling_rate,scan_order,points] = nptReadStreamerFile(rawfile);

if points==0
   data = [];
elseif channel<=num_channels
   data = all_data(channel,:);
else
   fprintf('No channel %i. Data file only has %i channels.\n',channel,num_channels);
   data = [];
end
   
