function obj = plot(obj,varargin)
%@mapfields/plot Plots receptive fields in MAPFIELDS object
%   OBJ = PLOT(OBJ,N,VARARGIN) plots the fields from the N-th session
%   field in the MAPSFIELD object OBJ. The following color scheme is 
%   used:
%      black for unmarked receptive fields (RFs)
%      red for real RFs
%      blue for dummy RFs
%      green for fixation
%   The optional input arguments are:
%      'Hold' - flag to add fields to current plot.
%
%   OBJ = PLOT(OBJ) plots all the fields in OBJ. 
%
%   OBJ = PLOT(OBJ,'Marked') plots only the fields that have a non-zero
%   value in their mark field. This option cannot be used with the
%   first two options.
%
%   OBJ = PLOT(OBJ,'Fix') plots only the fixation spot. This option 
%   cannot be used with the first two options.

Args = struct('Hold',0,'FromFix',0,'NoOri',0,'NoNumber',0,'Ecc',0, ...
	'UseDegrees',0,'DegreeStep',2.5,'PixelStep',50);
Args = getOptArgs(varargin,Args,'flags',{'Hold','FromFix','NoOri', ...
	'NoNumber','Ecc','UseDegrees'});
        
if(~Args.Hold)
	% clear axis by default otherwise everything gets added
	cla
end

if(Args.UseDegrees)
	% get conversion factors between pixels and degrees
	[xdeg,ydeg] = get(obj,'PixelsPerDegree');
end

% get the selected fields
fields = get(obj,varargin{:},'Indices');

if(Args.Ecc)
	if(Args.UseDegrees)
		% plot the histogram of the eccentricities
		eccd = getEccentricity(obj,'Field',fields,'UseDegrees');
		% get last bin
		lastbin = ceil(max(eccd)/Args.DegreeStep) * Args.DegreeStep;
		% set up bins in 2.5 degrees
		bins = 0:Args.DegreeStep:lastbin;
		% get histcie count
		n = histcie(eccd,bins);
		% create bar graph
		bar(bins,n,'histc')
		xlabel('Eccentricity (degrees)')
	else
		% plot the histogram of the eccentricities
		ecc = getEccentricity(obj,'Field',fields);
		% get last bin
		lastbin = ceil(max(ecc)/Args.PixelStep) * Args.PixelStep;
		% set up bins in 50 pixel steps
		bins = 0:Args.PixelStep:lastbin;
		% get histcie count
		n = histcie(ecc,bins);
		% create bar graph
		bar(bins,n,'histc')
		xlabel('Eccentricity (pixels)')
	end	
	ylabel('Number of fields')
	title('Distribution of receptive field eccentricities')
else
	if(~isempty(Args.NumericArguments))
		session = 1;
	else
		session = 0;
	end
	
	% set default field colors:
	% 1 black for unmarked RFs
	% 2 red for real RFs
	% 3 blue for dummy RFs
	% 4 green for fixation
	fieldcolors = [0 0 0; 1 0 0; 0 0 1; 0 1 0];
	
	vertices = obj.data.pts(fields,:)';
	% get value of mark for each field add 1 so we can use it as index
	% into fieldcolors
	marks = obj.data.mark(fields) + 1;
	% check type field to see which one is the fixation (its value will be 2)
	% and set that value to 3 since we will be adding to marks and an unmarked 
	% RF in marks will have a value of 1
	fix = obj.data.type(fields) * 3 / 2;
	% add marks and fix together to get index into fieldcolors since fixation
	% should not be marked so they should be mutually exclusive
	% get colors for each face created by patch
	fc = fieldcolors(marks+fix,:);
	% replicate color for all 4 vertices of each face
	fc1 = repmat(fc,[1 1 4]);
	% rearrange into correct format for patch
	vcolors = permute(fc1,[3 1 2]);
	xvals = vertices(1:2:7,:);
	yvals = vertices(2:2:8,:);
	if(Args.FromFix)
		% get cooordinates of fixation
		[fixx,fixy] = get(obj,'FixCenterXY','Field',fields);
		matfx = repmat(fixx',4,1);
		matfy = repmat(fixy',4,1);
		xvals = xvals - matfx;
		yvals = yvals - matfy;
	end
	% create patch object using odd and even rows of vertices
	patch(xvals,yvals,vcolors,'FaceAlpha',0,'EdgeColor','flat')
	if(~Args.NoNumber)
		if(session)
			% get field number for that session
			numstr = cellstr(num2str(vecc(get(obj,'SessionRFNumber','Field',fields)-1)));
		else
		   numstr = cellstr(num2str(vecc(fields-1)));
		end
		% label fields using 0-indexed values
		text(min(xvals),min(yvals),numstr,'VerticalAlignment','Bottom', ...
			'HorizontalAlignment','Right')
	end
	if(~Args.NoOri)
		% find fields that are not fixation
		fieldsi = find(obj.data.type(fields)==0);
		fields = fields(fieldsi);
		% get orientation or RFs, multiply by -1 to go from cartesian coordinates
		% to screen coordinates
		ori = deg2rad(-obj.data.ori(fields));
		% get x change
		orix = cos(ori);
		% get y change
		oriy = sin(ori);
		% get x range
		xvals = xvals(:,fieldsi);
		yvals = yvals(:,fieldsi);
		xrange = [max(xvals) - min(xvals)];
		yrange = [max(yvals) - min(yvals)];
		% get size of each RF
		range = max([xrange;yrange])' * 0.5;
		% get vector indicating orientation
		changex = range .* orix;
		changey = range .* oriy;
		% get centerx and centery
		centerx = obj.data.centerx(fields);
		centery = obj.data.centery(fields);
		if(Args.FromFix)
			centerx = centerx - matfx;
			centery = centery - matfy;
		end
		% get one end of line indicating orientation
		p1x = centerx - changex;
		p1y = centery - changey;
		% get other end of line indicating orientation
		p2x = centerx + changex;
		p2y = centery + changey;
		% draw line
		line([p1x'; p2x'],[p1y'; p2y'],'Color','k')
	end
	% make sure plot has the right aspect ratio
	axis equal
	% do some option specific formatting
	if(Args.FromFix)
		% make sure the x- and y- limits include 0, which is the fixation
		ax = axis;
		if(ax(1)>0)
			xlim([0 ax(2)])
		elseif(ax(2)<0)
			xlim([ax(1) 0])
		end
		if(ax(3)>0)
			ylim([0 ax(4)])
		elseif(ax(4)<0)
			ylim([ax(3) 0])
		end
	end
	if(Args.UseDegrees)
		% get x tick marks
		xt = get(gca,'XTick');
		% get number of tick marks
		nxt = length(xt);
		xtd1 = floor(xt(1)/xdeg);
		xtde = ceil(xt(nxt)/xdeg);
		% get step size
		xstep = round((xtde-xtd1)/nxt);
		% get limits
		xtd = xtd1:xstep:xtde;
		% convert to pixels
		xt2 = xtd * xdeg;
		% set tick marks and labels
		set(gca,'XTick',xt2,'XTickLabel',num2str(xtd(:)))
		
		% get y tick marks
		yt = get(gca,'YTick');
		% get number of tick marks
		nyt = length(yt);
		ytd1 = floor(yt(1)/ydeg);
		ytde = ceil(yt(nyt)/ydeg);
		% get step size
		ystep = round((ytde-ytd1)/nyt);
		% get limits
		ytd = ytd1:ystep:ytde;
		% convert to pixels
		yt2 = ytd * ydeg;
		% set tick marks and labels
		set(gca,'YTick',yt2,'YTickLabel',num2str(ytd(:)))
				
		xlabel('degrees')
		ylabel('degrees')
	else
		xlabel('pixels')
		ylabel('pixels')
	end
	if(session)
		title(obj.data.sessionname{Args.NumericArguments{1}})
	else
		title(obj.data.sessionname{1})
	end
	set(gca,'YDir','reverse')
end