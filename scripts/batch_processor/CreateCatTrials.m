function CreateCatTrials(infile,outfile,bin_size)
%
%function CreateCatTrials(infile,outfile)
%Creates trial based files from Cat data to be used with npt Software
%
%outfile should be of the form namedatesession 
%for example 'cats702290101' for cats7 on 022901 for session 01.
%
%This program assumes the pwd is the destination and source directory
%The default bin_size is 1800000

if nargin == 2
    bin_size = 500000;
end
%read file to get num_channels
fid = fopen(infile,'r','ieee-le');
if fid==-1
    fprintf('Error opening %s',infile);
end

header_size=fread(fid, 1, 'int32');					% 4 bytes reserved for header size which is 73 bytes
num_channels=fread(fid, 1, 'uchar');				% 1 byte
fclose(fid);

file = dir(infile);
data_points = abs((file.bytes-73)/2/num_channels);
num_trials = ceil(data_points/bin_size);



%Read data from infile
fid = fopen(infile,'r','ieee-le');
if fid==-1
    fprintf('Error opening %s',infile);
end

header_size=fread(fid, 1, 'int32');					% 4 bytes reserved for header size which is 73 bytes
num_channels=fread(fid, 1, 'uchar');				% 1 byte
sampling_rate=fread(fid, 1, 'uint32');				% 4 bytes
scan_order = fread(fid,num_channels,'uchar');	% 1 byte for each channel up to 64 channels
fseek(fid, header_size, 'bof');						

for trial=1:3%num_trials
    
    [data,count]=fread(fid, [num_channels,bin_size], 'int16');
    filename = [outfile '.' num2strpad(trial,4)];
    fprintf('%s\n',filename);
    nptWriteStreamerFile(filename,sampling_rate,data,scan_order);
    
end

fclose(fid);
