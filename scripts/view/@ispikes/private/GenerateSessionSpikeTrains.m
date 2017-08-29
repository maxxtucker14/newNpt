function spike = GenerateSessionSpikeTrains(groupname,cut)
%GenerateSessionSpikeTrains	Creates session data.
%	spike = GenerateSessionSpikeTrains(GROUPNAME,CUT)
%	creates a spike structure that stores all the spike trains
%	by trials and clusters. This function opens a .CUT file (named
%	*GROUPNAME.CUT), a waveforms file and a .HDR
%	file (named GROUPNAME.HDR) in the current directory and uses
%	data from these 3 files to create the the spike data. The
%	CUT argument (0 or 1) specifies if a .cut file is to be used or not.
%	If a GDF file is not to be used (i.e. CUT = 0)
%	all spikes from the waveforms file will be stored in a
%	multiunit (MUA) cluster. 
%   spike is a structure with the following fields:
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
%		annie0424010101 = GenerateSessionSpikeTrains('0001',0)
%
%	creates spike data for a session with no .cut file.
%
%	And,
%		annie0424010101 = GenerateSessionSpikeTrains('0001',1)
%
%	creates spike data for a session with a .cut file. 
%
%	Dependencies: nptReadSorterHdr, nptReadCUTFile, nptLoadingEngine.

% read HDR file
[duration,min_duration,trials,waves,sessionName,samplingRate,signalNumber, ...
        means,thresholds,numChunks,chunkSize] = nptReadSorterHdr([groupname '.hdr']);
spike.title = 'Sorted Spike Trains';
spike.sessionname = sessionName;
spike.groupname = groupname;
spike.cellname = '';
spike.duration = duration;
spike.min_duration = min_duration;
spike.signal = signalNumber;
spike.means = means;
spike.thresholds = thresholds;
spike.numChunks = numChunks;
spike.chunkSize = chunkSize;  %in datapoint units.
 
%%%%%%%%%%%%%%%%%%%%%%  chunks  %%%%%%%%%%%%%%%%%%%
if numChunks==0 & trials==1 %data extracted before numChunks
    [spike.numChunks,spike.chunkSize] = getChunkInfo(sessionName,17);
end

% change duration to micro-seconds for use with time in waveforms data
duration = duration*1000000;

%assume waveform file is in the same directory
% check if name contains '_highpass'
snIndex = strfind(sessionName,'_highpass');
if isempty(snIndex)
    filenameroot=[sessionName 'g' groupname 'waveforms'];
else
    filenameroot=[sessionName(1:(snIndex-1)) 'g' groupname 'waveforms'];
end
times = ReadWaveformsFile([filenameroot '.bin'],[],6);  %microseconds


if cut==0
    numClusters = 1;
    numSpikes=length(times);
    clusters=ones(size(times));
    
else
    [clusters,numSpikes,numClusters] = ReadCUTFile([filenameroot '.cut']);
    try
        load([filenameroot '_overlap.mat']);
        numClusters = size(overlap,2);
    catch
        overlap=[];
        fprintf('Warning.  No overlap file found!!! \n All overlap spike information will be discarded.\n')
    end
end

trial=0;

for count=1:numSpikes,
    spiketrial = floor(times(count)/duration);
    spiketime = times(count) - spiketrial*duration ;
    
        while trial < spiketrial +1 % loops until the new trial with a spike is encountered
            trial = trial + 1;  %trial = trial + 1;
            for i=1:numClusters
                spike.trial(trial).cluster(i).spikecount = 0;
                spike.trial(trial).cluster(i).spikes = [];
            end
            fprintf('%i ',trial);
        end
    
    cluster = clusters(count);
    if cluster==-1 & ~isempty(overlap)
        %goto overlap matrix and find info
        cluster = find(overlap(count,:));
        for i=1:length(cluster)
            spike.trial(trial).cluster(cluster(i)).spikecount = spike.trial(trial).cluster(cluster(i)).spikecount + 1;
            spike.trial(trial).cluster(cluster(i)).spikes(spike.trial(trial).cluster(cluster(i)).spikecount) = spiketime/1000;
        end
    elseif cluster~=0
        % store the spike time in milliseconds so divide by 1000
        spike.trial(trial).cluster(cluster).spikecount = spike.trial(trial).cluster(cluster).spikecount + 1;
        spike.trial(trial).cluster(cluster).spikes(spike.trial(trial).cluster(cluster).spikecount) = spiketime/1000;
    end
end

% if last trial had no spikes, create empty trial
if trial < trials
    for t = (trial+1):trials
        for i=1:numClusters
            spike.trial(t).cluster(i).spikecount = 0;
            spike.trial(t).cluster(i).spikes = [];
        end
        fprintf('%i ',t);
    end
end

spike.numTrials = trials;
spike.numClusters = numClusters;
fprintf('\n');