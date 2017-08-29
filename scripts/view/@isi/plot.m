function obj = plot(obj,varargin)
%isi/plot Plot function for ISI object
%   OBJ = plot(OBJ) plots the inter-spike intervals for each cell in
%   OBJ using subplots.
%
%   OBJ = plot(OBJ,N) plots the intervals for the Nth cell.
%
%   OBJ = plot(...,'Rate') plots the histogram of the instantaneous
%   firing rate instead of the inter-spike intervals.
%
%   These are the optional input arguments:
%      BinSize: Bin size in ms used to calculate the histogram 
%               (default: 0.2).
%      XMax: Maximum value in ms on the x-axis (default: 15).
%      XScale: Uses 'log' or 'linear' scales on the x-axis (default log).
%      YScale: Uses 'log' or 'linear' scales on the y-axis (default linear).
%      Overplot: Flag to plot data from all cells on the same axis.
%      Normalize: Flag to normalize instantaneous firing rate data 
%                 for each cell by its mean rate before computing
%                 the histogram.
%      SPTitleOff: Flag to turn off titles on each subplot.
%      SPXTickLabelOff: Flag to turn off x tick labels on each subplot.
%      LogSpace: Argument specifying number of histogram bins spaced 
%                logarithmically between BinSize and XMax (default: 0,
%                which uses linearly spaced bins instead).

Args = struct('BinSize',0.2,'XMax',15,'XScale','linear','YScale','log', ...
	'Rate',0,'OverPlot',0,'Normalize',0,'SPTitleOff',0,'LogSpace',0, ...
	'SPXTickLabelsOff',0,'ShowSurrogates',0,'MarkISI',[],'LabelsOff',0, ...
    'GroupPlots',1,'GroupPlotIndex',1,'Color','b','HistBins',[], ...
    'IntervalHist',0);
Args.flags = {'Rate','OverPlot','Normalize','SPTitleOff','SPXTickLabelsOff', ...
        'ShowSurrogates','LabelsOff','IntervalHist'};
Args = getOptArgs(varargin,Args);

% binedges is common to all cases so set it up here
% set up bin-edges
if(Args.LogSpace)
	% start with 0, use BinSize to determine the starting point for the
	% log-spaced bins which end with XMax
	binedges = [0 logspace(floor(log10(Args.BinSize)), ...
		ceil(log10(Args.XMax)),Args.LogSpace)];
elseif(~isempty(Args.HistBins))
    binedges = Args.HistBins;
else
	binedges = 0:Args.BinSize:Args.XMax;
end

% check if we are plotting individual isi histograms or population data
if(isempty(Args.NumericArguments))
	% plot population data
    % get number of data sets
    numSets = obj.data.numSets;
	% plotting population data
	n = 1:numSets;
	% grab data
	data = obj.data.isi(:,n);
	if(Args.Rate)
		% convert isi to seconds and take the inverse of the isi to get 
		% instantaneous rate
		data2 = (data/1000).^-1;
		if(Args.Normalize)
			% get mean rate for each cell
			meanrate = nanmean(data2);
			% normalize by mean rate
			data3 = data2 ./ repmat(meanrate,size(data,1),1);
			counts = histcie(data3,binedges,'DataCols');
		else
			counts = histcie(data2,binedges,'DataCols');
        end
    elseif(~Args.IntervalHist)
		counts = histcie(data,binedges,'DataCols');
	end
	if(Args.OverPlot)
		if(Args.Rate)
            stairs(binedges,counts,Args.Color)
			set(gca,'XScale',Args.XScale,'YScale',Args.YScale);
            title(['Normalized Instantaneous Rate for ' num2str(numSets) ' cells'])
            xlabel('Normalized Instantenoues Rate (Hz)')
            ylabel('Counts')
		end
    else
        if(Args.IntervalHist)
            for index = 1:numSets
                if(numSets>1)
                    nptSubplot(numSets,index);
                end
                % get intervals for one cell
                inti = obj.data.isi(:,index);
                % call subfunction to compute and plot 2D histogram
                IntervalHist(inti,binedges)
            end
        else
            for index = 1:numSets
                if(numSets>1)
                    nptSubplot(numSets,index);
                end
                stairs(binedges,counts(:,index),Args.Color)
                set(gca,'XScale',Args.XScale,'YScale',Args.YScale);
                xlim([0 Args.XMax])
                if(~Args.SPTitleOff)
                    title(getDataDirs('ShortName','DirString',obj.data.setNames{index}));
                else
                    title(num2str(index))
                end
                if(Args.SPXTickLabelsOff)
                    set(gca,'XTickLabel','');
                end
                if(Args.LabelsOff)
                    set(gca,'YTickLabel','')
                end
            end
        end
        if(numSets>1)
			% select the bottom-left subplot
			nptSubplot(numSets,'BottomLeft');
        end
		if(Args.Rate)
			if(Args.Normalize)
				xlabel('Normalized Rate (Hz)');
			else
				xlabel('Instantaneous Rate (Hz)');
			end
		else
			xlabel('ISI (ms)')
		end
		if(Args.SPXTickLabelsOff)
			set(gca,'XTickLabel',get(gca,'XTick'));
		end
		ylabel('Counts')
    end
else
	% plot selected data sets
	n = Args.NumericArguments{1};
	% grab data
	data = obj.data.isi(:,n);
    % grab surrogate data if necessary
    if(Args.ShowSurrogates)
        % save current directory and then go to the appropriate directory
        cwd = pwd;
        cd(obj.data.setNames{n});
        % load the surrogate data if it is already computed or compute it and 
        % save it if it has not been computed
        data = getSurrISI(obj,varargin{:});
        % return to previous directory
        cd(cwd)
    end
	if(Args.Rate)
		% convert isi to seconds and take the inverse of the isi to get 
		% instantaneous rate
		data2 = (data/1000).^-1;
		counts = histcie(data2,binedges,'DataCols');
        stairs(binedges,counts)
		set(gca,'XScale',Args.XScale,'YScale',Args.YScale);
		xlim([0 Args.XMax])
        if(~Args.LabelsOff)
            title(getDataDirs('ShortName','DirString',obj.data.setNames{n}));
            xlabel('Instantaneous Rate (Hz)')
            ylabel('Counts')
        end
    elseif(Args.IntervalHist)
        % get intervals for one cell
        inti = obj.data.isi(:,n);
        % call subfunction to compute and plot 2D histogram
        IntervalHist(inti,binedges);
	else
		counts = histcie(data,binedges,'DataCols');
		% plot histogram of the data
		% use stairs instead of plot so it is clearer where the binedges 
        % for the histogram were
        stairs(binedges,counts)
		if(Args.ShowSurrogates)
			% calculate mean and std of surrogate values
			scounts = counts(:,2:end)';
			cmean = nanmean(scounts)';
			cstd = nanstd(scounts)';
			hold on
			% plot mean and std for surrogate data
			plot(plotbins,[cmean+cstd cmean-cstd])
			hold off
		end
		set(gca,'XScale',Args.XScale,'YScale',Args.YScale);
        if(strcmp(Args.XScale,'linear'))
    		xlim([0 Args.XMax])
        else
            % XScale is log, so since first value in binedges is always 
            % 0, the first value in counts won't be plotted with a step
            % so we will just draw a line from the current lower limit 
            % to the second value in binedges
            ax1 = axis;
            line([ax1(1) binedges(2)],[counts(1) counts(1)])
        end
        if(~Args.LabelsOff)
            title(getDataDirs('ShortName','DirString',obj.data.setNames{n}));
            xlabel('ISI (ms)')
            ylabel('Counts')		
        end
        xtime = Args.MarkISI;
		if(~isempty(xtime))            
            % get axis limits
            ax1 = axis;
            line([xtime xtime],ax1(3:4),'Color','r')
        end
    end
end

zoom on

function IntervalHist(inti,binedges)
% remove the nan padding
inti2 = inti(~isnan(inti));
% get the total number of intervals
inti2l = length(inti2);
% create 2D matrix of consecutive intervals
intiseq = 2:(inti2l-1);
intmat = [inti2([1 intiseq]) inti2([intiseq inti2l])];
% take 2D histogram
hist2d = histn(intmat,[binedges; binedges]');
% get length of binedges
bel = length(binedges);
% drop the last bin as it contains counts outside binedges
belind = 1:(bel-1);
imagesc(hist2d(belind,belind))
set(gca,'YDir','normal')
