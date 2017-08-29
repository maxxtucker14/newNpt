function type = DaqType(filename)
%type = DaqType(filename)
%
%type is returned as a string.
%The 3 choices are:
%           UEI
%           Streamer
%           unknown
%
%The program queries the headersize to determine
%the type of file.
%This function only works with *.bin files so far.

%Open Raw data file
fid = fopen(filename,'r','ieee-le');

%Read Header
headerSize = fread(fid,1,'int32');

%Close File
s = fclose(fid);

if headerSize== 90
    type = 'UEI';
elseif headerSize == 73
    type = 'Streamer';
else
    type = 'unknown';
end
