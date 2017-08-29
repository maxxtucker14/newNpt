function [y,t] = slidingHist(data,slide,width,duration,shape)
%
%[y,t] = slidingHist(data,slide,width,duration,shape)
%
%calculates the histogram with a sliding window.
%  INPUTS:
%   data - row vector or matrix.
%           If a matrix then each row is a different repetition.
%   slide - amount to slide the window on each step.
%   width - width of window.
%   duration - final time value.
%   shape - shape of vector.  The default is rectangular or ones(1,round(width/slide)).
%
%  OUTPUTS:
%   y - histogram vector
%   t - time vector
%   
%  METHOD:
%  calculates the histogram at the slide resolution.  Then balculates the
%  running sum over width.  The width is rounded to the nearest integer
%  multiple of the slide.  Edge effects are removed.

m = round(width/slide);
if nargin<5
    shape = ones(1,m);
end
edges = 0:slide:ceil(duration);
count = sum(histcie(data,edges),2)';
y = conv(count,shape);
t = edges;
% get length of y
ylength = length(y);
% get size of edge effects
edgesize = floor(m/2) - 1;
%remove edge effects
y(1:edgesize)=[];
y((ylength-edgesize):ylength)=[];

if length(t) < length(y)
    y = y(1:length(t));
end    