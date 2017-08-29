function vi = brunoplot(vi,n,varargin)
%ISPIKES/PLOT Plots interleaved spikes over raw traces
%   OBJ = PLOT(OBJ,N) plots a spike train for each cluster above the 
%   raw data for trial N. The raw data is assumed to be in the current 
%   directory. If the means and the thresholds used for the extraction 
%   are stored in the ISPIKES object, they are also plotted.
%
%	Dependencies: nptReadStreamerFile.

% get color order list. gcf will use current figure if there is one 
% or create one if there are no figures currently

% presTrigOnsets is passed in as varargin
presTrigOnsets = varargin{1};

hfig = gcf;
zoom on

clist = get(gca,'ColorOrder');
clistsize = size(clist,1);

trial = n;
channel = vi.signal;
numTrials = vi.numTrials;
numClusters = vi.numClusters;
sessionname = vi.sessionname;
groupname = vi.groupname;
duration = vi.duration;

plot(vi.streamer,trial);
ax = axis;
clf

% draw stimulus representation
stairs([0 presTrigOnsets(n,:)/30 ax(2)],[0 0.8 0 0])
hold on

for cluster=1:numClusters
	%draw a line
	lineY = 1+(cluster-1);
	line(ax(1:2),[lineY lineY],'Color',clist(mod(cluster-1,clistsize)+1,:));
	lineY2 = lineY + 0.8;
    if (vi.trial(trial).cluster(cluster).spikecount > 0)
		%draw the spikes
		%spikecount = vi.trial(trial).cluster(cluster).spikecount;
		spiketime = vi.trial(trial).cluster(cluster).spikes;%change from micro to milliseconds
        [y,ind]=find(spiketime>ax(1) & spiketime<ax(2));
        for spikenum=ind
            line([spiketime(spikenum) spiketime(spikenum)],[lineY lineY2],'Color',clist(mod(cluster-1,clistsize)+1,:));
        end
    end
end

axis off
set(gcf,'Color',[1 1 1])
hold off
