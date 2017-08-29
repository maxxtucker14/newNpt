function [n,x,nbins,xcenter,ycenter] = hist(obj,varargin)
%@eyejitter/hist Compute 2D histogram on EYEJITTER data
%   [N,X,NBINS] = hist(OBJ,VARARGIN) returns the 2D histogram of the
%   mean positions. If no output arguments are provided, the data is
%   plotted using a mesh plot.
%
%   The optional input arguments are:
%      'MaxSD' - followed by value specifying the
%                threshold for the standard deviation of
%                the eye position (default: 0.35).
%      'XBinSize' - followed by size of bins for x (default: 1).
%
%      'YBinSize' - followed by size of bins for y (default: 1).
%
%      'BinSize' - followed by size of bins for x and y.
%
%      'ImageSC' - flag to indicate that the plot should be created
%                  using imagesc instead of mesh.
%   [n,x,nbins] = hist(obj,'MaxSD',0.35,'XBinSize',1, ...
%      'YBinSize',1,'BinSize',1,'ImageSC');

Args = struct('XBinSize',1,'YBinSize',1,'ImageSC',0, ...
    'Contour',0,'ContourLevels',[],'Interp',0,'HistExp',1,'Centroid',0, ...
    'Oversample',10,'GaussianSize',10,'GaussianSigma',2,'Percentile',95);
Args = getOptArgs(varargin,Args,'aliases',{'BinSize',{'XBinSize','YBinSize'}}, ...
			'flags',{'ImageSC','Contour','Interp','Centroid'});

% select trials with stdev within threshold and get means
% means will be in [x y]
[trials,m] = get(obj,'StableTrials',varargin{:});
% switch the columns since histn returns the counts for the first column in
% rows and it would be more natural if that corresponded to y values
m = fliplr(m);
xcol = 2;
ycol = 1;
% get min and max of m round down and up respectively to get integer
% make sure we are taking min and max across rows so this will work even if
% there is only 1 row of points
yxmin = floor(min(m,[],1));
yxmax = ceil(max(m,[],1));
ybins = yxmin(ycol):Args.YBinSize:yxmax(ycol);
xbins = yxmin(xcol):Args.XBinSize:yxmax(xcol);
bins = concatenate(ybins,xbins)';
[n1,x1,nbins1] = histn(m,bins);

% find center of eye positions
if(Args.Centroid)
	% remove mean
	% n1m = n1 - mean(n1(:));
	% oversample image
	n2 = imresize(n1,Args.Oversample);
	% create 2D Gaussian
	f = TwoDimGaussFilter(Args.GaussianSize*Args.Oversample,Args.GaussianSigma);
	% smooth image with gaussian
	n3 = imfilter(n2,f,'same');
	% demean again and take absolute value
	% n4 = abs(n3-mean(n3(:)));
	% find peak
	[Max,row,col] = max2(n3);
	% find 99th percentile
	threshold = prctile(n3(:),Args.Percentile);
	bw = roicolor(n3,threshold,Max);
	bw = bwselect(bw,col,row);
	stats = regionprops(bwlabel(bw),'Centroid');
	xmean = round(stats.Centroid(1)/Args.Oversample);
	ymean = round(stats.Centroid(2)/Args.Oversample);
else
	% create x-, y-grids
	[X,Y] = meshgrid(1:nbins1(xcol),1:nbins1(ycol));
	% raise n1 to HistExp power to emphasize peaks
	n2 = n1.^Args.HistExp;
	% get total number of trials in n1
	n2sum = sum(n2(:));
	% get weighted x position
	wx = n2 .* X;
	% get mean x position
	xmean = round(sum(wx(:))/n2sum);
	% get weighted y position
	wy = n2 .* Y;
	% get mean y position
	ymean = round(sum(wy(:))/n2sum);
end

% if there were no output arguments, behave like hist and plot the histogram
if(nargout==0)
	if(Args.ImageSC)
		imagesc(n1)
		% colorbar
		set(gca,'YDir','reverse')
		hold on
		plot(xmean,ymean,'w*')
        if(Args.Centroid)
            contour(imresize(bw,1/Args.Oversample),Args.ContourLevels)
        end
		hold off
    elseif(Args.Contour)
    	if(Args.Interp)
    		n1 = interp2(n1);
    	end
    	if(strcmp(Args.ContourLevels,'integer'))
    		contour(n1,1:max(n1(:)))
    	elseif(~isempty(Args.ContourLevels))
    		contour(n1,Args.ContourLevels)
    	else
	        contour(n1)
	    end
		set(gca,'YDir','reverse')
	else
		mesh(n1)
	end
	% set tick labels to screen coordinates
	yticks = get(gca,'YTick');
	xticks = get(gca,'XTick');
	set(gca,'YTickLabel',yticks+yxmin(ycol)-1,'XTickLabel',xticks+yxmin(xcol)-1)
else
	% set output arguments - need to do this otherwise outputs will
	% get returned when there are no output arguments as well
	n = n1;
	x = x1;
	nbins = nbins1;
	xcenter = xbins(xmean);
	ycenter = ybins(ymean);
end
