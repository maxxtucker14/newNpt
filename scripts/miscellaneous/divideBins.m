function [r,subbinsize,nsubbins] = divideBins(bins,varargin)
%divideBins Sub-divide bin limits into smaller bin limits
%   [R,BINSIZE] = divideBins(BINS,N) divides bin limits in BINS into
%   N smaller bins. The N*(length(BINS)-1)+1 column vector is returned 
%   in R as well as the average sub-divided binsizes in BINSIZE.
%
%   [R,BINSIZE] = divideBins(BINS,'SubBinSize',S) attempts to break
%   BINS into sub-bins that are approximately S in size. The averaged
%   size of the actual sub-bins are returned in BINSIZE.

Args = struct('SubBinSize',0);
Args = getOptArgs(varargin,Args);

% convert bins to column vector
bins = vecr(bins);
% get length of vector
binl = length(bins);
% get size of bins
dbin = diff(bins);
if(~isempty(Args.NumericArguments))
	% specified number of subbins so figure out what their sizes will be
	nsubbins = Args.NumericArguments{1};
	% get size of subbins
	subsize = dbin / nsubbins;
elseif(Args.SubBinSize~=0)
	% specified size of subbins so figure out how many there will be
	subbinsize = Args.SubBinSize;
	% hopefully there is no reason the nbins will be different for any of
	% the frames
	nsubbins = round(mean(dbin/subbinsize));
	% get size of bins
	subsize = dbin / nsubbins;
else
	error('Please specify either number of bins or binsize to subdivide!');
end
mat1 = tril(ones(nsubbins));
mat2 = [bins(1:(binl-1)); repmat(subsize,(nsubbins-1),1)];
blimits = mat1 * mat2;
% reshape into column vector and add last point in bins
r = [reshape(blimits,[],1); bins(binl)];
subbinsize = mean(subsize);
