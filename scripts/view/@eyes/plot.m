function [ve,varargout] = plot(ve,n,varargin)
%EYES/PLOT Plots raw data from Eye folder
%   OBJ = PLOT(OBJ,N,VARARGIN) plots the raw data from the trial 
%   specified by N. The eye files are assumed to be in the current 
%   directory. The sampling rate of the eye signals is usually 1 kHz.
%
%   The optional input arguments are:
%      'XY' - flag to plot data in 2D.
%      'Calib' - flag to plot eye calibration grid illustrating the 
%                distortions in the eye signals. This option assumes
%                the 'XY' option. The eye calibration data is obtained
%                from the getEyeCalData function, which is called
%                from two directories up.
%      'CalibDir' - specifies an alternative directory in which to run
%                   the getEyeCalData function.
%      'CalibData' - specifies a structure to use as the eye
%                    calibration data.
%      'DataStart' - followed by number specifying first data point
%                    to be plotted (default: 1).
%      'DataEnd' - followed by number specifying the last data point
%                  to be plotted (default: length(data)).
%      'AxisZoom' - followed by array which is passed to axis to set
%                   the axis limits (default: []).
%      'XYStd' - followed by handle to a figure to use to display
%                histogram of distances from the mean.
%
%   Dependencies: nptReadDataFile.
%
%   obj = plot(obj,n,'XY','Calib','CalibDir','../..','CalibData',ec, ...
%      'DataStart',1,'DataEnd',l,'AxisZoom',[],'XYStd',[]);

Args = struct('XY',0,'CalibData',0,'DataStart',1,'DataEnd',[],'AxisZoom',[], ...
    'linkedZoom',0,'XYStd',[],'Calib',0,'CalibDir',['..' filesep '..'], ...
    'MarkerSize',24,'ColorPath',0,'TickDir','in');
Args.flags = {'XY','Calib','linkedZoom','ColorPath'};
Args = getOptArgs(varargin,Args);

if(Args.Calib)
	% get data from CalibDir
	Args.CalibData = getEyeCalData('Dir',Args.CalibDir);
end
if(isstruct(Args.CalibData))
	% make sure we plot in XY if CalibData was used
	Args.XY = 1;
end
if(~isempty(Args.XYStd))
	Args.XY = 1;
end

% open new figure if none exists, otherwise just use the current figure
gcf;
clist = get(gca,'ColorOrder');
clistsize = size(clist,1);

% set zoom to on
zoom on

channel = ve.channel;
sessionname = ve.sessionname;
% set horizontal and vertical channels
vchan = 1;
hchan = 2;

trialn = num2str(n,'%04i');
% % check to see if we are in the right directory
% [res,aname] = ispresent(Args.EyeDir,'dir','CaseInsensitive');
% if(~res)
%     % we are already in the right directory so set prefix to .
%     dirprefix = '.';
% else
%     dirprefix = aname;
% end
%     
% % open up the eye file for the trial
% filename = [dirprefix filesep sessionname '_eye.' trialn];
filename = [sessionname '_eye.' trialn];
fprintf('Reading %s\n',filename);
cwd = pwd;
% get directory from nptdata object, which is a cell array
% sessiondir = get(ve,'SessionDirs');
% there should only be 1 directory in sessiondir so just use first one
% cd(sessiondir{1})
cd(ve.nptdata.SessionDirs{1})
[data,numChannels,samplingRate,datatype,datalength] = nptReadDataFile(filename);
cd(cwd)
%convert from pixels to degrees
if strcmp(ve.units,'degrees')
   [data(1,:), data(2,:)] = pixel2degree(data(1,:),data(2,:));
end

% get length of data
dlength = size(data,2);
if(isempty(Args.DataEnd))
    Args.DataEnd = dlength;
end
plotPoints = Args.DataStart:Args.DataEnd;
if(Args.XY)
	if(isstruct(Args.CalibData))
		% plots the locations where the eye calibration was measured
		plot(Args.CalibData.screenx(:),Args.CalibData.screeny(:),'+');
		hold on
		% draw vertical lines of grid
		plot(Args.CalibData.gridx,Args.CalibData.gridy,'g');
		% draw horizontal lines of grid
		plot(Args.CalibData.gridx',Args.CalibData.gridy','g');
	end
	% plot data from trial n
    if(Args.ColorPath)
        scatter(data(hchan,plotPoints),data(vchan,plotPoints),Args.MarkerSize,plotPoints,'filled')
    else
    	plot(data(hchan,plotPoints),data(vchan,plotPoints),'r.-')
		hold on
		% put a black dot on the last point
		plot(data(hchan,Args.DataEnd),data(vchan,Args.DataEnd),'k.')
        hold off
    end
	% flip the y axis so it corresponds to screen coordinates
	set(gca,'YDir','reverse')
	xlabel('Eye Position X (pixels)')
	ylabel('Eye Position Y (pixels)')
    if(~isempty(Args.AxisZoom))
        axis(Args.AxisZoom)
    end
    if(~isempty(Args.XYStd))
		% compute mean and std for relevant data
		[dm,dstd] = getPositionMeanStd(data(:,plotPoints)');
    	% plot mean and standard deviation
    	plot(dm(2),dm(1),'o')
    	line([dm(2)-dstd dm(2)+dstd],[dm(1) dm(1)])
    	line([dm(2) dm(2)],[dm(1)-dstd dm(1)+dstd])
    	% get current figure so we can set it back after we plot histogram
    	h = gcf;
    	figure(Args.XYStd)
    	hist(ds)
    	title(['STD: ' num2str(dstd)])
    	figure(h)
    end
	varargout{1} = {'Args',Args,'handle',gca};
else
	% convert to milliseconds
	timestep = 1/samplingRate*1000;
	duration = (datalength)/samplingRate * 1000;
	timev = 0:timestep:duration;
	for i=1:length(channel)
	   eval(['h' num2str(i) '= plot(timev(1:datalength),data(channel(i),:),''Color'',clist(mod(i-1,clistsize)+1,:));'])
	
	   hold on
	end
	if strcmp(ve.units,'degrees')
		ylabel('degrees')
	else
		ylabel('pixels')
	end
	%xlabel('Time (msec)')
	legend('vertical','horizontal')
    legend boxoff
	% shift x axis a little bit so we can see the start of the data
	set(gca,'XLim',[-25 duration])

    varargout{1} = {'Args',Args,'handle',gca,'h1',h1,'h2',h2};
end	

set(gca,'TickDir',Args.TickDir)
hold off
zoom on
title([sessionname '.eye.' trialn]);
