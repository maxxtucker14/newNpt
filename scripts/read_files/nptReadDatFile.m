function [datdata,total] = nptReadDatFile(filename)
%nptReadDatFile		Read in DAT file containing spike times and waveforms
%	[DATA,TOTAL] = nptReadDatFile(FILENAME) opens FILENAME and 
%	returns the spike times and waveforms in DATA, which is a structure 
%	with the following fields:
%		DATA.time	time of the spike in microseconds (10^-6 seconds)
%		DATA.wave	32 points representing the spike waveform stored in
%					millivolts
%	The total number of extracted spikes is returned in TOTAL.
%	e.g. 
%		[dat,total] = nptReadDatFile('0001.dat');
%
%	Dependencies: None.

fid=fopen(filename,'r','ieee-le');

% fseek to end of file and get the file size
fseek(fid,0,'eof');
% filesize is in bytes
filesize = ftell(fid);
%return to beginning of file
fseek(fid,0,'bof');


fread(fid,2,'int8');	%-1,0
fread(fid,1,'int32');	%0 (32 bit time)
%The number of zeros (num_channels*32) at beginning of file tell how many channels are
%contained in the dat file. 
num_channels=0;
zeros=true;
while zeros
    z=fread(fid,32,'int16');
    if isempty(find(z))
        zeros=true;
        num_channels=num_channels+1;
    else
        zeros=false;
        fseek(fid,-32*2,'cof');
    end
end

headersize=ftell(fid);
% headersize = (2*8/8 + 1*32/8 + 32*16/8*num_channels =  bytes
% divide filesize by headersize bytes and then subtract by 2 to get the
% total number of spikes since the 
% opening header, closing header and the data are all same number of bytes
total = filesize/headersize - 2;
disp(['ReadDatFile: ' num2str(total) ' spikes extracted'])

%read data   
for i=1:total
    fread(fid,2,'int8');	%0,3
    datdata.time(i)=fread(fid,1,'int32');	%latency	time is multiplied by 10^6 (first six numbers are decimals)
    data=fread(fid,[1,num_channels*32],'int16'); %v_help is the extracted spike data points
    datdata.wave(i,:,:)=transpose(reshape(data,[32,num_channels]));
end

%close file   
fclose(fid);
