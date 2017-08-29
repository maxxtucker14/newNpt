%create_fake_spikes
%this program is used to make some fake preprocessed data files
%for the batch display

%the file will have:
%2 eyeposition channels(vertical and horiz)
%8 tetrode signals
%All of the data channels are of the same length sampled at 30kHz
%The millivolt signal is multiplied by 1000 and then
%written as 16 bit integers(shorts).
clear all


%set how many chnnels to create
eye=2;		%max 2
nueron=8;	%max 8 
lfp=2;		%max 2


%new data file name
file_name=('name02290105.xxxx');
%eye file name
eye_file=('tang03280103.xxxx');
%nueron file name
nueronfile='s602.bin';

stopplace=0;

for i=1:5
   eyedata=[];
   nuerondata=[];
   lfpdata=[];
   
   %create trial num
   trialnum=num2strpad(i,4);
   
   %open eye file
   eyefile=strrep(eye_file,'xxxx',trialnum);
   cd('h:\data\tang\032801\03\raw');
   fid=fopen(eyefile,'r');
   	header_size=fread(fid, 1, 'int32');
		num_channels=fread(fid, 1, 'uchar');
   	sampling_rate=fread(fid, 1, 'ulong');
      scan_order=fread(fid,num_channels,'uchar');
      position=ftell(fid);
      junk=fread(fid,header_size-position,'uchar');
      fseek(fid, header_size, 'bof');
   	[eyedata count]=fread(fid, [num_channels,inf], 'short'); 	% read in data and keep track of how many points were read
   	count=count/num_channels;
   fclose(fid);
   
   
   %open raw nueron file
   cd('h:\data\s6');
   fid=fopen(nueronfile,'r');
   	header_size=fread(fid, 1, 'int32');
   	num_channels=fread(fid, 1, 'uchar');
   	sampling_rate=fread(fid, 1, 'ulong');
   	scan_order=fread(fid,num_channels,'uchar');
   	position=ftell(fid);
   	junk2=fread(fid,header_size-position,'uchar');
		fseek(fid, stopplace+header_size, 'bof');
      % read in same amount of data as in eyefile.
      startplace=ftell(fid);
      [nuerondata count]=fread(fid, [num_channels,count], 'short'); 
   	stopplace=ftell(fid);
   	stopplace=stopplace-header_size;
   fclose(fid);
   nuerondata=nuerondata(1:nueron,:);
   size(nuerondata)
   
   %create lfp signals and add to matrix
   t=1/sampling_rate:1/sampling_rate:count/num_channels/sampling_rate;
   lfpdata=sin(2*pi*2*t)+sin(2*pi*65*t)+10*sin(2*pi*.5*t)+.25*sin(2*pi*1000*t)+.25*sin(2*pi*300*t);
   lfpdata=[lfpdata;lfpdata];
   lfpdata=lfpdata(1:lfp,:);
   size(lfpdata)
   
   %cancontonate all three data types together
   data=[eyedata;nuerondata;lfpdata];
     
     
  	%create new file
   filename=strrep(file_name,'xxxx',trialnum)
   cd('h:\data\name\022901\05\raw');
   fid=fopen(filename,'w');
   %write header
   	fwrite(fid,header_size,'int32');
   	fwrite(fid,(eye+nueron+lfp),'uchar');
   	fwrite(fid,30000,'ulong');
      scan_order=[3 4 5 6 7 8 9 10 11 12 13 14]';
      scan_order=scan_order(1:(eye+nueron+lfp));
      fwrite(fid,scan_order,'uchar');
      position=ftell(fid);
      len=length(junk);
      fwrite(fid,junk(len-header_size+position+1:len),'uchar');% we need to start writing the data at header size!!!!
      data_position=ftell(fid)	%should always be 73!!!
      fwrite(fid,data,'short');	
   fclose(fid);
end

    %checking...
   fid=fopen(filename,'r');
   	header_size=fread(fid, 1, 'int32');
   	num_channels=fread(fid, 1, 'uchar');
   	sampling_rate=fread(fid, 1, 'ulong');
   	scan_order=fread(fid,num_channels,'uchar');
   	position=ftell(fid);
   	junk2=fread(fid,header_size-position,'uchar');
      fseek(fid, header_size, 'bof');
      ftell(fid);
      atad=fread(fid, [num_channels,inf], 'short'); 
   %stopplace=ftell(fid);
   %stopplace=stopplace-header_size;
   fclose(fid);
   figure
   size(atad)
   plot(atad(3,:))   