function [r,varargout] = getTrialsInFields(obj,varargin)
%eyejitter/getTrialsInFields Determines trials with acceptable eye-jitter
%   T = getTrialsInFields(OBJ) returns trial numbers with stable eye
%   positions within the limits of receptive fields with mark 0 from
%   the center of the scatter in eye positions. 
%
%   T = getTrialsInFields(OBJ,'FieldMark',M) uses the fields marked with
%   M instead of 0.
%
%   getTrialsInFields(OBJ,'Plot') plots the marked receptive fields,
%   along with the intersection of the two fields on top of the mean 
%   eye positions from stable trials to indicate which are included
%   and which are excluded.
%
%   [T,F] = getTrialsInFields(OBJ,'ReturnFractionIn') returns the
%   fraction of included trials.
%
%   [T,TO] = getTrialsInFields(OBJ,'ReturnTrialsOut') returns the
%   trial numbers for the excluded trials.

Args = struct('Plot',0,'ReturnFractionIn',0,'ReturnTrialsOut',0, ...
	'FieldMark',0,'Radius',[],'RadiusDegrees',[]);
Args = getOptArgs(varargin,Args,'flags',{'Plot','ReturnFractionIn', ...
        'ReturnTrialsOut'});

% load mapfields object
mf = mapfields('auto',varargin{:});

% if RadiusDegrees is specified, convert it to pixels
if(~isempty(Args.RadiusDegrees))
	% get the conversion factor between pixels and degrees
	deg2pix = get(mf,'PixelsPerDegree');
	% take the mean of the x- and y- conversion factors
	Args.Radius = mean(deg2pix(:)) * Args.RadiusDegrees;
end

% get eye position for each trial that has reasonable standard deviation
[trialn,epos] = get(obj,varargin{:},'StableTrials');

% get center of eyejitter object
ejcenter = get(obj,varargin{:},'CenterXY');

if(~isempty(Args.Radius))
	% find distance of trials to ejcenter
	ejx = epos(:,1) - ejcenter(1);
	ejy = epos(:,2) - ejcenter(2);
	ejdistance = sqrt(ejx.^2 + ejy.^2);
	% find points within radius
	in1 = find(ejdistance<=Args.Radius);
	in0 = find(ejdistance>Args.Radius);
	% return trial numbers
	r = trialn(in1);
	if(Args.Plot)
		% plot included points
		plot(epos(in1,1),epos(in1,2),'g.')
		hold on
		% plot excluded points
		plot(epos(in0,1),epos(in0,2),'.')
		% plot circle
		diam = 2 * Args.Radius;
		rectangle('Position',[ejcenter(1)-Args.Radius ...
			ejcenter(2)-Args.Radius,diam,diam],'Curvature',1);
		hold off
		axis equal
	end
else
	% get points for marked fields
	pts = get(mf,'Points','Mark',Args.FieldMark);
	% get center of marked fields
	mfcenter = get(mf,'CenterXY','Mark',Args.FieldMark);
	% get polygon points with respect to center
	pcpts = pts - repmat(mfcenter,1,4);
	
	% check size of pts
	[prows,pcols] = size(pts);
	% get polygon centered on center of eyejitter object
	pcenter = pcpts + repmat(ejcenter,prows,4);
	
	% if there is only 1 field, use that field's pts to determine which
	% points are within the field
	if(prows==1)
		% reshape into x and y columns
		pxy = reshape(pcenter,2,[]);
		% close the polygon by adding the 1st column to the end
		pxy = [pxy pxy(:,1)];
		% get points in pcenter
		inVector = inpolygon(epos(:,1),epos(:,2),pxy(1,:),pxy(2,:));
		in1 = find(inVector);
		% get excluded points
		in0 = find(~inVector);
		% return trial number of included points
		r = trialn(in1);
		if(Args.Plot)
			% plot included points
			plot(epos(in1,1),epos(in1,2),'g.')
			hold on
			% plot excluded points
			plot(epos(in0,1),epos(in0,2),'.')
			% plot polygon
			plot(pxy(1,:),pxy(2,:))
			hold off
		end
	elseif(prows>1)
		% more than 1 field marked so we have to find the intersection 
		% polygon
		% get the first polygon
		pxy1 = reshape(pcenter(1,:),2,[])';
		% close the polygoin by adding the 1st column to the end
		% pxy1 = [pxy1; pxy1(1,:)];
		pxy1 = checkpoly(pxy1);
		% plot polygon now otherwise we will have to recreate them later
		if(Args.Plot)
			% close the polygon for plotting purposes
			plot([pxy1(:,1); pxy1(1,1)],[pxy1(:,2); pxy1(1,2)])
			hold on
			colorOrder = get(0,'defaultaxescolororder');
			cindex = 2;
		end
		for i = 2:prows
			% get the next polygon
			pxyn = reshape(pcenter(i,:),2,[])';
			% close the polygon
			% pxyn = [pxyn; pxyn(1,:)];
			pxyn = checkpoly(pxyn);
			if(Args.Plot)
				plot([pxyn(:,1); pxyn(1,1)],[pxyn(:,2); pxyn(1,2)],'Color',colorOrder(cindex,:))
				cindex = cindex + 1;
			end
			% find the intersection between pxy1 and pxyn
			pxy1 = convex_intersect(pxy1,pxyn);
		end
		% get points in polygon
		inVector = inpolygon(epos(:,1),epos(:,2),pxy1(:,1),pxy1(:,2));
		in1 = find(inVector);
		in0 = find(~inVector);
		% return trial numbers 
		r = trialn(in1);
		if(Args.Plot)
			% plot included points
			plot(epos(in1,1),epos(in1,2),'g.')
			% plot excluded points
			plot(epos(in0,1),epos(in0,2),'.')
			% plot intersection polygon
			plot([pxy1(:,1); pxy1(1,1)],[pxy1(:,2); pxy1(1,2)],'Color',colorOrder(cindex,:))
			hold off
		end
	else
		error('No marked fields found!');
	end
end
% figure out what else to return
% initialize varargout index
argi = 1;
if(Args.ReturnFractionIn)
    varargout{argi} = length(in1)/size(epos,1);
    argi = argi + 1;
end
if(Args.ReturnTrialsOut)
    varargout{argi} = trialn(in0);
    argi = argi + 1;
end
