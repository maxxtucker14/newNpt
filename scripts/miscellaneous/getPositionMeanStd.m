function [m,s] = getPositionMeanStd(d2)
%@getPositionMeanStd Computes standard deviation of XY positions
%   [M,S] = getPositionMeanStd(DATA) computes the standard deviation of
%   of XY positions from DATA, which is a two column array containing
%   the x- and y- signals. The mean xy position, M, is first calculated, 
%   and then distances from M are computed and the standard deviation 
%   of these distances are returned in S.

m = mean(d2);
% compute (dx)^2 and (dy)^2
dxy = (d2 - repmat(m,size(d2,1),1)).^2;
% compute distance from mean, i.e. sqrt((dx)^2+(dy)^2)
ds = sum(dxy').^0.5;
% get standard deviation
s = std(ds);
