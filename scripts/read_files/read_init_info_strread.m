% function init_info=read_init_info(filename)
%
% Reads an init file written by Presenter to determine revelant
% parameters about the session.  The structure init_info is returned
% with fields assigned according to the type of session.
%

% modified 8/29/01 by BAO to read each line using fgetl, which is more
% robust to linefeeds/control-M's


function init_info=read_init_info(filename)

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
            [field_name value]=strread(line,'%s%d','delimiter','=');
            switch field_name{1}
            case 'Screen Width'
                init_info.ScreenWidth = value;
            case 'Screen Height'
                init_info.ScreenHeight = value;
            end
            line=fgetl(fid);
        end
    
    elseif strcmp(line,'[RECEPTIVE FIELDS INFO]')
    
        % information ignored
        line=fgetl(fid);
        while ~isempty(line)
            line=fgetl(fid);
        end

    elseif strcmp(line,'[OBJECT INFO]')
    
        line=fgetl(fid);
        while ~isempty(line)
            textstring=strread(line,'%s','delimiter',' =');
            switch textstring{1}
            case 'Orientation'
                % get bar orientations
                [k angle] = strread(line,'Orientation of Bar %u=%d');
                init_info.bar_orientation(k+1)=angle;
            end
            line=fgetl(fid);
        end
        
    elseif strcmp(line,'[STIMULUS INFO]')
        
        % get type
        line=fgetl(fid);
        textstring=strread(line,'%s','delimiter','=');
        
        if strcmp(textstring{2},'TRIAL_SPARSE-NOISE')
            
            init_info.type = 'sparse_noise';
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
                case 'Grid X Size'
                    init_info.grid_x_size=str2num(textstring{2});
                case 'Grid Y Size'
                    init_info.grid_y_size=str2num(textstring{2});
                case 'Contrast'
                    init_info.contrast=str2num(textstring{2});
                case 'Fixation Location X'
                    init_info.fixation_location_x=str2num(textstring{2});
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
                
        elseif strcmp(textstring{2},'Eye Calibration')
                
            init_info.type = 'Calibration'
            while ~isempty(line)
                switch textstring{1}
                case 'Grid Rows'
                    init_info.GridRows=str2num(textstring{2});
                case 'Grid Cols'
                    init_info.GridCols=str2num(textstring{2});
                case 'X Size'          
                    init_info.Xsize = str2num(textstring{2});
                case 'Y Size'
                    init_info.Ysize = str2num(textstring{2});                       
                case 'Center X'
                    init_info.CenterX =  str2num(textstring{2});
                case 'Center Y'
                    init_info.CenterY =  str2num(textstring{2});
                case 'Number of Blocks'
                    % number of times the entire grid is shown
                    init_info.NumBlocks = str2num(textstring{2}); 
                end
                line=fgetl(fid);
            end
            
        end % which type of stimulus info
        
    elseif strcmp(line,'[TIMING INFO]')
        
        line=fgetl(fid);
        while ~isempty(line)
            texstring=strread(line,'%s','delimiter','=');
            switch textstring{1}
            case 'Stimulus Latency'
                init_info.StimulusLatency = str2num(textstring{2});
            case 'Stimulus Duration'
                init_info.StimulusDuration = str2num(textstring{2});
            case 'PostStimulus Duration'
                init_info.PostStimulusDuration = str2num(textstring{2});
            end
            line=fgetl(line);
        end
        
    elseif strcmp(line,'[STIMULUS SEQUENCE]')
        
        NumberOfTrials = init_info.GridRows*init_info.GridCols*init_info.NumBlocks;
        for j = 1:NumberOfTrials
            textstring=strread(fgetl(fid),'%s','delimiter','=');
            init_info.StimulusSequence(j) = str2num(textstring{2});
        end
        % last thing read, so no extra line

    elseif strcmp(line,'[EXTRA SYNCS]')
    
        line=fgetl(fid);
        textstring=strread(line,'%s','delimiter','=');
        if strcmp(textstring{1},'Total extra syncs')
            init_info.extra_syncs=str2num(textstring{2});
        elseif strcmp(textstring{1},'No extra syncs detected')
            init_info.extra_syncs=0;
        end
        line=fgetl(fid);
        
    elseif strcmp(line,'[FIRST FRAMES PER TRIAL]')
    
        for j = 1:init_info.number_of_trials
            textstring=strread(fgetl(fid),'%s','delimiter','=');
            init_info.frames(j) = str2num(textstring{2});
        end
        % last thing read, so no extra line
        
    end % which [ ] 
    
end % while ~eof

fclose(fid);

if ~isfield(init_info,'type')
  init_info.type='notcalibration';
end
