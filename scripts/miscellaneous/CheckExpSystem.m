function [results,dmins,mmins,iTrials,eTrials] = CheckExpSystem(session,varargin)
%CheckExpSystem Check for problems on the experimental rig
%   [RESULTS,DMINS,MMINS,ITRIALS,ETRIALS] = CheckExpSystem(SESSION,
%      TRIALS,FG_CHANNELS,SYNC_CHANNEL,MIN_SYNC,TRIG_CHANNEL,TRIG_LENGTH,
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
%      ITRIALS: vector of trial numbers with interleaved data at the
%         end of the trial.
%      ETRIALS: vector of trial numbers missing end triggers.
%   The function will also print out on the screen the following:
%      1: standard deviation of the trial duration.
%      2: number of trials with long triggers.
%      3: number of trials missing end triggers.
%      4: number of trials with interleaved data at the end of the trials.
%
%   Examples:
%      [results,dmins,mmins,iTrials,eTrials] = CheckExpSystem(
%         'test08010201');
%      [results,dmins,mmins,iTrials,eTrials] = CheckExpSystem(
%         'disco08010201',1:140,4:5);
%
%   Dependencies: nptCheckExpSystem,PlotExpSystemResults.


[results,dmins,mmins] = nptCheckExpSystem(session,varargin{:});

% set default values of trigLength and threshold
trigLength = 305;
threshold = 2500;

% do some processing of the arguments for PlotExpSystem
if nargin>7
   trigLength = varargin{8};
end
if nargin>8
   threshold = varargin{9};
end

[iTrials,eTrials] = PlotExpSystemResults(results,dmins,mmins,trigLength,threshold);
