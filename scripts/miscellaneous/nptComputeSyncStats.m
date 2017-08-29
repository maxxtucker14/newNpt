function [sIntervals,meanInt,stdInt,maxInt,minInt,iminInt] = nptComputeSyncStats(syncs,varargin)
%nptComputeSyncStats Compute syncs statistics from sync monitor
%   [INTERVALS,MEAN_INT,STD_INT,MAX_INT,MIN_INT,IMIN_INT] 
%      = nptComputeSyncStats(SYNCS) returns statistics 
%   on the number of points bewteen SYNCS. The mean number
%   of points between syncs is returned in MEAN_INT, STD_INT 
%   is the standard deviation of the number of points between
%   syncs, MAX_INT and MIN_INT are the maximum and minimum 
%   number of points between syncs, IMIN_INT contains the 
%   indices corresponding to the interval(s) with the minimum 
%   number of points, and INTERVALS returns the intervals 
%   between syncs in number of points.
%
%   If called with the form: nptComputeSyncStats(SYNCS,MIN_SYNC),
%   IMIN_INT will contain the indices of syncs intervals smaller
%   than MIN_SYNC, which is specified in data points.
%
%   Dependencies: None.

% get number of input arguments
ain = nargin;

if length(syncs)>1
   % s1 = [syncs(2:end);syncs(end)];
   % s2 = s1 - syncs;
   % sIntervals = s2(1:(end-1));
   sIntervals = diff(syncs);
   meanInt = mean(sIntervals);
   stdInt = std(sIntervals);
   maxInt = max(sIntervals);
   minInt = min(sIntervals);
   
   if ain>1
      minSync = varargin{1};
      iminInt = find(sIntervals<minSync);
   else
      iminInt = find(sIntervals==minInt);
   end
else
   meanInt = 0;
   stdInt = 0;
   maxInt = 0;
   minInt = 0;
   iminInt = 0;
   sIntervals = [];
end
