function [syncs,sIntervals,sMean,sStd,sMax,sMin,sMinI] = nptComputeSyncDataStats(data,varargin)
%nptComputeSyncDataStats Compute sync statistics from raw data
%   [SYNCS,INTERVALS,MEAN_INT,STD_INT,MAX_INT,MIN_INT,IMIN_INT] 
%      = nptComputeSyncDataStats(DATA) finds the data
%   points corresponding to the rising phase of a sync
%   signal and calls nptComputeSyncStats to return 
%   statistics on the number of points between SYNCS.
%   The mean number of points between syncs is returned 
%   in MEAN_INT, STD_INT is the standard deviation of 
%   the number of points between syncs, MAX_INT and 
%   MIN_INT are the maximum and minimum number of points
%   between syncs, IMIN_INT contains the indices 
%   corresponding to the interval(s) with the minimum 
%   number of points, and INTERVALS returns the intervals 
%   between syncs in number of points. The data points
%   corresponding to syncs are also returned in SYNCS.
%
%   Dependencies: nptComputeSyncStats.

sThreshold = 2500;
sMax = 5000;
dThresh = (data>sThreshold) * sMax;
syncs = nptThresholdCrossings(dThresh,2500,'rising')';
[sIntervals,sMean,sStd,sMax,sMin,sMinI] = nptComputeSyncStats(syncs,varargin{:});
