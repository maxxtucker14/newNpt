function [iniInfo] = ReadOldRevCorrIni(filename)

% Reads an init file written by Presenter to determine revelant
% parameters about the session.  The structure init_info is returned
% with fields assigned according to the type of session.

% Directory specific.

if nargin==0
    fprintf('must provide filename\n');
    return
end

%open init file
fid=fopen(filename,'r');
if fid==-1
    errordlg('The init file for this processed data could not be opened','ERROR')
    return
end

% loop through lines of .INI file, copying desired variables by section
eof=0;
while ~eof
    
    line=fgetl(fid);
    
    if line(1)==-1
        
        eof=1;
        
    elseif strcmp(line,'[SESSION INFO]')
        
        line=fgetl(fid);
        while ~isempty(line)
            field_name = sscanf(line,'%[^=]');
            value = sscanf(line, '%*[^=]=%s');
            switch field_name
                case 'Presenter Version'
                    value = sscanf(line, '%*[^=]=%s');
                    init_info.Presenter_Version = value;                
                case 'Date'
                    init_info.Date = value;
                case 'Time'
                    value = sscanf(line, '%*[^=]=%s');
                    init_info.Time = value;
                case 'Screen Width'
                    init_info.ScreenWidth = str2num(value);
                case 'Screen Height'
                    init_info.ScreenHeight = str2num(value);
            end
            line=fgetl(fid);
        end
        
    elseif strcmp(line,'[RECEPTIVE FIELDS INFO]')           
        line=fgetl(fid);
        while ~isempty(line)
            field_name = sscanf(line,'%[^=]');
            value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
            switch field_name
                case 'Number of Fields'
                    init_info.ReceptiveField.numRF = value;
                    for numRF=1:value
                        line=fgetl(fid);
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.Type(numRF) = value;
                        
                        line=fgetl(fid);
                        value = sscanf(line,'%*[^=]={%d,%d%d,%d%d,%d%d,%d');
                        init_info.ReceptiveField.Points(:,numRF) = value;
                        
                        line=fgetl(fid);
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.CenterX(numRF) = value;
                        
                        line=fgetl(fid);
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.CenterY(numRF) = value;
                        
                        line=fgetl(fid);
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.Ori(numRF) = value;
                    end % for
            end % case
            line=fgetl(fid); %After reading the RF info, look at the next line, should quit the while loop if next line is blank.
        end % while
        
        
    elseif strcmp(line,'[OBJECT INFO]')
        
        line=fgetl(fid);
        angleCount=1;
        while ~isempty(line)
            textstring=strread(line,'%s','delimiter',' =');
            switch textstring{1}
                case 'Orientation'
                    % get bar orientations
                    value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                    init_info.bar_orientation(angleCount)=value;
                    angleCount = angleCount+1;
            end
            line=fgetl(fid);
        end    
        
        
    elseif strcmp(line,'[STIMULUS INFO]')
        
        % get type
        line=fgetl(fid);
        textstring=strread(line,'%s','delimiter','=');        
        if strcmp(textstring{2},'SPARSE-NOISE')
            init_info.type = 'sparse_noise';
            file = strrep(filename,'ini','seq');
            %init_info.seq = read_seq(file);
            line=fgetl(fid);
            while ~isempty(line)
                textstring=strread(line,'%s','delimiter','=');
                switch textstring{1}
                    case 'Sequence File'
                        init_info.stimulus_path=textstring{2};
                    case 'Rows'
                        init_info.rows=str2num(textstring{2});
                    case 'Cols'
                        init_info.cols=str2num(textstring{2});
                    case 'Number of Colors'
                        init_info.num_colors=str2num(textstring{2});
                    case 'Number of Orientations'
                        init_info.num_orientations=str2num(textstring{2});
                    case 'Bar Length'
                        init_info.bar_length=str2num(textstring{2});
                    case 'Bar Width'
                        init_info.bar_width=str2num(textstring{2});
                    case 'Number of Blocks'
                        init_info.num_blocks=str2num(textstring{2});
                    case 'Grid Center'
                        init_info.grid_center=...
                            strread(textstring{2},'%d','delimiter',',');
                        value = strread(textstring{2},'%d','delimiter',',');
                        init_info.grid_x_center = value(1);     
                        init_info.grid_y_center = value(2); 
                    case 'Grid X Size'
                        init_info.grid_x_size=str2num(textstring{2});
                    case 'Grid Y Size'
                        init_info.grid_y_size=str2num(textstring{2});
                    case 'Contrast'
                        init_info.contrast=str2num(textstring{2});
                    case 'Fixation Location X'
                        init_info.fixation_location_x=str2num(textstring{2});
                    case 'Spontaneous Trials Per Block'
                        init_info.spontaneous_trials=str2num(textstring{2});
                    case 'Contrast Polarity'
                        init_info.contrast_polarity=str2num(textstring{2});
                    case 'Object Type'
                        init_info.obj_type=(textstring{2});
                    case 'Directions per Orientation'
                        init_info.directions_per_orientation=str2num(textstring{2});
                    case 'Grating Diameter'
                        init_info.grating_diameter=str2num(textstring{2});
                    case 'Velocity'
                        init_info.velocity=str2num(textstring{2}); 
                    case 'Spatial Frequency'
                        init_info.spatial_frequency=str2num(textstring{2});
                    case 'ISI'
                        init_info.inter_stimulus_interval=str2num(textstring{2});
                    case 'Random Type'
                        init_info.random_type=(textstring{2});
                    case 'Repeat Blocks'
                        init_info.repeat_blocks=(textstring{2});
                    case 'Number of Blocks'
                        init_info.number_of_blocks=str2num(textstring{2});
                    case 'Fixation Location Y'
                        init_info.fixation_location_y=str2num(textstring{2});
                    case 'Number of Trials'
                        init_info.number_of_trials=str2num(textstring{2});
                    case 'Trial Separation (frames)'
                        init_info.trial_separation=str2num(textstring{2});
                    case 'Background Luminance'
                        init_info.background_luminance=str2num(textstring{2});
                    case 'Refreshes Per Frame'
                        init_info.refreshes_per_frame=str2num(textstring{2});
                    case 'Monitor Refresh Rate'
                        init_info.refresh_rate=str2num(textstring{2});
                    case 'Frames Displayed'
                        init_info.frames_displayed=str2num(textstring{2});
                end %switch
                line=fgetl(fid);
            end %while
            
            
        elseif strcmp(textstring{2},'M-SEQUENCE')
            
            init_info.type = 'm_sequence';
            line=fgetl(fid);
            
            while ~isempty(line)
                textstring=strread(line,'%s','delimiter','=');
                switch textstring{1}
                    case 'M-Sequence File'
                        init_info.stimulus_path=textstring{2};
                        if ~isempty(findstr('mat16','16'))
                            init_info.m_seq_size= '16x16 (order=16)';
                        else
                            init_info.m_seq_size= '64x64 (order=16)';
                        end
                    case 'Grid Center'
                        init_info.grid_center=...
                            strread(textstring{2},'%d','delimiter',',');
                        value = strread(textstring{2},'%d','delimiter',',');
                        init_info.grid_x_center = value(1);     
                        init_info.grid_y_center = value(2); 
                    case 'Grid X Size'
                        init_info.grid_x_size=str2num(textstring{2});
                    case 'Grid Y Size'
                        init_info.grid_y_size=str2num(textstring{2});
                    case 'Contrast'
                        init_info.contrast=str2num(textstring{2});
                    case 'Background Luminance'
                        init_info.background_luminance=str2num(textstring{2});
                    case 'Refreshes Per Frame'
                        init_info.refreshes_per_frame=str2num(textstring{2});
                    case 'Frames Displayed'
                        init_info.frames_displayed=str2num(textstring{2});
                end %switch
                line=fgetl(fid);
            end %while
            
        elseif strcmp(textstring{2},'WINDOW_MOVIE')
            
            init_info.type = 'Movie';           
            line=fgetl(fid);
            textstring=strread(line,'%s','delimiter','=');
            if strcmp(textstring{1},'Movie type')
                init_info.movie_type=textstring{2};
                line=fgetl(fid);
            else
                init_info.movie_type='movie';
            end
            
            while ~isempty(line)
                textstring=strread(line,'%s','delimiter','=');
                switch textstring{1}
                    case 'Movie Filename'
                        init_info.stimulus_path=textstring{2};
                        [init_info.stimulus_root init_info.stimulus_ext]=...
                            fileparts(textstring{2});
                    case 'Frame Rows'
                        init_info.frame_rows=str2num(textstring{2});
                    case 'Frame Cols'
                        init_info.frame_cols=str2num(textstring{2});
                    case 'Movie Frames'
                        init_info.movie_frames = str2num(textstring{2});
                    case 'Start Frame'
                        init_info.start_frame = str2num(textstring{2});
                    case 'End Frame'
                        init_info.end_frame = str2num(textstring{2});
                    case 'Grid Center'
                        center=strread(textstring{2},'%d','delimiter',',');
                        init_info.x_center=center(1);
                        init_info.y_center=center(2);
                    case 'X Size'
                        init_info.x_size = str2num(textstring{2});
                    case 'Y Size'
                        init_info.y_size = str2num(textstring{2});
                    case 'Number of Trials'
                        init_info.number_of_trials = str2num(textstring{2});
                    case 'Trial Separation (frames)'
                        init_info.trial_separation = str2num(textstring{2});
                    case 'Background Luminance'
                        init_info.background_luminance = str2num(textstring{2});
                    case 'Refreshes Per Frame'
                        init_info.refreshes_per_frame = str2num(textstring{2});
                    case 'Monitor Refresh Rate'
                        init_info.refresh_rate = str2num(textstring{2});
                    case 'Frames Displayed'
                        init_info.frames_displayed = str2num(textstring{2});
                end %switch
                line=fgetl(fid);
            end %while
            
        elseif strcmp(textstring{2},'MOVIE')
            
            init_info.type = 'Movie';
            line=fgetl(fid);
            
            textstring=strread(line,'%s','delimiter','=');
            if strcmp(textstring{1},'Movie type')
                init_info.movie_type=textstring{2};
                line=fgetl(fid);
            else
                init_info.movie_type='movie';
            end
            
            while ~isempty(line)
                textstring=strread(line,'%s','delimiter','=');
                switch textstring{1}
                    case 'Movie Filename'
                        init_info.stimulus_path=textstring{2};
                        [init_info.stimulus_root init_info.stimulus_ext]=...
                            fileparts(textstring{2});
                    case 'Frame Rows'
                        init_info.frame_rows=str2num(textstring{2});
                    case 'Frame Cols'
                        init_info.frame_cols=str2num(textstring{2});
                    case 'Movie Frames'
                        init_info.movie_frames = str2num(textstring{2});
                    case 'Start Frame'
                        init_info.start_frame = str2num(textstring{2});
                    case 'End Frame'
                        init_info.end_frame = str2num(textstring{2});
                    case 'Grid Center'
                        center=strread(textstring{2},'%d','delimiter',',');
                        init_info.x_center=center(1);
                        init_info.y_center=center(2);
                    case 'X Size'
                        init_info.x_size = str2num(textstring{2});
                    case 'Y Size'
                        init_info.y_size = str2num(textstring{2});
                    case 'Number of Trials'
                        init_info.number_of_trials = str2num(textstring{2});
                    case 'Trial Separation (frames)'
                        init_info.trial_separation = str2num(textstring{2});
                    case 'Background Luminance'
                        init_info.background_luminance = str2num(textstring{2});
                    case 'Refreshes Per Frame'
                        init_info.refreshes_per_frame = str2num(textstring{2});
                    case 'Monitor Refresh Rate'
                        init_info.refresh_rate = str2num(textstring{2});
                    case 'Frames Displayed'
                        init_info.frames_displayed = str2num(textstring{2});
                end %switch
                line=fgetl(fid);
            end %while     
            
        end % which type of stimulus info
        
    elseif strcmp(line,'[EXTRA SYNCS]')
        
        line=fgetl(fid);
        textstring=strread(line,'%s','delimiter','=');
        if strcmp(textstring{1},'Total extra syncs')
            init_info.extra_syncs=str2num(textstring{2});
        elseif strcmp(textstring{1},'No extra syncs detected')
            init_info.extra_syncs=0;
        end
        line=fgetl(fid);
        
        
    end % which [ ] 
    
end % while ~eof
fclose(fid);

iniInfo = init_info;