%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function descriptor_info = ReadDescriptor(filename)			
%Description:	This function reads a descriptor file written by StreamerDescriptor				
%						to determine how many channels were recorded, what type of signals they were 	
%						and what group they belong to.															
%	descriptor_info is a structure with the following fields:
%			number_of_channels
%			sampling_rate
%			data_type
%			gain
%			channel
%			description
%			group
%			state
%																							
%																														
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [descriptor_info , nuerongroup_info] = ReadDescriptor(filename)
     
   

% parse out text fields between ' ', '=', or carriage returns
[textstrings] = textread(filename, '%s', 'delimiter', ' \n'); 
% loop through the fields captured from .hdr file, look for
% placement of desired variables, copy to integer values
      
i=1;
while i < (size(textstrings,1)-1)
         % deal out text cells to char variables
         [text1] = textstrings{i};
         [text2] = textstrings{i+1};
                 
         %number_of_channels 
         if (strcmp(text1,'of') & strcmp(text2,'Channels'))
            descriptor_info.number_of_channels = str2num( textstrings{i+2} );
        	end

			%sampling_rate
         if (strcmp(text1,'Sample') & strcmp(text2,'Rate(Hz)'))
				descriptor_info.sampling_rate = str2num( textstrings{i+2} );
         end

			%data_type
         if (strcmp(text1,'Data') & strcmp(text2,'Type'))
				descriptor_info.data_type =  textstrings{i+2};
         end
         %Gain
         if (strcmp(text2,'Gain'))
				descriptor_info.gain =  textstrings{i+2};
         end
         
         if (strcmp(text2,'State'))
   			table_index=i+2;
			end

		i = i + 1;
	   clear text1;
   	clear text2;
   
end

%read data table
k=0;
for j=table_index:4:(size(textstrings,1)-1)
   k=k+1;
   descriptor_info.channel(k,1)=str2num(textstrings{j});
   descriptor_info.description{k,1}=textstrings{j+1};
   descriptor_info.group(k,1)=str2num(textstrings{j+2});
   descriptor_info.state{k,1}=textstrings{j+3};
end

