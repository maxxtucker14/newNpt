function vs = plot(vs,n)
%DATAFILE/PLOT Plots data files written using nptWriteDataFile
%   OBJ = PLOT(OBJ,N) plots the raw data from the trial specified N. 
%   The data files are assumed to be in the current directory. 
%
%   Dependencies: nptReadDataFile.

% open new figure if none exists, otherwise just use the current figure
gcf;
clist = get(gca,'ColorOrder');
clistsize = size(clist,1);

% set zoom to on
zoom on

channel = vs.channel;
sessionname = vs.sessionname;

% open up the raw streamer file for the trial
filename = [sessionname '.' num2str(n,'%04i')];
fprintf('Reading %s\n',filename);
[data,numChannels,samplingRate,datatype,datalength] = nptReadDataFile(filename);
% convert to milliseconds
timestep = 1/samplingRate*1000;
duration = (datalength)/samplingRate * 1000;
timev = 0:timestep:duration;
for i=1:length(channel)
   plot(timev(1:datalength),data(channel(i),:),'Color',clist(mod(i-1,clistsize)+1,:))
   hold on
end
hold off
title(filename);
% shift x axis a little bit so we can see the start of the data
ax = axis;
axis([-25 ax(2) ax(3) ax(4)]); 
% set zoom to on
zoom on
