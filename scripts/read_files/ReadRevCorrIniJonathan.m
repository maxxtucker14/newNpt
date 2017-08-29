% function [iniInfo, status] = ReadRevCorrIni(filename)
%
% Reads an init file written by Presenter to determine revelant
% parameters about the session.  The structure iniInfo is returned
% with fields assigned according to the type of session.
%
% STATUS indicates whether or not the .ini file had a "[TReverseCorrGUIForm]"
% section, such that if STATUS == 0, you may want to use read_init_info.
%
% modified 8/29/01 by BAO to read each line using fgetl, which is more
% robust to linefeeds/control-M's

% modified to use sscanf instead of strread since strread is not available in
% Matlab 5
% 3/28/02 added receptive field information
% 05/07/03 added info to deal with new free viewing code, thus the "Read Rev Corr" name
% 01/15/04 since windows 2000 does not place a blank line between sections
% a correction for that problem was made.
% a new flag, on line 58 checks for the presenter version and date, if the
% version and date are 2006 and older, than a new ini reader is used.

function [iniInfo, status] = ReadRevCorrIniJonathan(filename)

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
                case 'Presenter Version'
                    value = sscanf(line, '%*[^=]=%s');
                    iniInfo.Presenter_Version = value;
                case 'Date'
                    iniInfo.Date = value;
                    % If the experiment occured during or after 2006, a new
                    % version of presenter was used with a new UEI DAQ.                    %
                    if iniInfo.Date(3) >= 2006
                        iniInfo.Date = 'UEI';
                        status=1;
                        return
                    end
                case 'Time'
                    value = sscanf(line, '%*[^=]=%s');
                    iniInfo.Time = value;
                case 'Screen Width'
                    iniInfo.ScreenWidth = value;
                case 'Screen Height'
                    iniInfo.ScreenHeight = value;
            end

            if strcmp(fieldName,'Screen Height')
                line=[];
            else
                line = fgetl(fid);
            end
        end

    elseif strcmp(line,'[RECEPTIVE FIELDS INFO]') | strcmp(line,'[RECEPTIVE FIELDS]')
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line, '%[^=]');
            field=[];
            if strcmp(fieldName,'Number of Fields')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.ReceptiveField.numRF = value;
                field=[];
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

            if strcmp(field,'Mark')
                if numRF == iniInfo.ReceptiveField.numRF;
                    line=[];
                else
                    line=fgetl(fid);
                end
            else
                line = fgetl(fid);
            end

        end % while ~isempty(line)

    elseif strcmp(line,'[STIMULUS INFO]')
        % get type
        line = fgetl(fid);
        textstring = sscanf(line,'%*[^=]=%[^\n]');
        if strcmp(textstring,'Eye Calibration')
            iniInfo.type = 'Calibration';
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
                end

                if strcmp(fieldName,'Number of Blocks')
                    line=[];
                else
                    line = fgetl(fid);
                end
            end
        end

    elseif strcmp(line,'[TReverseCorrGUIForm]')
        status = 1;
        line = fgetl(fid);
        RevCorrType = str2num(sscanf(line, '%*[^=]=%[^\n]'));
        if RevCorrType == 0
            iniInfo.type = 'm_sequence';
        elseif RevCorrType == 1
            iniInfo.type = 'sparse_noise';
        elseif RevCorrType == 2
            iniInfo.type = 'Movie';
        end
        line = fgetl(fid);
        while ~isempty(line)
            fieldName = sscanf(line, '%[^=]');
            value = sscanf(line, '%*[^=]=%[^\n]');
            switch fieldName
                case 'Matrix'
                    if(isempty(value))
                        iniInfo.m_seq_size = '64x64 (order=16)';
                    elseif strcmp(value(2),'6')
                        iniInfo.m_seq_size = '16x16 (order=16)';
                    elseif strcmp(value(2),'4')
                        iniInfo.m_seq_size = '64x64 (order=16)';
                    end
                case 'Number of Frames'
                    iniInfo.m_seq_frames = str2num(value);
                case 'Number of Columns'
                    iniInfo.grid_cols = str2num(value);
                case 'Number of Rows'
                    iniInfo.grid_rows = str2num(value);
                case 'Number of Colors'
                    iniInfo.num_colors = str2num(value);
                case 'Number of Orientations'
                    iniInfo.num_orientations = str2num(value);
                    numOris = str2num(value);
                case 'Directions per Orientation'
                    iniInfo.dir_per_orientation = str2num(value);
                case 'Base Orientation Angle'
                    iniInfo.orientation_angle = str2num(value);
                case 'Random Order'
                    iniInfo.random_type = value;
                case 'Number of Blocks'
                    iniInfo.num_blocks = str2num(value);
                case 'Repeat Blocks'
                    iniInfo.repeat_blocks = str2num(value);
                case 'Contrast Polarity'
                    iniInfo.contrast_polarity = value;
                case 'Object Type'
                    iniInfo.obj_type = value;
                case 'Object Length'
                    iniInfo.obj_length = str2num(value);
                case 'Object Width'
                    iniInfo.obj_width = str2num(value);
                case 'Object Diameter'
                    iniInfo.obj_diameter = str2num(value);
                case 'Spatial Frequency'
                    iniInfo.spat_freq = str2num(value);
                case 'Temporal Frequency'
                    iniInfo.temporal_freq = str2num(value);
                case 'Velocity'
                    iniInfo.velocity = str2num(value);
                case 'ISI'
                    iniInfo.inter_stimulus_interval = str2num(value);
                case 'Total Frames'
                    iniInfo.total_frames = str2num(value);
                case 'Duration in Frames'
                    iniInfo.num_frames = str2num(value);
                case 'Jittering File Name'
                    iniInfo.jittering_file_name = sscanf(line, '%*[^=]=%[^\n]');
                case 'Use Jittering File'
                    iniInfo.use_jittering_file = str2num(value);
                case 'Spontaneous Activity'
                    iniInfo.spon_activity = str2num(value);
                case 'Spontaneous Refreshes'
                    iniInfo.spon_refreshes = str2num(value);
                case 'Movie Filename'
                    [iniInfo.stimulus_path iniInfo.stimulus_root iniInfo.stimulus_ext] = fileparts(value);
                case 'Frames In Movie'
                    iniInfo.tot_frames_in_movie_file = str2num(value);
                case 'Movie Frame Rows'
                    iniInfo.frame_rows = str2num(value);
                case 'Movie Frame Cols'
                    iniInfo.frame_cols = str2num(value);
                case 'Start Frame'
                    iniInfo.start_frame = str2num(value);
                case 'End Frame'
                    iniInfo.end_frame = str2num(value);
                case 'Frames'		%this will be an integer multiple of stimFrames
                    iniInfo.tot_mov_frames_shown = str2num(value);
                    iniInfo.frames_displayed = str2num(value);

                case 'StimFrames'	%length of movie being shown:  start - end
                    iniInfo.stim_frames = str2num(value);
                case 'Data Start Position'
                    iniInfo.data_start_position = str2num(value);
                case 'Number Of Repeats'
                    iniInfo.num_mov_repeats = str2num(value);
                case 'Monitor Eye Position'
                    iniInfo.monitor_eye_pos = str2num(value);
                case 'Widowed Movie'
                    iniInfo.win_movie = str2num(value);
                case 'Still Images'
                    iniInfo.still_images = str2num(value);
                case 'Number Of Trials'
                    iniInfo.num_trials = str2num(value);
                case 'Play Continuously'
                    iniInfo.play_cont = str2num(value);
                case 'Fix Position X'
                    iniInfo.fixation_location_x = str2num(value);
                case 'Fix Position Y'
                    iniInfo.fixation_location_y = str2num(value);
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
                case 'Enable Window 1'
                    iniInfo.enabled_window_1 = str2num(value);
                case 'X Center For Small Movie Window 1'
                    iniInfo.x_center_small_window_1 = str2num(value);
                case 'Y Center For Small Movie Window 1'
                    iniInfo.y_center_small_window_1 = str2num(value);
                case 'Diameter For Small Movie Window 1'
                    iniInfo.diameter_small_window_1 = str2num(value);
                case 'Enable Window 2'
                    iniInfo.enabled_window_2 = str2num(value);
                case 'X Center For Small Movie Window 2'
                    iniInfo.x_center_small_window_2 = str2num(value);
                case 'Y Center For Small Movie Window 2'
                    iniInfo.y_center_small_window_2 = str2num(value);
                case 'Diameter For Small Movie Window 2'
                    iniInfo.diameter_small_window_2 = str2num(value);
            end %switch

            if strcmp(fieldName,'Screen Resolution')
                line=[];
            else
                line = fgetl(fid);
            end
        end %while

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

            if strcmp(fieldName,'Post Stimulus Duration')
                line=[];
            else
                line = fgetl(fid);
            end
        end

    elseif strcmp(line,'[OBJECT INFO]')
        line = fgetl(fid);
        while (~isempty(line)) & (line ~= -1)
            textstring = sscanf(line,'%[^=]');
            if strcmp(textstring,'Orientation Angle 0')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.orientation_angles = zeros(1, numOris);
                iniInfo.orientation_angles(1) = value;
            elseif strcmp(textstring,'Orientation Angle 1')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.orientation_angles(2) = value;
            elseif strcmp(textstring,'Orientation Angle 2')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.orientation_angles(3) = value;
            elseif strcmp(textstring,'Orientation Angle 3')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.orientation_angles(4) = value;
            end

            if strcmp(textstring,'Orientation Angle 3')
                line=[];
            else
                line = fgetl(fid);
            end
        end

    elseif strcmp(line,'[TRIAL INFO]')
        line = fgetl(fid);
        while ~isempty(line)
            textstring = sscanf(line,'%[^=]');
            if strcmp(textstring,'Number Trials')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.num_trials = value;
            elseif strcmp(textstring,'SN Block Length')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.sn_block_length = value;
            end

            if strcmp(textstring,'SN Block Length')
                line=[];
            else
                line = fgetl(fid);
            end
        end

    elseif strcmp(line,'[EXTRA SYNCS]')
        line = fgetl(fid);
        while ~isempty(line)
            textstring = sscanf(line,'%[^=]');
            if strcmp(textstring,'No extra syncs detected')
                iniInfo.extra_syncs = 0;
                line=[];
            elseif strcmp(textstring,'Total extra syncs')
                value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
                iniInfo.number_extra_syncs = value;
                line=[];
            end
        end

    elseif strcmp(line,'[FIRST FRAMES PER TRIAL]')
        line = fgetl(fid);
        while ~isempty(line)
            ind = sscanf(line,'%[^=]');
            value = sscanf(line, '%*[^=]=%[^\n]');
            iniInfo.first_frames = str2num(value);
            line = [];
        end

    elseif strcmp(line,'[LAST FRAMES PER TRIAL]')
        line = fgetl(fid);
        while ~isempty(line)
            ind = sscanf(line,'%[^=]');
            value = sscanf(line, '%*[^=]=%[^\n]');
            iniInfo.last_frames = str2num(value);
            line = [];
        end

    elseif strcmp(line,'[ACTUAL NUMBER OF TRIALS SHOWN]')
        line = fgetl(fid);
        while ~isempty(line)
            value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
            iniInfo.num_trials = value;
            line = [];
        end

    elseif strcmp(line,'[NUMBER OF FRAMES SHOWN PER TRIAL]')
        line = fgetl(fid);
        while line ~= -1
            ind = str2num(sscanf(line,'%[^=]'));
            value = str2num(sscanf(line, '%*[^=]=%[^\n]'));
            iniInfo.trial_frames(ind) = value;
            line = fgetl(fid);
        end

    else
        % not something we recognize so break out of loop and exit
        break;
    end % which [ ]

end % while ~eof

fclose(fid);