function spike = GenerateSessionSpikeTrains(groupname,gdf,muaCluster)
%GenerateSessionSpikeTrains	Creates session data.
%	spike = GenerateSessionSpikeTrains(GROUPNAME,GDF,MUACLUSTER)
%	creates a spike structure that stores all the spike trains
%	by trials and clusters. This function opens a .GDF file (named
%	GROUPNAME1.GDF), a .DAT file (named GROUPNAME.DAT) and a .HDR
%	file (named GROUPNAME.HDR) in the current directory and uses
%	data from these 3 files to create the the spike data. The
%	GDF argument (0 or 1) specifies if a .GDF is to be used or not.
%	If a GDF file is to be used (i.e. GDF = 1) and MUACLUSTER is 0,
%	any spikes from DAT that are not in GDF will be stored in a
%	new cluster. Otherwise, the missing spikes are added to the
%	cluster numbered MUACLUSTER. spike is a structure with the
%	following fields:
%		SPIKE.sessionname	data file from which the spikes were extracted
%		SPIKE.groupname   signal group number specified in descriptor.txt
%		SPIKE.duration	duration used to form continuous trial
%		SPIKE.signal	signal number in the data file
%		SPIKE.means	means for all trials
%		SPIKE.thresholds	thresholds used in extraction for all trials
%		SPIKE.trial(trial).cluster(clusternum).spikecount
%		SPIKE.trial(trial).cluster(clusternum).spikes()
%	Spiketimes are stored in milliseconds with microsecond precision.
%	For example,
%		annie0424010101 = GenerateSessionSpikeTrains('0001',0,0)
%
%	creates spike data for a session with no .GDF file.
%
%	And,
%		annie0424010101 = GenerateSessionSpikeTrains('0001',1,3)
%
%	creates spike data for a session with a .GDF file. Spikes
%	that are missing from the .GDF file are added to cluster
%	number 3.
%
%	Dependencies: nptReadSorterHdr, nptReadDatFile.

% read HDR file
[duration,min_duration,trials,waves,sessionName,samplingRate,signalNumber,means,thresholds] = nptReadSorterHdr([groupname '.hdr']);
spike.title = 'Sorted Spike Trains';
spike.sessionname = sessionName;
spike.groupname = groupname;
spike.duration = duration;
spike.min_duration = min_duration;
spike.signal = signalNumber;
spike.means = means;
spike.thresholds = thresholds;
% change duration to micro-seconds for use with time in DAT data
duration = duration*1000000;

% read DAT file
[dat,total] = nptReadDatFile([groupname '.dat']);
% get number of spikes in dat
datsize = size(dat.time,2);

if gdf==0
	gdf = [0 0];
	numClusters = 1;
   muaCluster = 1;
   gdfsize = 0;
else
   % read GDF file
   [gdf,gdfsize,numClusters] = nptReadGDFFile([groupname '1.gdf']);
   %[gdf,gdfsize,numClusters] = nptReadMCLUSTFile([groupname '.cut']);
	% get clusters from first column
	clusters = gdf(:,1) - 100;
	% check to see if datsize > gdfsize, that means that we will have to create a
	% cluster to store the missing spikes
	if muaCluster==0 & datsize>gdfsize,
		numClusters = numClusters+1;
		muaCluster = numClusters;
	end
end

gcount = 1;
trial = 0;
for dcount=1:datsize,
	dspiketime = dat.time(dcount);
	spiketrial = floor(dspiketime/duration);
	spiketime = dspiketime - spiketrial*duration;
	if spiketrial+1 > trial
		trial = trial + 1;
		for i=1:numClusters
			spike.trial(trial).cluster(i).spikecount = 0;
		end
		fprintf('%i ',trial);
	end
	% check to make sure we haven't exhausted all the entries in gdf
	if gcount<=gdfsize
      gspiketime = gdf(gcount,2);
   else
      gspiketime = -1;
	end
	% time in dat is in microseconds so divide by 100 and floor it to compare
	% with time in dat file
	%if floor(dspiketime/100)==gspiketime,      %%%%if using old sorter
    if floor(dspiketime/100)==floor(gspiketime)           %if using MCLust
		cluster = clusters(gcount);
		% store the spike time in milliseconds so divide by 1000
		spike.trial(trial).cluster(cluster).spikecount = spike.trial(trial).cluster(cluster).spikecount + 1;
		spike.trial(trial).cluster(cluster).spikes(spike.trial(trial).cluster(cluster).spikecount) = spiketime/1000;
		gcount = gcount + 1;
	else
		% dspiketime is not in gdf so add dspiketime to muaCluster
		spike.trial(trial).cluster(muaCluster).spikecount = spike.trial(trial).cluster(muaCluster).spikecount + 1;
		spike.trial(trial).cluster(muaCluster).spikes(spike.trial(trial).cluster(muaCluster).spikecount) = spiketime/1000;
	end
end

spike.numTrials = trial;
spike.numClusters = numClusters;
fprintf('\n');