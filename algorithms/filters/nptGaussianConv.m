function [resampled_data , resample_rate, G, sigma, SamplesPerMS] = nptGaussianConv(data,sample_rate)
%function resampled_data = nptGaussianConv(data,sample_rate)
%Convolves a 3 sigma gaussian with the data as an antialiasing filter
%then subsamples data and removes edge effects
%resample_rate=1000; %1 KHz


resample_rate=1000;

SamplesPerMS = fix(sample_rate / resample_rate);
   sigma = floor(SamplesPerMS);
   G = exp(-(-3*sigma:3*sigma).^2/(2*sigma^2));
   G = G / sum(G(:));

% smooth data by convolving with gaussian mask 'G'
dataconv = conv2( data, G, 'same' );
% subsample data approximately every millisecond
n = size(dataconv, 2);
resampled_data = dataconv(:,1:SamplesPerMS:n);
% (!) remove edge effect that conv2 imposes, assume low-velocity trace (!)
resampled_data(:,1:3) = resampled_data(:,4)*ones(1,3);
finis = size(resampled_data,2);
resampled_data(:,finis-2:finis) = resampled_data(:,finis-3)*ones(1,3);
SamplesPerMS=1;
