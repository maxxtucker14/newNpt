function totalwaveforms = nptWriteDat(unit_extracted,duration,name,numChannels)
%function totalwaveforms = nptWriteDat(unit_extracted,duration,name,numChannels)

totalwaveforms=0;

% for i=1:size(neurongroup_info,2)	%loop over groups

% datfile=[num2strpad(neurongroup_info(i).group,4) '.dat'];  %create .dat files
datfile = [name '.dat'];
fprintf('Writing datfile: %s   channels: %i\n', datfile,numChannels); 
fid=fopen(datfile,'w','ieee-le');

% prelude. something that is added at the beginning of every dat file.
fwrite(fid,-1,'int8');
fwrite(fid,0,'int8');
fwrite(fid,0,'int32');
buffer  = zeros(1,numChannels*32);
fwrite(fid,buffer,'int16');

%Sorter requires each waveform set to be separated by 0,3 and then the time and then the datapoints for all channels.
%the initial (4*32=128) zeros indicate how much space the data.(tetrodes)            
for j=1:size(unit_extracted,2)	%loop over trials
   for k=1:size(unit_extracted(j).times,1)		%loop over extracted waveforms
      totalwaveforms=totalwaveforms+1;
      fwrite(fid,0,'int8');
      fwrite(fid,3,'int8');
      
      time=unit_extracted(j).times(k,1)+(duration*(j-1))*10^6;
      
      fwrite(fid,time,'int32');
      fwrite(fid,unit_extracted(j).waveforms(k,:),'int16');
   end
end

% POSTLUDE. Something that must be added at the end of every .dat file
fwrite(fid,-1,'int8');
fwrite(fid,1,'int8'); 
fwrite(fid,0,'int32');   
fwrite(fid,buffer,'int16');
fclose(fid); 
% end