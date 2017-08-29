function nptWriteSorterHdr(filename,fs,max_duration,min_duration,trials,totalwaves,...
   rawfile,channel_num,extract_info,varargin)
%nptWriteSorterHdr(filename,fs,max_duration,min_duration,trials,totalwaves,...
%	rawfile,channel_num,extract_info)

% this is used in 2 places so instead of converting it twice, we convert 
% argument to string now
fsstr = int2str(fs);
num_cha = size(channel_num,2);
% write headers for the sun.

fid=fopen([filename '.hdr'],'wt');

fprintf(fid,'GETDATA v1.0\n');
fprintf(fid,'description 1:  this is a parameter ASCII file for GETDATA.EXE\n');
fprintf(fid,'description 2:  you can type any description on the first four lines\n');
fprintf(fid,'Raw Streamer Filename = %s Number of Trials = %i \n',rawfile,trials);
fprintf(fid,'Total Waveforms per group = %i Trial Durations = %f,%f Channel Numbers =',totalwaves,max_duration,min_duration);
fprintf(fid,' %i',channel_num(1));
for i=2:size(channel_num,2)
    fprintf(fid,',%i',channel_num(i));
end
fprintf(fid,'\n');
fprintf(fid,'%s\trequested frequency per channel\n',fsstr);
fprintf(fid,'%s\tactual frequency per channel\n',fsstr);
fprintf(fid,'%6f\tduration of event in seconds\n',max_duration*trials);
fprintf(fid,'1\tgain of all channels: 1, 2, 4, 8\n');
fprintf(fid,'%s\telectrode config: 1-single, 2-stereo, 4-tetrode\n',int2str(num_cha));
fprintf(fid,'1\tspike extraction: 0-off, 1-on\n');
fprintf(fid,'10\twave samples before threshold crossing\n');
fprintf(fid,'21\twave samples after threshold crossing\n');
fprintf(fid,'0\tRS232 Feedback from Sampler for Event OK or Stop: 0-off, 1-on\n');
fprintf(fid,'0\tRS232 Feedback Port: 0-COM1, 1-COM2, 2-COM3, 3-COM4\n');
fprintf(fid,'1\tchannel active: 0-off, 1-on\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'0\n');
fprintf(fid,'2050\tbaseline value: 0-4095\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2050\n');
fprintf(fid,'2060\n');
fprintf(fid,'2061\n');
fprintf(fid,'2062\n');
fprintf(fid,'2063\n');
fprintf(fid,'2120\n');
fprintf(fid,'2220\n');
fprintf(fid,'2090\tthreshold value: 0-4095\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2150\n');
fprintf(fid,'2083\n');
fprintf(fid,'2084\n');
fprintf(fid,'2085\n');
fprintf(fid,'2086\n');
fprintf(fid,'2087\n');
fprintf(fid,'2088\n');
fprintf(fid,'2088\n');
fprintf(fid,'2088\n');
% write the means and thresholds for each trial
for i=1:trials
   fprintf(fid,'Trial=%i ',i);
   fprintf(fid,'Mean=');
   fprintf(fid,'%f ',extract_info.trial(i).means);
   fprintf(fid,'Threshold=');
   fprintf(fid,'%f ',extract_info.trial(i).thresholds);
   fprintf(fid,'\n');
end
if length(varargin)==2
    fprintf(fid,'numChunks = %i  chunkSize = %i',varargin{1},varargin{2});
end
fclose(fid);
