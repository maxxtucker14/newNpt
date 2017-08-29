function descriptor_info = ReadDescriptor(filename)			
% Reads a descriptor file written by StreamerDescriptor to determine 
% how many channels were recorded, what type of signals they were 
% and what group they belong to.
% 
% descriptor_info is a structure with the following fields:
%
%			number_of_channels
%			sampling_rate
%			data_type
%			gain
%			channel
%			description
%			group
%			state

if nargin==0
  fprintf('must provide filename\n');
  return
end

%open init file
fid=fopen(filename,'rt');
if fid==-1
  errordlg('Desciptor file could not be opened','ERROR')
  return
end

% be default assume file was created by StreamerDescriptor version 1.4
v14 = 1;
% loop through lines of .INI file, copying desired variables by section
eof=0;
while ~eof

    line=fgetl(fid);
            
    if line(1)==-1
        
        eof=1;
        
    else
        % get first word
        word1 = sscanf(line,'%s',1);
        switch word1
        case 'Number'
        	descriptor_info.number_of_channels = sscanf(line,'%*s %*s %*s %i',1);
        case 'Sample'
            % file was created by version 1.3 or before
            v14 = 0;
        case 'Channel'
            if(v14)
            	for j=1:descriptor_info.number_of_channels
            		line = fgetl(fid);
            		descriptor_info.channel(j) = sscanf(line,'%i ',1);        		
            		descriptor_info.group(j) = sscanf(line,'%*i %i',1);
            		descriptor_info.grid(j) = sscanf(line,'%*i %*i %i',1);
            		%descriptor_info.description{j} = sscanf(line,'%*i %*i %*i %s',1);   
                    d = sscanf(line,'%*i %*i %*i %s',1); 
                    descriptor_info.description{j} = sprintf('%c',d);
            		descriptor_info.rfnumber(j) = sscanf(line,'%*i %*i %*i %*s %i',1);
            		descriptor_info.startdepth(j) = sscanf(line,'%*i %*i %*i %*s %*i %i',1);
            		descriptor_info.recdepth(j) = sscanf(line,'%*i %*i %*i %*s %*i %*i %i',1);
            		%descriptor_info.state{j} = sscanf(line,'%*i %*i %*i %*s %*i %*i %*i %s',1);
                    d = sscanf(line,'%*i %*i %*i %*s %*i %*i %*i %s',1);
                    descriptor_info.state{j} = sprintf('%c',d);
            	end
            else
            	for j=1:descriptor_info.number_of_channels
            		line = fgetl(fid);
            		descriptor_info.channel(j) = sscanf(line,'%i ',1);   
                    %descriptor_info.description{j} = sscanf(line,'%*i %s',1);
                    d = sscanf(line,'%*i %s',1); 
                    descriptor_info.description{j} = sprintf('%c',d);
                    descriptor_info.group(j) = sscanf(line,'%*i %*s %i',1);
                    %descriptor_info.state{j} = sscanf(line,'%*i %*s %*i %s',1);
                    d = sscanf(line,'%*i %*s %*i %s',1);
                    descriptor_info.state{j} = sprintf('%c',d);
            		descriptor_info.grid(j) = 0;
            		descriptor_info.rfnumber(j) = -1;
            		descriptor_info.startdepth(j) = 0;
            		descriptor_info.recdepth(j) = 0;
            	end
            end
        end % switchc word1
    end % if line(1)==-1
end % while ~eof

% close file
fclose(fid);
