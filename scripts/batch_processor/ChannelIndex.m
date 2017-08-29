function [unitindex ,  bbindex] = ChannelIndex (descriptor_info)
%function [unitindex bbindex] = ChannelIndex (descriptor_info)
%
%Helps combine unit signals from different DAQ types.  
%Do not want to overwrite unit signals with broadband signals
%when combining matrices while still maintaining correct channel
%sequence.  Called by ProcessSession.


unitindex=[];
bbindex=[];


for k=1:descriptor_info.number_of_channels
   if strcmp(descriptor_info.description(k),'electrode') & strcmp(char(descriptor_info.state(k)),'Active')
      unitindex = [unitindex k];
   elseif strcmp(descriptor_info.description(k),'broadband') & strcmp(char(descriptor_info.state(k)),'Active')
      bbindex = [bbindex k];
   end
end

