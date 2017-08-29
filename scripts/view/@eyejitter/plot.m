function obj = plot(obj,varargin)
%@eyejitter/plot Plots data from EYEJITTER object
%   OBJ = plot(OBJ,N,VARARGIN) plots the mean eye position as well
%   as the standard deviation of the cartesian distances from the
%   mean. The following optional input arguments are valid:
%      ShowRaw - flag that specifies that the raw eye position signals
%                are to be plotted as well.
%      NoHoldPlot - flag that specifies that the data from trial to trial
%                   should be replaced instead of added.
%      MaxSD - followed by number specifying the threshold
%              for the standard deviation (default: 0.35). 
%              Trials exceeding the threshold will be 
%              plotted in red.
%
%   OBJ = plot(OBJ,VARARGIN) plots the mean and standard 
%   deviation for all trials. In addition to the optional input 
%   arguments above, the following are valid:
%      Trials - followed by array specifying the trials to be plotted.
%
%   OBJ = plot(OBJ,'Responses',RESPONSES,VARARGIN) creates an
%   interpolated surface of the response at different eye positions and 
%   adds the eye position with the most number of spikes to a plot of
%   the mean and standard deviation for all trials. In addition to the
%   optional input arguments above, the following are valid:
%      mesh - flag that creates a mesh plot of the interpolated surface,
%             in addition to the RESPONSES themselves.
%      imagesc - flag that creates a 2D map of the interpolated surface.
%
%
%   OBJ = plot(OBJ,'InFields') calls eyejitter/getTrialsInFields with
%   the optional input argument 'Plot'.
%
%   obj = plot(obj,n,'ShowRaw','NoHoldPlot','MaxSD',t);
%   obj = plot(obj,['Trials',[]],'MaxSD',t);
%   obj = plot(obj,['Trials',[]],'Responses',r,'mesh','imagesc', ...
%      'MaxSD',t,'ShowRaw');
%   obj = plot(obj,'hist','MaxSD',t);

Args = struct('ShowRaw',0,'NoHoldPlot',0,'Trials',[],'Responses',[], ...
	'mesh',0,'imagesc',0,'hist',0,'InFields',0);
Args = getOptArgs(varargin,Args,'flags',{'ShowRaw','NoHoldPlot','hist', ...
					'mesh','imagesc','InFields'});

if(Args.InFields)
	getTrialsInFields(obj,varargin{:},'Plot');
	title(obj.eyes.sessionname)
	return
end

% set default variables
tl = 0;
rl = 0;
n = 0;
hchan = obj.data.hchan;
vchan = obj.data.vchan;

% if there are numeric arguments, we are probably using the first form
if(~isempty(Args.NumericArguments))
	n = Args.NumericArguments{1};
end

% get total number of trials in eyes object
ttrials = obj.eyes.numTrials;
if(isempty(Args.Trials))
	Args.Trials = (1:ttrials)';
end
% make sure Trials and Responses are the same size
if(~isempty(Args.Responses))
	tl = length(Args.Trials);
	rl = length(Args.Responses);
	if(tl~=rl)
		error('Trials and Responses vectors not the same length!')
	end
end	

% if there are responses, we need to compute response weighted eye 
% positions
if(rl>0)
	% find trials with stdev smaller than threshold
	tstdthresh = get(obj,'StableTrials',varargin{:});
	% find trials in both tstdthresh and Args.Trials
	[ptrials,ia,ib] = intersect(tstdthresh,Args.Trials);
	% get x and y means for selected trials
	x = obj.data.mean(ptrials,hchan);
	y = obj.data.mean(ptrials,vchan);
	% get responses of trials in ptrials
	z = Args.Responses(ib);
	% get range of x and y
	xmin = round(min(x));
	xmax = round(max(x));
	ymin = round(min(y));
	ymax = round(max(y));
	% get grid spanning x-, y- min and max
	[X,Y] = meshgrid(xmin:1:xmax,ymin:1:ymax);
	% create interpolated surface using spike counts at selected means
	Z = griddata(x,y,z,X,Y,'cubic');
	% compute max along columns
	[imax,i] = max(Z);
	% compute max along imax
	[zmax,xmaxi] = max(imax);
	ymaxi = i(xmaxi);
end

if( Args.mesh & (rl>0) )
	% create mesh plot for all selected trials
	mesh(X,Y,Z);
    hold on
	plot3(x,y,z,'k*')
    plot3(xmin+xmaxi-1,ymin+ymaxi-1,zmax,'g*')
    hold off
elseif( Args.imagesc & (rl>0) )
	% create imagesc plot for all selected trials
	imagesc(Z);
    hold on
    plot(xmaxi,ymaxi,'g*')
    hold off
    % set tick labels to screen coordinates
    yticks = get(gca,'YTick');
    xticks = get(gca,'XTick');
    set(gca,'YTickLabel',yticks+ymin-1);
    set(gca,'XTickLabel',xticks+xmin-1);
elseif( Args.hist )
	hist(obj,varargin{:})
else
	% if we are not plotting mesh or imagesc, we are plotting regular 2D
    if(n~=0)
        trials = n;
    else
        trials = Args.Trials;
    end
	
	% find trials with stdev smaller than threshold
	tstdthresh = get(obj,'StableTrials',varargin{:});

	% plot 2D data for selected trial(s)
	for i = trials'
		if(Args.NoHoldPlot)
			cla
        else
            hold on
		end
		if(Args.ShowRaw)
			plot(obj.eyes,i,'DataStart',obj.data.datastart(i),'DataEnd',obj.data.dataend(i), ...
				'XY',varargin{:});
		end
		hold on
		% get means and stdev for this trial
		hm = obj.data.mean(i,hchan);
		vm = obj.data.mean(i,vchan);
		nstdev = obj.data.stdev(i);
		
		% draw mean and stdev 
		if(~isempty(intersect(tstdthresh,i)))
			% plot in blue if under threshold
			plot(hm,vm,'o')
			line([hm-nstdev hm+nstdev],[vm vm])
			line([hm hm],[vm-nstdev vm+nstdev])
		else
			% plot in red if above threshold
			red = [1 0 0];
			plot(hm,vm,'ro')
			line([hm-nstdev hm+nstdev],[vm vm],'Color',red)
			line([hm hm],[vm-nstdev vm+nstdev],'Color',red)
		end
		hold off
	end
    % flip y-axis in case 'ShowRaw' is not used
    set(gca,'YDir','reverse')
	% plot peak according to griddata if necessary
	if(rl>0)
		% add peak of response weighted eye positions
        hold on
		plot(xmin+xmaxi-1,ymin+ymaxi-1,'g*')
        hold off
	end
end
title([obj.eyes.sessionname ' Eye Position Mean and Standard Deviation'])
