function [sTrigs,eTrigs] = nptComputeTrigDurations(data)
%nptComputeTrigDurations Compute durations of start and end triggers
%   [START_TRIGS,END_TRIGS] = nptComputeTrigDurations(DATA)
%   computes the durations of the start and end triggers 
%   and returns them in START_TRIGS and END_TRIGS in number 
%   of data points. DATA is assumed to contain just the
%   trigger channel.
%
%   Dependencies: None.

a = (data>2500) .* 5000;
dd = diff(a);
% no longer calls nptComputeSyncDataStats to reduce memory usage
dd1 = find(dd>2500);
dd2 = find(dd<-2500);
dd3 = sort([dd1 dd2]);
intervals = transpose(diff(dd3));
is = length(intervals);
trigIntervals = intervals(1:2:is);
it = length(trigIntervals);
sTrigs = trigIntervals(1:2:it);
eTrigs = trigIntervals(2:2:it);
