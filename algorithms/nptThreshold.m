function [data_mean, stddev] = nptThreshold(data)
%[data_mean, stddev] = nptThreshold(data)
%
%this function finds the approximate mean and
%standard deviation of the noise within a unimodal signal
%(signal with only positive spikes)  
%This function is useful for finding a threshold for 
%spike data.
%
% INPUT PARAMETERS
% DATA is the data to be evaluated.
% It can be multiple channels but is assumed to be made up of column vectors.
% OUTPUT PARAMETERS
% data_mean is the mean of the noise
% stddev is the standard deviation of the noise.
%
%The function works by first finding all points outside of 
%4 standard deviations of the mean.  All of these points are set to NaN's
%and the calculation is repeated.  These iterations are repeated 
%until the ratio between the mean at the beginning of an iteration
%and the end is less than 10^-7.

epsilon=1;    
while max(epsilon) > 0.0000001
    % Calculate sigma thresholds for each channel
    onesigma = nanstd(data);
    avg = nanmean(data);
    % compute positive threshold
    % since we are dealing with unimodal data, avg will always be the mean of the noise or greater.
    v_plusthreshold = avg + (4 * onesigma);
    % make these thresholds into a matrix so that they can be compared to the data
    threshMatrix = repmat(v_plusthreshold, size(data, 1), 1);
    % find points larger than positive threshold
    cliphigh = data > threshMatrix;
    % set them to NaN's
    data(find(cliphigh)) = NaN;
    data_mean = nanmean(data);
    
    epsilon = abs((avg - data_mean)./avg);
end
stddev = nanstd(data);