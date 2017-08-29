function CreateChannelFile(channel)
%function CreateChannelFile(channel)
%this function assumes the pwd is the session directory.
%A file is created from the raw spike data from a single channel.


dirlist = nptdir('*.0*');

[p,n,e,v]=fileparts(dirlist(1).name);
filename=[n 'channel' num2str(channel) '.raw'];
fid = fopen(filename,'w');

for i=1:length(dirlist)
   
   [data,num_channels,sampling_rate,scan_order,points]=nptReadStreamerFile(dirlist(i).name);
   data=data(channel,:);
   fwrite(fid,data,'integer*2');
end

fclose(fid);

