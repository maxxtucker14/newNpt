function frame = ReadStimulusFrame(frame_num, init_info, stimheader)
%function frame = ReadStimulusFrame(frame_num, init_info, stimheader)
%
%reads the correct frame from the correct stimulus file

if frame_num<=stimheader.frames_total
	stimulus_num=floor(frame_num/(stimheader.end_frame+1));
	stimulus_file = [init_info.stimulus_root num2strpad(stimulus_num,3) init_info.stimulus_ext];
   
   fid=fopen(stimulus_file,'r');
	error_flag=0;
	if fid == -1
   	errordlg('The stimulus file for this processed data could not be opened','ERROR')
   	error_flag=1;
   else
      status = fseek(fid,stimheader.headersize,'bof');
      skip_bytes = stimheader.w*stimheader.h*mod(frame_num,(stimheader.end_frame+1))*1;	%*1 b/c uint8 is 8 bits or 1 byte
      status = fseek(fid,skip_bytes,'cof');
      %read frame
   	frame = fread(fid,[stimheader.w,stimheader.h],'*uint8');	%frame is read in as uint8 b/c of *
      fclose(fid);
   end
end

   
      
      



