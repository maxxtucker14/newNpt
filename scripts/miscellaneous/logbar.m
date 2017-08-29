function hb = logbar(varargin)

Args = struct('ZeroValue',0.1);
Args = getOptArgs(varargin,Args);

hb = bar(varargin{:});
% vert = get(hb,'vertices');
% if(iscell(vert))
%     for vidx = 1:length(vert)
%         zi = find(vert{vidx}(:,2)==0);
%         vert{vidx}(zi,2) = Args.ZeroValue;
%         set(hb(vidx),'vertices',vert{vidx})
%     end
% else
% 	% find values that are zero
% 	zi = find(vert(:,2)==0);
% 	vert(zi,2) = Args.ZeroValue;
% 	set(hb,'vertices',vert);
% end
set(gca,'yscale','log');
set(hb,'BaseValue',0.1);
