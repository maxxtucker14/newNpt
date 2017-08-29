function nuerongroup_info = GroupSignals (descriptor_info)
%function nuerongroup_info = GroupSignals (descriptor_info)
%JP's extracting algorithm only works for one group at a time so...
%change channels and groups into a more usable form to be used by 
%nptExtractorWrapper

channels=[];
raw_channels=[];
groups=[];
nuerongroup_info=[];
k=0;
for i=1:descriptor_info.number_of_channels
   if (strcmp(descriptor_info.description(i),'electrode') | ...
         strcmp(descriptor_info.description(i),'tetrode') | ...
         strcmp(descriptor_info.description(i),'highpass') | ...
         strcmp(descriptor_info.description(i),'broadband')) & ...
         strcmp(descriptor_info.state(i),'Active')
      k=k+1;
      channels=[channels k];
      raw_channels=[raw_channels i];
      groups=[groups descriptor_info.group(i)];
   end
end

if ~isempty(channels)
   [groups,index]=sort(groups,2);
   for i=1:length(index)
      groups(2,i)=channels(index(i));
      groups(3,i)=raw_channels(index(i));
   end
   smallest_channel=min(groups(2,:));
   
   start=min(groups(1,:));
   finish=max(groups(1,:));
   k=0;
   for group=start:finish		%seperate channels of groups to seperate arrays
      channels=[];
      raw_channels=[];
      for j=1:size(groups,2)
         if groups(1,j)==group
            channels=[channels groups(2,j)];	%Now channels only contains the channels for this group
            raw_channels=[raw_channels groups(3,j)];
         end
      end
      if ~isempty(channels)
         k=k+1;
         nuerongroup_info(k).group=group;
         nuerongroup_info(k).channels=channels;
         nuerongroup_info(k).raw_channels=raw_channels;
      end
   end
end



