% function [iniInfo, status] = ReadRevCorrIni(filename)
%
% Reads an .ini file written by Presenter to determine revelant
% parameters about the session.  The structure iniInfo is returned
% with fields assigned according to the type of session.
%
% STATUS indicates that the .ini file has a "[TReverseCorrGUIForm]" or
% "[STIMULUS INFO]" section. STATUS == 0 indicates a problem with the file.
%
% modified 8/29/01 by BAO to read each line using fgetl, which is more
% robust to linefeeds/control-M's

% modified to use sscanf instead of strread since strread is not available in 
% Matlab 5
% 3/28/02 added receptive field information
% 05/07/03 added info to deal with new free viewing code, thus the "Read Rev Corr" name
% 06/01/04 added read_init_info.m functionality such that any monkey .ini file can be read.



function [iniInfo, status] = ReadRevCorrIni(filename)

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
                end
            end
            line = fgetl(fid);
		end
        
    elseif strcmp(line,'[STIMULUS INFO]')
        %As of 2003, this section is only present in eye calibration files; however, 
        %prior to that time it was used like the [TReverseCorrGUIForm] section is now.
        status = 1;
        line = fgetl(fid);
        textstring = sscanf(line,'%*[^=]=%[^\n]');
        %The contents of this field differ depending on the type of session, with 3 possibilities present:
        %Sparse Noise/M-Sequence, Movie, or Eye Calibration
        if strcmp(textstring,'TRIAL_SPARSE-NOISE') | strcmp(textstring,'SPARSE-NOISE') | strcmp(textstring,'M-SEQUENCE')
            if strcmp(textstring,'TRIAL_SPARSE-NOISE') | strcmp(textstring,'SPARSE-NOISE')
                iniInfo.type = 'Sparse Noise';
            elseif strcmp(textstring,'M-SEQUENCE')
                iniInfo.type = 'M-Sequence';
            end
            iniInfo.oldMonkey = 1;
            iniInfo.win_movie = 0;
            iniInfo.still_images = 0;
            line = fgetl(fid);
            while ~isempty(line)
                fieldName = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch fieldName
                    case 'Rows'
                        iniInfo.grid_rows = str2num(value);
                    case 'Cols'
                        iniInfo.grid_cols = str2num(value);
                    case 'Number of Colors'
                        iniInfo.num_colors = str2num(value);
                    case 'Spontaneous Trials Per Block'
                        if str2num(value)
                            iniInfo.spon_activity = 1;
                            iniInfo.spon_refreshes = str2num(value);
                        else
                            iniInfo.spon_activity = 0;
                            iniInfo.spon_refreshes = 0;
                        end
                    case 'Object Type'
                        iniInfo.obj_type = value;
                    case 'Number of Orientations'
                        iniInfo.num_orientations = str2num(value);
                    case 'Bar Length'
                        iniInfo.obj_length = str2num(value);
                    case 'Bar Width'
                        iniInfo.obj_width = str2num(value);
                    case 'Random Type'
                        iniInfo.random = value;
                    case 'Repeat Blocks'
                        if strcmp(value, 'NO_REPEAT')
                            iniInfo.repeat_blocks = 0;
                        else
                            iniInfo.repeat_blocks = 1;
                        end
                    case 'Number of Blocks'
                        iniInfo.num_blocks = str2num(value);
                    case 'Grid Center'
                        center = sscanf(value,'%d,%d');
                        iniInfo.grid_x_center = center(1);
                        iniInfo.grid_y_center = center(2);
                    case 'Grid X Size'
                        iniInfo.grid_x_size = str2num(value);
                    case 'Grid Y Size'
                        iniInfo.grid_y_size = str2num(value);
                    case 'Contrast'
                        contrast = str2num(value);
                        iniInfo.on_contrast = contrast;
                        iniInfo.off_contrast = contrast;
                    case 'Fixation Location X'
                        iniInfo.fix_location_x = str2num(value);
                    case 'Fixation Location Y'
                        iniInfo.fix_location_y = str2num(value);
                    case 'Directions per Orientation'
                        iniInfo.dir_per_orientation = str2num(value);
                    case 'Grating Diameter'
                        iniInfo.obj_diameter = str2num(value);
                    case 'Velocity'
                        iniInfo.velocity = str2num(value);
                    case 'Spatial Frequency'
                        iniInfo.spatial_freq = str2num(value);
                    case 'ISI'
                        iniInfo.isi = str2num(value);
                    case 'Number of Trials'
                        iniInfo.num_trials = str2num(value);
                    case 'Trial Separation (frames)'
                        iniInfo.trial_separation = str2num(value);
                    case 'Background Luminance'
                        bLum = str2num(value);
                        iniInfo.background_luminance = bLum;
                        iniInfo.on_luminance = (bLum * contrast/100) + bLum;
                        iniInfo.off_luminance = (bLum * contrast/100) - bLum;
                    case 'Refreshes Per Frame'
                        iniInfo.refreshes_per_frame = str2num(value);
                    case 'Monitor Refresh Rate'
                        iniInfo.refresh_rate = str2num(value);
                    case 'Frames Displayed'
                        if strcmp(iniInfo.type, 'Sparse Noise')
                            iniInfo.SNframes = str2num(value);
                        else
                            iniInfo.m_seq_frames = str2num(value);
                        end
                end %switch
                line=fgetl(fid);
            end %while
            
        elseif strcmp(textstring,'WINDOW_MOVIE') | strcmp(textstring,'MOVIE')
            iniInfo.type = 'Movie';
            if strcmp(textstring,'WINDOW_MOVIE')
                iniInfo.win_movie = 1;
            else
                iniInfo.win_movie = 0;
            end
            line = fgetl(fid);
            iniInfo.oldMonkey = 1;
            iniInfo.still_images = 0;
            while ~isempty(line)
                fieldName = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch fieldName
                    case 'Movie type'
                        if strcmp(value,'still_image')
                            iniInfo.still_images = 1;
                        end
                    case 'Movie Filename'
                        [iniInfo.stimulus_path iniInfo.stimulus_root iniInfo.stimulus_ext] = fileparts(value);
                    case 'Frame Rows'
                        iniInfo.frame_rows = str2num(value);
                    case 'Frame Cols'
                        iniInfo.frame_cols = str2num(value);
                    case 'Movie Frames'
                        iniInfo.movie_frames = str2num(value);
                    case 'Start Frame'
                        iniInfo.start_frame = str2num(value);
                    case 'End Frame'
                        iniInfo.end_frame = str2num(value);
                    case 'Grid Center'
                        center = sscanf(value,'%d,%d');
                        iniInfo.grid_x_center = center(1);
                        iniInfo.grid_y_center = center(2);
                    case 'Grid X Size'
                        iniInfo.grid_x_size = str2num(value);
                    case 'Grid Y Size'
                        iniInfo.grid_y_size = str2num(value);
                    case 'Number of Trials'
                        iniInfo.num_trials = str2num(value);
                    case 'Trial Separation (frames)'
                        iniInfo.trial_separation = str2num(value);
                    case 'Background Luminance'
                        iniInfo.background_luminance = str2num(value);
                    case 'Refreshes Per Frame'
                        iniInfo.refreshes_per_frame = str2num(value);
                    case 'Monitor Refresh Rate'
                        iniInfo.refresh_rate = str2num(value);
                    case 'Frames Displayed'
                        iniInfo.frames_displayed = str2num(value);
                end 
                line=fgetl(fid);
            end 
            
        elseif strcmp(textstring,'Eye Calibration')
            iniInfo.type = 'Calibration';
            iniInfo.win_movie = 0;
            line = fgetl(fid);
            while ~isempty(line)
                fieldName = sscanf(line,'%[^=]');
                value = sscanf(line,'%*[^=]=%[^\n]');
                switch fieldName
                    case 'Grid Rows'
                        iniInfo.GridRows = str2num(value);
                    case 'Grid Cols'
                        iniInfo.GridCols = str2num(value);
                    case 'X Size'          
                        iniInfo.Xsize = str2num(value);
                    case 'Y Size'
                        iniInfo.Ysize = str2num(value);                       
                    case 'Center X'
                        iniInfo.CenterX = str2num(value);
                    case 'Center Y'
                        iniInfo.CenterY = str2num(value);
                    case 'Number of Blocks'
                        iniInfo.NumBlocks = str2num(value); 
                end
                line=fgetl(fid);
            end
        end % which type of [STIMULUS INFO]
        
    elseif strcmp(line,'[TReverseCorrGUIForm]')
        %For a while in 2003, many of these subfields were numeric; thus
        %the need for all of the "if" logic that is no longer necessary.
        
        status = 1;
        
	    line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line, '%[^=]');
            value = sscanf(line, '%*[^=]=%[^\n]');
            switch fieldName
                case 'Reverse Corr Type'
                    if str2num(value) == 0
                        iniInfo.type = 'M-Sequence';
                    elseif str2num(value) == 1
                        iniInfo.type = 'Sparse Noise';
                    elseif str2num(value) == 2
                        iniInfo.type = 'Movie';
                    else
                        iniInfo.type = value;
                    end
                case 'Matrix'
                    if str2num(value) == 0
                        iniInfo.m_seq_size = '16x16';
                    elseif str2num(value) == 1
                        iniInfo.m_seq_size = '64x64';
                    else
                        iniInfo.m_seq_size = sscanf(value,'%dx%d');
                    end
				case {'Mseq Stimulus Frames', 'Number of Frames'}    %(Old Name)
					iniInfo.m_seq_frames = str2num(value);
                case 'Number of Columns'
                    iniInfo.grid_cols = str2num(value);
                case 'Number of Rows'
                    iniInfo.grid_rows = str2num(value);
                case {'Number of Colors', 'Object Colors'}           %(Old Name)
                    iniInfo.num_colors = str2num(value);
                case 'Number of Orientations'
                    iniInfo.num_orientations = str2num(value);
                case 'Directions per Orientation Index'
                    Ori = 1;
                    %This information is only important in determining whether or not the 
                    %"Directions per Orientation subfield is zero-based or
                    %not.  (If it is present, the next subfield is one-based.)
				case 'Directions per Orientation'
                    if exist('Ori')
                        iniInfo.dir_per_orientation = str2num(value);
                    else
                        iniInfo.dir_per_orientation = str2num(value) + 1;
                    end
                case {'Orientation Angle', 'Base Orientation Angle'}     %(Old Name)
                    iniInfo.orientation_angle = str2num(value);
				case 'Random Order'
                    if str2num(value) == 0
                        iniInfo.random = 'Pseudo-Random';
                    elseif str2num(value) == 1
                        iniInfo.random = 'Blocked-Orientation';
                    elseif str2num(value) == 2
                        iniInfo.random = 'Sequential';
                    else
                        iniInfo.random = value;
                    end
                case 'Number of Blocks'
                    iniInfo.num_blocks = str2num(value);
				case 'Repeat Blocks'
                    iniInfo.repeat_blocks = str2num(value);
				case 'Contrast Polarity'
                    if str2num(value) == 0
                        iniInfo.contrast_polarity = 'On/Off';
                    elseif str2num(value) == 1
                        iniInfo.contrast_polarity = 'On';
                    elseif str2num(value) == 2
                        iniInfo.contrast_polarity = 'Off';
                    else
                        iniInfo.contrast_polarity = value;
                    end
                case 'Object Type'
                    if str2num(value) == 0
                        iniInfo.obj_type = 'Bar';
                    elseif str2num(value) == 1
                        iniInfo.obj_type = 'Gabor';
                    elseif str2num(value) == 2
                        iniInfo.obj_type = 'Spot';
                    elseif str2num(value) == 3
                        iniInfo.obj_type = 'Grating';
                    elseif str2num(value) == 4
                        iniInfo.obj_type = 'Square';
                    else
                        iniInfo.obj_type = value;
                    end
                case 'Object Length'
                    iniInfo.obj_length = str2num(value);
                case 'Object Width'
                    iniInfo.obj_width = str2num(value);
				case 'Object Diameter'
                    iniInfo.obj_diameter = str2num(value);	
                case 'Spatial Frequency'
                    iniInfo.spatial_freq = str2num(value);
                case 'Velocity'
                    iniInfo.velocity = str2num(value);
				case 'Temporal Frequency'
                    iniInfo.temporal_freq = str2num(value);
				case 'ISI'
                    iniInfo.isi = str2num(value);	
				case 'Spontaneous Activity'
                    iniInfo.spon_activity = str2num(value);
				case 'Spontaneous Refreshes'
                    iniInfo.spon_refreshes = str2num(value);
                case 'Total Frames'     %Minimum number of Sparse noise frames in stimulus
                    iniInfo.SN_frames = str2num(value);
                case 'Duration in Frames'   %Duration of a grating stimulus in frames
                    iniInfo.end_frame = str2num(value);
				case 'Movie Filename'
                    [iniInfo.stimulus_path iniInfo.stimulus_root iniInfo.stimulus_ext] = fileparts(value);
                case 'Frames In Movie'
                    iniInfo.movie_frames = str2num(value);
                case 'Movie Frame Rows'
                    iniInfo.frame_rows = str2num(value);
                case 'Movie Frame Cols'
                    iniInfo.frame_cols = str2num(value);
                case 'Start Frame'
                    iniInfo.start_frame = str2num(value);
                case 'End Frame'
                    iniInfo.end_frame = str2num(value);
				case 'Frames'		%this will be less than, or an integer multiple of, stimFrames
                    iniInfo.frames_displayed = str2num(value);
				case {'StimFrames', 'Stimulus Frames'}	%length of movie being shown:  start - end
                    iniInfo.stim_frames = str2num(value);
				case 'Data Start Position'
                    iniInfo.data_start_position = str2num(value);
				case 'Number Of Repeats'
                    iniInfo.num_mov_repeats = str2num(value);
				case 'Monitor Eye Position'
                    iniInfo.monitor_eye_pos = str2num(value);
				case 'Windowed Movie'
                    iniInfo.win_movie = str2num(value);
				case 'Still Images'
                    iniInfo.still_images = str2num(value);
                case 'Play Continuously'
                    iniInfo.play_cont = str2num(value);
                case 'Number Of Trials' %This number is unreliable; it will be noted later.
                    iniInfo.num_trials = [];
				case 'Fix Spot Size'
                    iniInfo.fix_spot_size = str2num(value);
                case 'Fix Spot Luminance'
                    iniInfo.fix_spot_luminance = str2num(value);
                case 'Fix Window Size'
                    iniInfo.fix_window_size = str2num(value);
                case 'Fix Position X'
                    iniInfo.fix_location_x = str2num(value);
                case 'Fix Position Y'
                    iniInfo.fix_location_y = str2num(value);
                case 'X Grid Center'
                    iniInfo.grid_x_center = str2num(value);
                case 'Y Grid Center'
                    iniInfo.grid_y_center = str2num(value);
                case 'X Grid Size'
                    iniInfo.grid_x_size = str2num(value);
                case 'Y Grid Size'
                    iniInfo.grid_y_size = str2num(value);
                case 'Refreshes Per Frame'
                    iniInfo.refreshes_per_frame = str2num(value);
                case 'Background Luminance'
                    iniInfo.background_luminance = str2num(value);
                case 'On Luminance'
                    iniInfo.on_luminance = str2num(value);
                case 'Off Luminance'
                    iniInfo.off_luminance = str2num(value);
				case 'On Contrast'
                    iniInfo.on_contrast = str2num(value);
                case 'Off Contrast'
                    iniInfo.off_contrast = str2num(value);
                case 'Trial Repeats'
                    iniInfo.trial_repeats = str2num(value);
                case 'Screen Resolution'
                    res = sscanf(value,'%dx%d %dHz');
                    if res == 6
                        iniInfo.resolution = [800;600];
                    else
                        iniInfo.resolution = res(1:2);
                    end
                    if length(res) > 2
                        iniInfo.refresh_rate = res(3);
                    end
             end
            line = fgetl(fid);
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
            case {'Post Stimulus Duration', 'PostStimulus Duration'}
                iniInfo.PostStimulusDuration = str2num(value);
            end
            line = fgetl(fid);
        end
        
    elseif strcmp(line,'[STIMULUS SEQUENCE]')
        numTrials = iniInfo.GridRows * iniInfo.GridCols * iniInfo.NumBlocks;
        for ind = 1:numTrials
            iniInfo.StimulusSequence(ind) = sscanf(fgetl(fid),'%*[^=]=%d');
        end
		
    elseif strcmp(line,'[TRIAL INFO]')
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line,'%[^=]');
            value = sscanf(line,'%*[^=]=%[^\n]');
            switch fieldName
            case 'Number Trials'
                iniInfo.num_trials = [];
            case 'SN Block Length'
                iniInfo.SNframes = str2num(value) * iniInfo.num_blocks;
            end
            line = fgetl(fid);
        end
        
    elseif strcmp(line,'[OBJECT INFO]')
    	line = fgetl(fid);
        while ~isempty(line)
            textstring = sscanf(line,'%[^=]');
            OriNum = str2num([textstring(end - 1) textstring(end)]);
            if ~isempty(OriNum)
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.orientation_angles(OriNum + 1) = value;
			end
            line = fgetl(fid);
        end
		if ~isfield(iniInfo, 'SNframes') & isfield(iniInfo, 'grid_cols')
            iniInfo.SNframes = iniInfo.grid_cols * iniInfo.grid_rows * iniInfo.num_colors * iniInfo.num_orientations * iniInfo.dir_per_orientation * iniInfo.num_blocks;
        end
        
    elseif strcmp(line,'[EXTRA SYNCS]')
    	line = fgetl(fid);
		while ~isempty(line)
			textstring = sscanf(line,'%[^=]');
			if strcmp(textstring,'Total extra syncs')
				value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
           		iniInfo.extra_syncs = value;
			end
        	line = fgetl(fid);
		end
		
    elseif strcmp(line,'[FIRST FRAMES PER TRIAL]')
		line = fgetl(fid);
		while (~isempty(line)) & (line ~= -1)               %In old files, this was the last field
        	ind = str2num(sscanf(line,'%[^=]'));
            value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
            iniInfo.first_frames(ind) = value;
        	line = fgetl(fid);
		end
		
	elseif strcmp(line,'[LAST FRAMES PER TRIAL]')
		line = fgetl(fid);
		while ~isempty(line)
        	ind = str2num(sscanf(line,'%[^=]'));
            value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
            iniInfo.last_frames(ind) = value;
            line = fgetl(fid);
        end
        
    elseif strcmp(line,'[ACTUAL NUMBER OF TRIALS SHOWN]')
        line = fgetl(fid);
        value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
        iniInfo.num_trials = value;
        line = fgetl(fid);
        
    elseif strcmp(line,'[NUMBER OF FRAMES SHOWN PER TRIAL]')
        line = fgetl(fid);
        while line ~= -1
            ind = str2num(sscanf(line,'%[^=]'));
            value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
            iniInfo.trial_frames(ind) = value;
        	line = fgetl(fid);
		end
        if isempty(iniInfo.num_trials)
            iniInfo.num_trials = ind;
        end
	else
       % not something we recognize so break out of loop and exit
       break;
    end % which [ ] 
    
end % while ~eof
fclose(fid);