function [iniInfo,status] = ReadEyeCalibIni(filename)


status = 0;

if nargin == 0
    fprintf('must provide filename\n');
    return
end

%open init file
fid = fopen(filename, 'rt');
if fid == -1
    errordlg('The init file for this processed data could not be opened','ERROR')
    return
end

% loop through lines of .INI file, copying desired variables by section
eof = 0;
while ~eof
    
    line = fgetl(fid);
    if line == -1
        eof = 1;
        
    elseif strcmp(line,'[SESSION INFO]')
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line, '%[^=]');		%always put '%' then read until '='
            value = sscanf(line, '%*[^=]=%d/%d/%d');		%* means ignore so ignore up to '=', then match '=' then read number
            switch fieldName
                case 'Date'
                    iniInfo.Date = value;
                case 'Screen Width'
                    iniInfo.ScreenWidth = value;
                case 'Screen Height'
                    iniInfo.ScreenHeight = value;
            end
            line = fgetl(fid);
        end
        
    elseif strcmp(line,'[RECEPTIVE FIELDS INFO]') | strcmp(line,'[RECEPTIVE FIELDS]')
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line, '%[^=]');
            if strcmp(fieldName,'Number of Fields')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.ReceptiveField.numRF = value;
            elseif strcmp(line(1), '{')
                % get RF number
                numRF = sscanf(line, '{%i}', 1) + 1;
                % get field name
                field = sscanf(line, '%*s %[^=]', 1);
                switch field
                    case 'Type'
                        value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                        iniInfo.ReceptiveField.Type(numRF) = value;
                        
                    case 'Pts'
                        value = sscanf(line, '%*[^=]={%d,%d%d,%d%d,%d%d,%d');
                        iniInfo.ReceptiveField.Points(:,numRF) = value;
                        
                    case 'Center X'
                        value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                        iniInfo.ReceptiveField.CenterX(numRF) = value;
                        
                    case 'Center Y'
                        value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                        iniInfo.ReceptiveField.CenterY(numRF) = value;
                        
                    case 'Ori'
                        value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                        iniInfo.ReceptiveField.Ori(numRF) = value;
                end % switch field
            end % if strcmp
            line = fgetl(fid);
        end % while ~isempty(line)   
        
        
        
    elseif strcmp(line,'[STIMULUS INFO]')
        % get type
        line = fgetl(fid);
        textstring = sscanf(line,'%*[^=]=%[^\n]');
        if strcmp(textstring,'Eye Calibration')
            iniInfo.type = 'Calibration';
            
            status = 1;
            
            line = fgetl(fid);
            while ~isempty(line)
                fieldName = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch fieldName
                    case 'Grid Rows'
                        iniInfo.GridRows=str2num(value);
                    case 'Grid Cols'
                        iniInfo.GridCols=str2num(value);
                    case 'X Size'          
                        iniInfo.Xsize = str2num(value);
                    case 'Y Size'
                        iniInfo.Ysize = str2num(value);                       
                    case 'Center X'
                        iniInfo.CenterX =  str2num(value);
                    case 'Center Y'
                        iniInfo.CenterY =  str2num(value);
                    case 'Number of Blocks'
                        % number of times the entire grid is shown
                        iniInfo.NumBlocks = str2num(value); 
                    case 'Fixation Size'
                        iniInfo.fix_size =  str2num(value);
                    case 'Fixation Window Size'
                        iniInfo.fix_window_size =  str2num(value);
                end
                line=fgetl(fid);
            end
        end
        
        
    elseif strcmp(line,'[TIMING INFO]')
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line,'%[^=]');
            value = sscanf(line,'%*[^=]=%[^\n]');
            switch fieldName
                case 'Stimulus Latency'
                    iniInfo.StimulusLatency = str2num(value);
                case 'Stimulus Duration'
                    iniInfo.StimulusDuration = str2num(value);
                case 'Post Stimulus Duration'
                    iniInfo.PostStimulusDuration = str2num(value);
            end
            line = fgetl(fid);
        end    
        
    elseif strcmp(line,'[STIMULUS SEQUENCE]')
        
        NumberOfTrials = init_info.GridRows*init_info.GridCols*init_info.NumBlocks;
        for j = 1:NumberOfTrials
            % textstring=strread(fgetl(fid),'%s','delimiter','=');            
            init_info.StimulusSequence(j) = sscanf(fgetl(fid),'%*[^=]=%d');
        end
        % last thing read, so no extra line  
        
        
    else
        % not something we recognize so break out of loop and exit
        break;
    end % which [ ] 
    
end % while ~eof
status=1;
fclose(fid);