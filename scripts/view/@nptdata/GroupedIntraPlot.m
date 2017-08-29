function GroupedIntraPlot(obj,varargin)

Args = struct('PatchColor',0.75);
[Args,varargin2] = getOptArgs(varargin,Args);

gind = groupDirs(obj);
% get number of rows in gind
[gindrows,gindcols] = size(gind);
% drop the first limit since we are going to put a patch object
% behind the even numbered groups and then subtract 0.5 from 
% each limit. 
if(rem(gindcols,2)==1)
	% find limits of groups
	glimits = gind(1,:);
	glend = gindcols;
else
	% find limits of groups
	glimits = [gind(1,:) get(obj,'Number')+1];
	glend = gindcols+1;
end
glimits2 = glimits(2:glend)-0.5;
% Replicate the limits in a second row so we can
% reshape to get columns of [x0; x0; x1; x1] which will allow
% us to plot the patch objects all at once
bpx = reshape(repmat(glimits2,2,1),4,[]);
% get the y values which will go from -1 to 1
glcols2 = (glend - 1)/2;
ylimits = ylim';
% bpy = repmat([-1; 1; 1; -1],1,glcols2);
bpy = repmat([ylimits; flipud(ylimits)],1,glcols2);
% draw patch objects
patch(bpx,bpy,repmat(Args.PatchColor,1,3),'LineStyle','none')
chi = get(gca,'Children');
set(gca,'Children',flipud(chi),'TickDir','out');
% redraw the top and bottom axis since the patch object seems
% to obsure it
cax = axis;
line(repmat(cax(1:2)',1,2),repmat(cax(3:4),2,1),'Color','k')
