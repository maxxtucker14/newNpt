function status=nptAppendStreamerFile(filename,sampling_rate,data,scan_order)
%nptAppendStreamerFile Function to write binary files from Data Streamer
%function status=nptAppendStreamerFile(filename,sampling_rate,data,scan_order)
%scanorder is optional
%  Append to the end of the file

fid=fopen(filename,'a','ieee-le');
status = fseek(fid,0,'eof');
fwrite(fid, data, 'int16');
fclose(fid);
