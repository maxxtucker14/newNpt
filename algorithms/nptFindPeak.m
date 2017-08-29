function peak =  nptFindPeak(crossings, data)
%   peak =  nptFindPeak(crossings, data)
%   For use with nptThresholdCrossings
%   Finds peaks between threshold crossings
%   Input:  crossings -- the output structure from nptThresholdCrossings
%               containing the timestamps of such crossings
%           data -- the data from which the crossings were taken (needed to
%               retrieve "y-axis" values for peaktimes
%   Output: peak -- 2 row matrix.  Row 1: peak values; Row 2: peak times

%if it starts on a falling
if crossings.rising(1) > crossings.falling(1)
    crossings.falling(1) = [];
end

%else if it ends on a rising
if length(crossings.rising) ~= length(crossings.falling)
    crossings.rising(length(crossings.rising)) = [];
end

num_peaks = size(crossings.rising, 2);
peak = zeros(2, num_peaks);

for ind = 1:num_peaks
    [y, index] = max(data(crossings.rising(ind):crossings.falling(ind)));
    peak(1,ind) = y;
    peak(2,ind) = crossings.rising(ind) + index;
end