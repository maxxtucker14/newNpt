function [smean,sstd] = getStableMean(data,varargin)

Args = struct('StdThreshold',3,'ChangeThreshold',1);
Args = getOptArgs(varargin,Args);

% get rows and cols of data
[drows,dcols] = size(data);
% initialize return variable
smean = repmat(NaN,1,dcols);
sstd = repmat(NaN,1,dcols);
% create variable of column numbers so we don't have to do this inside
% the while loop
colNums = 1:dcols;

% get mean of data
dmean = mean(data);
dstd = std(data);
% get difference in mean
% diffmean = repmat(1,1,dcols);
% find columns that have stabilized
% colsdone = find(diffmean<Args.ChangeThreshold);
colsdone = [];

% if change in mean is above threshold continue to loop
while(isempty(colsdone))
	% store the means for columns that are done
	smean(colsdone) = dmean(colsdone);
    % store the std for columns that are done
    sstd(colsdone) = dstd(colsdone);
	% find columns left
	colsleft = setdiff(colNums,colsdone);
	% extract only columns left
	data = data(:,colsleft);
	% extract mean for columns left
	dmean = dmean(colsleft);
	
	% get std of data
	dstd = std(data);
	% get deviation from mean
	ddev = data - repmat(dmean,drows,1);
	% find points less than StdThreshold to keep
	ikeep = find(ddev<(Args.StdThreshold*dstd));
	data = data(ikeep);
	% store old mean
	odmean = dmean;
	% get new mean
	dmean = mean(data);
	% get difference in mean
	diffmean = dmean - odmean;
	% find columns that have stabilized
	colsdone = find(diffmean<Args.ChangeThreshold);
end
% store the means for columns that are done
smean(colsdone) = dmean(colsdone);
% store the std for columns that are done
sstd(colsdone) = dstd(colsdone);
