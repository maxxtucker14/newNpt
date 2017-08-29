function photoSpikes = CreatePhotoSpikes(session, numTrials, photoChannel, photoThresh);
%[photoSpikes, presentTrigs] = CreatePhotoSpikes(session, numTrials, presenterTrig, photoChannel, photoThresh);
%CreatePhotoSpikes  -- function which creates an ispikes object from photodiode data
%
%   Input:  session -- session name prefix, ex:  'test043003'
%           numTrials -- number of trials in vector form, ex: 1:100;
%           photoChannel -- channel number of photodiode data
%           photoThresh -- threshhold for both the presenter trigger, and the photodiode data
%
%   Output: photoSpikes -- an ispikes object, where "spikes" are noted every time the
%				photodiode signal crosses photoThresh.  See ISPIKES for more info.
%
%	Dependencies:  ispikes.m, nptReadStreamerFile.m, nptThresholdCrossings.m,

%Create and Initialize photoSpikes object
% s = ispikes;
% s.title = 'Rev Corr Photo Diode Data';
% s.sessionname = session;
% s.groupname = 1;
% s.signal = photoChannel;
% s.thresholds = photoThresh;
% s.numTrials = max(numTrials);
% s.numClusters = 1;

%Set up filter specs
order = 10;
b = 1/order*ones(1, order);
a = 1;

for index = numTrials			%For each trial...
    fprintf('%i\n',index)
    trialNum = sprintf('%04i',index);
    filename = [session '.' trialNum];
    [data, nc, sr, so, points] = nptReadStreamerFile(filename);
	
    %filtering the data
    filtData = filtfilt(b, a, data(photoChannel, :));
	%filtData = data(photoChannel, :);
	%finding threshold crossings of the photodiode data in milliseconds
    crossings = nptThresholdCrossings(filtData, photoThresh, 'rising', 'ignorefirst');
    s.trial(index).cluster(1).spikes = crossings;
	s.trial(index).cluster(1).spikecount = length(crossings);
	if points > s.duration
		s.duration = points;
	end
end
photoSpikes = s;