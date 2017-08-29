function [t,wv] = ReadWaveformsFile(filename,r2g,ru)
%[times,waveforms] = ReadWaveformsFile(filename,r2g,ru)
% 	Read in Waveform file containing spike times and
%   waveforms 
%	[t,wv] = ReadWaveformsFile(FILENAME,r2g,ru) opens FILENAME and 
%	returns the spike times and waveforms
%		t	time of the spike in microseconds (10^-6 seconds)
%           nx1 timestamps
%		wv	32 points representing the spike waveform stored in
%		    millivolts
%           nx4x32 waveforms
%
%	

[num_spikes,cha,headersize] = GetSpikeInfo(filename);  %all cases need this information

if nargin==1    %return all records!!!!!!
    r2g = [1 num_spikes];
    ru = 4;
end

switch(ru)
    case 1  %timestamp list********
        times=ReadTimes(filename,num_spikes,cha,headersize);
        index=findindex(times,r2g);
        t = r2g;
        wv = GetWaves(filename,index,cha,headersize);
        
    case 2  %records list
        wv = GetWaves(filename,r2g,cha,headersize);
        t = GetTimes(filename,r2g,num_spikes,cha,headersize);
        
    case 3  %range of time
        times=ReadTimes(filename,num_spikes,cha,headersize);
        index = find(times>=r2g(1)&times<=r2g(2));
        range = [min(index) max(index)];
        [t,wv]=ReadRecords(filename,range,num_spikes,cha,headersize);
        
    case 4  %range of records!!!!!!
        [t,wv]=ReadRecords(filename,r2g,num_spikes,cha,headersize);
        
    case 5   %just return number of spikes
        t=num_spikes;
        wv=[];
        
    case 6   %just return times
        t=ReadTimes(filename,num_spikes,cha,headersize);
        wv=[];
end

if ~isempty(wv)
    wvs2 = size(wv,2);
    if cha>4 % if using polytrode
        wv = reshape(wv,[32 cha wvs2]);
        wv = permute(wv,[3 2 1]);
    else
        if cha~=4
            z=zeros((4-cha)*32,wvs2);
            wv = [wv;z];
        end
        wv = reshape(wv,[32 4 wvs2]);
        wv = permute(wv,[3 2 1]);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SUBROUTINES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function t=ReadTimes(filename,num_spikes,cha,headersize);  %read all times
fid=fopen(filename,'r','ieee-le');
fseek(fid,headersize+2*num_spikes*cha*32,'bof');   
t = fread(fid,num_spikes,'uint64');
fclose(fid);

function [t,wv] = ReadRecords(filename,range,num_spikes,cha,headersize) %Read all records in range
fid=fopen(filename,'r','ieee-le');
%read waves first
fseek(fid,headersize+(range(1)-1)*(2*cha*32),'bof');      
wv = fread(fid,[cha*32,(range(2)-range(1)+1)],'int16');
%read times
fseek(fid,headersize+2*num_spikes*cha*32+(range(1)-1)*8,'bof');
t=fread(fid,(range(2)-range(1)+1),'uint64');
fclose(fid);

function [num_spikes,channels,headersize] = GetSpikeInfo(filename)  
fid=fopen(filename,'r','ieee-le');
headersize = fread(fid,1,'uint32');	
num_spikes = fread(fid,1,'uint32');
channels = fread(fid,1,'uint8');
fclose(fid);

function wv = GetWaves(filename,index,cha,headersize) 
fid=fopen(filename,'r','ieee-le');
%read waves 
wv(cha*32,length(index))=0;    %alloc space
for i=1:length(index)
    fseek(fid,headersize+(index(i)-1)*(2*cha*32),'bof');     
    wv(:,i) = fread(fid,cha*32,'int16');
end
fclose(fid);

function t = GetTimes(filename,index,num_spikes,cha,headersize) 
fid=fopen(filename,'r','ieee-le');
%read waves 
t(length(index),1)=0;   %alloc space
for i=1:length(index)
    fseek(fid,headersize+2*num_spikes*cha*32+(index(i)-1)*8,'bof');
    t(i,1)=fread(fid,1,'uint64');
end
fclose(fid);
