function InspectSpikes(spike)
%INSPECTSPIKES	Plots sorted spikes over raw traces
%	INSPECTSPIKES(SPIKEDATA) takes a structure spike generated
%	by the function GenerateSessionSpikeTrains containing the 
%	following fields:
%		spike.name
%		spike.duration
%		spike.signal
%		spike.means
%		spike.thresholds
%		spike.trial().cluster().spikes()
%		spike.trial().cluster().spikecount
%	and plots a spike train for each cluster above the raw data. The raw
%	data is assumed to be in the current directory and spike.signal 
%	specifies which data series in the raw file is to be plotted. If the
%	means and the thresholds used for the extraction are stored in the 
%	spike data, they are also plotted.
%
%	Dependencies: nptReadStreamerFile.

channel = spike.signal;
numTrials = size(spike.trial,2);
numClusters = size(spike.trial(1).cluster,2);

% check to see if spike data contain means and thresholds
if ~isempty(spike.means)
	plotmeans = 1;
else
	plotmeans = 0;
end

% open up the first trial to get sampling rate
[data,numChannels,samplingRate,scanOrder,datalength] = nptReadStreamerFile([spike.name '.0001']);

% convert duration to milliseconds
duration = ceil(spike.duration) * 1000;
% get time steps in milliseconds
timestep = 1/samplingRate*1000;
% get time vector
timev = 0:timestep:duration;

% get color order list. gcf will use current figure if there is one 
% or create one if there are no figures currently
hfig = gcf;
clist = get(gca,'ColorOrder');
clistsize = size(clist,1);
zoom on

% variable to check if we are just displaying the first trial for the
% first time which means we don't have to read the data file again
% otherwise, if we are displaying the first trial because the user hit 
% the p key or typed in the number, we have to read the data file again
initial=1;
trial = 1;
while trial<=numTrials
	% open up the raw streamer file for the trial
   filename = [spike.name '.' num2str(trial,'%04i')];
   fprintf('Reading %s\n',filename);
	% don't have to read trial 1 since we already read it in above
	if ~(trial==1 & initial==1)
      [data,numChannels,samplingRate,scanOrder,datalength] = nptReadStreamerFile(filename);
   else
      % i.e. trial==1 and initial==1 so that means we are displaying the
      % first trial for the first time so don't have to read data and 
      % change the initial flag to 0
      initial=0;
	end
	hold off
	plot(timev(1:datalength),data(channel,:))
	hold on
   ax = axis;
   if plotmeans==1
	   % plot mean
	   tmean = spike.means(trial);
	   tthreshold = spike.thresholds(trial);
	   plus = tmean+tthreshold;
	   minus = tmean-tthreshold;
	   line([ax(1) ax(2)],[tmean tmean],'Color',[1 0 0]);
	   line([ax(1) ax(2)],[plus plus],'Color',[0 1 0]);
	   line([ax(1) ax(2)],[minus minus],'Color',[0 1 0]);
	end
	cplotheight = (ax(4) - ax(3)) * 0.1;
	for cluster=1:numClusters
		% draw a line
		lineY = ax(4)+(cluster-1)*cplotheight;
		line(ax(1:2),[lineY lineY],'Color',clist(mod(cluster-1,clistsize)+1,:));
		lineY2 = lineY + cplotheight;
		% draw the spikes
		for spikenum=1:spike.trial(trial).cluster(cluster).spikecount
			spiketime = spike.trial(trial).cluster(cluster).spikes(spikenum);
			line([spiketime spiketime],[lineY lineY2],'Color',clist(mod(cluster-1,clistsize)+1,:));
		end
   end
   % shift axis a little bit so we can see the start of the data
   ax = axis;
   axis([-25 ax(2) ax(3) ax(4)]);

	% get keyboard input to see what to do next
	key = input('RETURN - Next Trial; p - Previous trial; N - Trial N; q - Quit: ','s');
	n = str2num(key);
	if strcmp(key,'p')
		trial = trial - 1;
		if trial<1
			trial = 1;
      end
      
   elseif strcmp(key,'q')
      return;
	elseif ~isempty(n)
		if n>0 & n<=numTrials
			trial = n;
		end	
	else
		trial = trial + 1;
	end
	% clear memory
	clear data;
end
