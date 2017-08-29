function [r,p] = spcorr(x,varargin)
%SPCORR Compute Spearman rank correlation
%   [R,P] = SPCORR(X) returns the non-parametric Spearman rank
%   correlation calculated from an input matrix X whose rows 
%   are observations and whose columns are variables. The data
%   in X is first ranked (equivalent values are set to the mean 
%   rank) before corrcoef is called to return the correlation
%   coefficient, R, and the p value in P.
%
%   [R,P] = SPCORR(X,Y) where X and Y are column vectors, is the
%   same as SPCORR([X Y]).
%
%   SPCORR(X,VARARGIN) passes the optional arguments in VARARGIN
%   to corrcoef. 
%
%   Dependencies: corrcoef.

% partially based on code from Jean-Philippe
% sort in one direction and then sort again in the opposite direction
% to get average rank for equivalent values

if length(varargin)>0 & isnumeric(varargin{1})
   y = varargin{1};
   varargin = removeargs(varargin,1,1);

   % Two inputs, convert to equivalent single input
   x = x(:);
   y = y(:);
   if length(x)~=length(y)
      error('The lengths of X and Y must match.');
   end
   x = [x y];
elseif ndims(x)>2
   error('Inputs must be 2-D.');
end

[sortedx,xi] = sort(x);
[sortedx,xrank] = sort(xi);

y = flipud(x);
[sortedy,yi] = sort(y);
[sortedy,yi2] = sort(yi);
yrank = flipud(yi2);

rank = (xrank+yrank)/2;
[r,p] = corrcoef(rank,varargin{:});
