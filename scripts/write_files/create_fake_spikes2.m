%Create very simple fake data for testing
%this program is used to make some fake preprocessed data files
%for the batch display

%the file will have:
%2 eyeposition channels(vertical and horiz)
%8 tetrode signals
%All of the data channels are of the same length sampled at 30kHz
%The millivolt signal is multiplied by 1000 and then
%written as 16 bit integers(shorts).
clear all
close all

%fake_spikes

%new data file name
file_name=('name02290105.0001')


   %eye file name just to copy header
	eye_file=('tang03280103.0001');
   cd('h:\data\tang\032801\03\raw');
   fid=fopen(eye_file,'r');
   	header_size=fread(fid, 1, 'int32');
   	num_channels=fread(fid, 1, 'uchar');
   	sampling_rate=fread(fid, 1, 'ulong');
   	scan_order=fread(fid,num_channels,'uchar');
   	position=ftell(fid);
   	junk2=fread(fid,header_size-position,'uchar');
	   fclose(fid);
   
   
   
   % nueron data
      tt=0:1/sampling_rate:.1;
      noise=.01*sin(2*pi*60*tt);
      %add some spikes
      pspike=.5*ones(1,20);
      nspike=-.5*ones(1,20);
      nuerondata=[noise pspike noise nspike noise pspike noise nspike noise];
      %create 2 channels of this
      data=1000*[nuerondata;nuerondata;nuerondata;nuerondata];		%%%%multiply by 1000 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      size(data)
      plot(data(2,:))

      %create new file
      cd('h:\data\name\022901\05\raw');
   fid=fopen(file_name,'w');
   %write header
   	fwrite(fid,header_size,'int32');
   	fwrite(fid,4,'uchar');
   	fwrite(fid,sampling_rate,'ulong');
   	scan_order=[4 5 6 7]';
      fwrite(fid,scan_order,'uchar');
      position=ftell(fid)
      len=length(junk2)
      fwrite(fid,junk2(len-header_size+position+1:len),'uchar');% we need to start writing the data at header size!!!!
      data_position=ftell(fid)	%should always be 73!!!
      fwrite(fid,data,'short');	
   fclose(fid);
   

   %checking...
   fid=fopen(file_name,'r');
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
   plot(atad(1,:))