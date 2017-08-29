function [stimheader] = ReadNewStimulusHeader(stimulus_file)
%function [stimheader] = ReadNewStimulusHeader(stimulus_file)
%
%stimulus files are limited to about one gigabyte in size. 
%the first stimulus file contains the maximum integer number of frames 
%that will fit in this space.
%Subsequent files contain the same number of frames per file(except the last may contain less)
%
%we read the stimulus header to determine which stimulus file contains which frame number.

% stimulus_num = 0;
% stimulus_file = [init_info.stimulus_root num2strpad(stimulus_num,3) init_info.stimulus_ext];

fid=fopen(stimulus_file,'r');
error_flag=0;
if fid==-1
   errordlg('The stimulus file for this processed data could not be opened','ERROR')
   error_flag=1;
end
if error_flag~=1
   %pgl movie has a header to start and then all the frames follow (only one header for all the frames)
   
   %read header info from stimulus file
   stimheader.type = fscanf(fid,'%s ',1);					% file type
   stimheader.w = fscanf(fid,'%i ',1);						% width
   stimheader.h = fscanf(fid,'%i ',1);						% height
   stimheader.start_frame=fread(fid,1,'int32');			% first frame of movie(0)
   stimheader.end_frame=fread(fid,1,'int32');			% frame end
   stimheader.frames_total=fread(fid,1,'int32');		% frames total
   stimheader.headersize=ftell(fid);
   fclose(fid);
end
