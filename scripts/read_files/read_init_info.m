% function init_info=read_init_info(filename)
%
% Reads an init file written by Presenter to determine revelant
% parameters about the session.  The structure init_info is returned
% with fields assigned according to the type of session.
%

% modified 8/29/01 by BAO to read each line using fgetl, which is more
% robust to linefeeds/control-M's

% modified to use sscanf instead of strread since strread is not available in 
% Matlab 5
% 3/28/02 added receptive field information

function [init_info , status] = read_init_info(filename)

if nargin==0
  fprintf('must provide filename\n');
  return
end

%open init file
fid=fopen(filename,'rt');
if fid==-1
  errordlg('The init file for this processed data could not be opened','ERROR')
  return
end

% loop through lines of .INI file, copying desired variables by section
eof=0;
while ~eof

    line=fgetl(fid);
            
    if line==-1
        
        eof=1;
        
    elseif strcmp(line,'[SESSION INFO]')

        line=fgetl(fid);
        while ~isempty(line)
            field_name = sscanf(line,'%[^=]');		%always put '%' then read until '='
            value = sscanf(line,'%*[^=]=%d/%d/%d');		%* means ignore so ignore up to '=', then match '=' then read number
            switch field_name
            case 'Date'
               init_info.Date = value;
            case 'Screen Width'
                init_info.ScreenWidth = value;
            case 'Screen Height'
                init_info.ScreenHeight = value;
            end
            line=fgetl(fid);
        end
    
    elseif strcmp(line,'[RECEPTIVE FIELDS INFO]') | strcmp(line,'[RECEPTIVE FIELDS]')
    
        % information ignored
        line=fgetl(fid);
        while ~isempty(line)
			field_name = sscanf(line,'%[^=]');
            if strcmp(field_name,'Number of Fields')
                value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                init_info.ReceptiveField.numRF = value;
            elseif strcmp(line(1),'{')
                % get RF number
                numRF = sscanf(line,'{%i}',1) + 1;
                % get field name
                field = sscanf(line,'%*s %[^=]',1);
                switch field
                    case 'Type'
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.Type(numRF) = value;
                        
                    case 'Pts'
                        value = sscanf(line,'%*[^=]={%d,%d%d,%d%d,%d%d,%d');
                        init_info.ReceptiveField.Points(:,numRF) = value;
                        
                    case 'Center X'
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.CenterX(numRF) = value;
                        
                    case 'Center Y'
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.CenterY(numRF) = value;
                        
                    case 'Ori'
                        value = str2num(sscanf(line,'%*[^=]=%[^\n]'));
                        init_info.ReceptiveField.Ori(numRF) = value;
                end % switch field
            end % if strcmp
            line = fgetl(fid);
		end % while ~isempty(line)
        
    elseif strcmp(line,'[GABOR CONTOURS INFO]')
        % we don't want it to do anything so break out of loop
        break
        
    elseif strcmp(line,'[OBJECT INFO]')
    
        line=fgetl(fid);
        while ~isempty(line)
           textstring = sscanf(line,'%[^=]');
           if ~isempty(findstr(textstring,'Orientation'))
                % get bar orientations
                % [k angle] = strread(line,'Orientation of Bar %u=%d');
                values = sscanf(line,'Orientation of Bar %u=%f');
                init_info.orientation_angles(values(1)+1)=values(2);
            end
            line=fgetl(fid);
        end
        
    elseif strcmp(line,'[STIMULUS INFO]')
        
        % get type
        line=fgetl(fid);
        % textstring=strread(line,'%s','delimiter','=');
        textstring = sscanf(line,'%*[^=]=%[^\n]');
        
        if strcmp(textstring,'TRIAL_SPARSE-NOISE') | strcmp(textstring,'SPARSE-NOISE') | strcmp(textstring,'M-SEQUENCE')
            if strcmp(textstring,'TRIAL_SPARSE-NOISE') | strcmp(textstring,'SPARSE-NOISE')
                init_info.type = 'sparse_noise';
            elseif strcmp(textstring,'M-SEQUENCE')
                init_info.type = 'm_sequence';
            end
        
            line=fgetl(fid);
            while ~isempty(line)
                % textstring=strread(line,'%s','delimiter','=');
                field_name = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch field_name
                case 'Sequence File'
                    init_info.stimulus_path=value;
                case 'M-Sequence File'
                    init_info.stimulus_path=value;
                case 'Rows'
                    init_info.grid_rows=str2num(value);
                case 'Cols'
                    init_info.grid_cols=str2num(value);
                case 'Number of Colors'
                    init_info.num_colors=str2num(value);
                case 'Number of Orientations'
                    init_info.num_orientations=str2num(value);
                case 'Bar Length'
                    init_info.obj_length=str2num(value);
                case 'Bar Width'
                    init_info.obj_width=str2num(value);
                case 'Number of Blocks'
                    init_info.num_blocks=str2num(value);
                case 'Grid Center'
                    center = sscanf(value,'%d,%d');
                     init_info.grid_x_center = center(1);
                     init_info.grid_y_center = center(2);
                case 'Grid X Size'
                    init_info.grid_x_size=str2num(value);
                case 'Grid Y Size'
                    init_info.grid_y_size=str2num(value);
                case 'Contrast'
                    init_info.contrast=str2num(value);
                case 'Spontaneous Trials Per Block'
                    init_info.spon_activity=str2num(value);
                case 'Contrast Polarity'
                    init_info.contrast_polarity=str2num(value);
                case 'Object Type'
                    init_info.object_type=value;
                case 'Directions per Orientation'
                    init_info.dir_per_orientation=str2num(value);
                case 'Grating Diameter'
                    init_info.obj_diameter=str2num(value);
                case 'Velocity'
                    init_info.velocity=str2num(value); %seq = 2; % Change seq number to 2 so that adjustsyncs will read it as a grating.
                case 'Spatial Frequency'
                    init_info.spatial_frequency=str2num(value);
                case 'ISI'
                    init_info.isi=str2num(value);
                case 'Random Type'
                    init_info.random_type=value;
                case 'Repeat Blocks'
                    init_info.repeat_blocks=value;
                case 'Number of Blocks'
                    init_info.num_blocks=str2num(value);
                case 'Fixation Location X'
                    init_info.fixation_location_x=str2num(value);
                case 'Fixation Location Y'
                    init_info.fixation_location_y=str2num(value);
                case 'Number of Trials'
                    init_info.number_of_trials=str2num(value);
                case 'Trial Separation (frames)'
                    init_info.trial_separation=str2num(value);
                case 'Background Luminance'
                    init_info.background_luminance=str2num(value);
                case 'Refreshes Per Frame'
                    init_info.refreshes_per_frame=str2num(value);
                case 'Monitor Refresh Rate'
                    init_info.refresh_rate=str2num(value);
                case 'Frames Displayed'
                    init_info.frames_displayed=str2num(value);
                end %switch
                line=fgetl(fid);
            end %while
        
            
        elseif strcmp(textstring,'WINDOW_MOVIE') | strcmp(textstring,'MOVIE')
            
            init_info.type = 'Movie';
            line=fgetl(fid);
            % textstring=strread(line,'%s','delimiter','=');
            textstring=sscanf(line,'%[^=]');
            if strcmp(textstring,'Movie type')
                init_info.movie_type=sscanf(line,'%*[^=]=%[^\n]');
                line=fgetl(fid);
            else
                init_info.movie_type='movie';
            end
            
            while ~isempty(line)
                % textstring=strread(line,'%s','delimiter','=');
                field_name = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch field_name
                case 'Movie Filename'
                    [init_info.stimulus_path init_info.stimulus_root init_info.stimulus_ext]=...
                        fileparts(value);
                case 'Frame Rows'
                    init_info.frame_rows=str2num(value);
                case 'Frame Cols'
                    init_info.frame_cols=str2num(value);
                case 'Movie Frames'
                    init_info.movie_frames = str2num(value);
                case 'Start Frame'
                    init_info.start_frame = str2num(value);
                case 'End Frame'
                    init_info.end_frame = str2num(value);
                case 'Grid Center'
                    % center=strread(textstring{2},'%d','delimiter',',');
                     center = sscanf(value,'%d,%d');
                     init_info.x_center = center(1);
                     init_info.y_center = center(2);
                case 'Grid X Size'
                    init_info.x_size = str2num(value);
                case 'Grid Y Size'
                    init_info.y_size = str2num(value);
                case 'Number of Trials'
                    init_info.number_of_trials = str2num(value);
                case 'Trial Separation (frames)'
                    init_info.trial_separation = str2num(value);
                case 'Background Luminance'
                    init_info.background_luminance = str2num(value);
                case 'Refreshes Per Frame'
                    init_info.refreshes_per_frame = str2num(value);
                case 'Monitor Refresh Rate'
                    init_info.refresh_rate = str2num(value);
                case 'Frames Displayed'
                    init_info.frames_displayed = str2num(value);
                end %switch
                line=fgetl(fid);
            end %while
                
        elseif strcmp(textstring,'Eye Calibration')
                
            init_info.type = 'Calibration';
            line = fgetl(fid);
            while ~isempty(line)
            	field_name = sscanf(line,'%[^=]');
            	value = sscanf(line,'%*[^=]=%[^\n]');
                switch field_name
                case 'Grid Rows'
                    init_info.GridRows=str2num(value);
                case 'Grid Cols'
                    init_info.GridCols=str2num(value);
                case 'X Size'          
                    init_info.Xsize = str2num(value);
                case 'Y Size'
                    init_info.Ysize = str2num(value);                       
                case 'Center X'
                    init_info.CenterX =  str2num(value);
                case 'Center Y'
                    init_info.CenterY =  str2num(value);
                case 'Number of Blocks'
                    % number of times the entire grid is shown
                    init_info.NumBlocks = str2num(value); 
                end
                line=fgetl(fid);
            end
            
        end % which type of stimulus info
        
    elseif strcmp(line,'[TIMING INFO]')
        
        line=fgetl(fid);
        while ~isempty(line)
            % texstring=strread(line,'%s','delimiter','=');
            field_name = sscanf(line,'%[^=]');
            value = sscanf(line,'%*[^=]=%[^\n]');
            switch field_name
            case 'Stimulus Latency'
                init_info.StimulusLatency = str2num(value);
            case 'Stimulus Duration'
                init_info.StimulusDuration = str2num(value);
            case 'PostStimulus Duration'
                init_info.PostStimulusDuration = str2num(value);
            end
            line=fgetl(fid);
        end
        
    elseif strcmp(line,'[STIMULUS SEQUENCE]')
        
        NumberOfTrials = init_info.GridRows*init_info.GridCols*init_info.NumBlocks;
        for j = 1:NumberOfTrials
            % textstring=strread(fgetl(fid),'%s','delimiter','=');            
            init_info.StimulusSequence(j) = sscanf(fgetl(fid),'%*[^=]=%d');
        end
        % last thing read, so no extra line

    elseif strcmp(line,'[EXTRA SYNCS]')
    
        line=fgetl(fid);
        field_name = sscanf(line,'%[^=]');
        if strcmp(field_name,'Total extra syncs')
            init_info.extra_syncs=sscanf(line,'%*[^=]=%d');
        elseif strcmp(field_name,'No extra syncs detected')
            init_info.extra_syncs=0;
        end
        line=fgetl(fid);
        
    elseif strcmp(line,'[FIRST FRAMES PER TRIAL]')
    
        for j = 1:init_info.number_of_trials
            value = sscanf(fgetl(fid),'%*[^=]=%d');
            init_info.frames(j) = value;
        end
        % last thing read, so no extra line
        
    else
       % not something we recognize so break out of loop and exit
       break;
    end % which [ ] 
    
end % while ~eof

fclose(fid);

if ~isfield(init_info,'type')
  init_info.type='notcalibration';
end
