function [results,dmins,mmins] = nptCheckExpSystem(session,varargin)
%nptCheckExpSystem Check for problems on the experimental rig
%   [RESULTS,DMINS,MMINS] = nptCheckExpSystem(SESSION,TRIALS,
%      FG_CHANNELS,SYNC_CHANNEL,MIN_SYNC,TRIG_CHANNEL,TRIG_LENGTH,
%      TRIG_THRESHOLD,SAMPLE_RATE) 
%   uses the following required argument:
%      SESSION: name of the session.
%   and the following optional arguments:
%      TRIALS: vector containing trial numbers (default: 1:336).
%      FG_CHANNELS: row numbers in the data file to use to look
%         for interleaved data at the end of the trial (default: 6:7).
%      SYNC_CHANNEL: row number in the data file corresponding 
%         to the sync channel (default: 2). 
%      MIN_SYNC: minimum number of data points below which a
%         sync will be marked irregular (default: 352).
%      TRIG_CHANNEL: row number in the data file corresponding
%         to the trigger channel (default: 3).
%      TRIG_LENGTH: maximum number of data points above which
%         a trigger will be marked as overly long (default: 305).
%      TRIG_THRESHOLD: threshold votage (in mV) used to identify
%         a trigger (default: 2500).
%      SAMPLE_RATE: sampling rate in points per ms (default: 30).
%   Note that if you want to specify an optional argument, you have
%   to specify all the optional arguments preceeding it.
%
%   The outputs are as follows:
%      RESULTS: data summary for the session with information in 
%         the following columns:
%         1: trial number.
%         2: number of channels.
%         3: trial length in ms.
%         4: trigger duration in data points.
%         5: minimum sync interval from the sync monitor in data
%            points.
%         6: maximum sync interval from the sync monitor in data
%            points.
%         7: minimum sync interval from the sync data in data
%            points.
%         8: maximum sync interval from the sync data in data
%            points.
%         9: last value in the trigger channel in mV.
%         10: 1 if data looks interleaved and 0 otherwise.
%      DMINS: matrix containing the trials with short sync 
%         intervals computed from the sync data with data in the 
%         following columns:
%         1: trial number.
%         2: the interval number within the trial containing the
%            short sync.
%      MMINS: similar to DMINS but the sync monitor is used instead
%         of the sync data.
%
%   Examples:
%      [results,dmins,mmins] = nptCheckExpSystem('test08010201');
%      [results,dmins,mmins] = nptCheckExpSystem('disco08010201',1:140,4:5);
%
%   Dependencies: nptReadStreamerFile, nptReadSyncsFile, 
%      nptComputeSyncStats, nptComputeSyncDataStats.

% default arguments
trial = 1:336;
fgChannels = 6:7;
syncChannel = 2;
minSync = 352;
trigChannel = 3;
trigLength = 305;
threshold = 2500;
samplesPerMS = 30;

% replace default arguments if they are present
if nargin>1
   trial = varargin{1};
end
if nargin>2
   fgChannels = varargin{2};
end
if nargin>3
   syncChannel = varargin{3};
end
if nargin>4
   minSync = varargin{4};
end
if nargin>5
   trigChannel= varargin{5};
end
if nargin>6
   trigLength= varargin{6};
end
if nargin>7
   threshold= varargin{7};
end
if nargin>8
   samplesPerMS= varargin{8};
end

results = [];
dmins = [];
mmins = [];
for i=trial  
   fprintf('%i\n',i)
   trial_num = sprintf('%04i',i);
   filename = [session '.' trial_num];
   error = 0;
   syncerror = 0;
   if ~isempty(dir(filename))
      [data,nc,sr,so,points] = nptReadStreamerFile(filename);
      if points > 0
   		% find out length of control trigger
         lct = find(data(trigChannel,:)<threshold);
         if isempty(lct)
            lct = 0;
         end
         endtrig = data(trigChannel,points);
         % find out max and min sync intervals from data
   		[dsyncs,dsInt,meanD,stdD,maxD,minD,iMinD] = nptComputeSyncDataStats(data(syncChannel,:),minSync);
         mD = [ones(size(iMinD))*i iMinD];
         % check if end points are interleaved
   		iLeaved = nptCheckEndData(data(fgChannels,:));
      else
         error = 1;
      end
   else
      error = 1;
   end
   syncname = [session '.snc' trial_num];
   if ~isempty(dir(syncname))
      [syncs,df,records,meanF,stdF] = nptReadSyncsFile(syncname);
      % find max and min sync intervals from sync monitor
   	[sInt,meanM,stdM,maxM,minM,minMi] = nptComputeSyncStats(syncs,minSync);
      mM = [ones(size(minMi))*i minMi];
   else
      % setting appropriate dummy values
      mM = [i 0];
      maxM = 0;
      minM = 0;
   end
   if error ==1
      nc = 0;
   	points = 0;
      lct = 0;
      endtrig = 0;
      maxD = 0;
      minD = 0;
      mD = [i 0];
      iLeaved = 0;
   end
   results = [results; i nc points/samplesPerMS lct(1) maxM minM maxD minD endtrig iLeaved];
   dmins = [dmins; mD];
   mmins = [mmins; mM];
end
