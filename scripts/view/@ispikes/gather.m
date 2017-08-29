function r = gather(obj,varargin)
%ispikes/gather Gathers ispikes objects from session directory
%   R = gather(OBJ) loops over group directories and then loops over
%   cluster directories to load ispikes objects.

Args = struct('Stub',0);
Args = getOptArgs(varargin,Args);

r = {};

% get list of groups
glist = nptDir('group*');
% get number of groups
gnum = size(glist,1);
isIndex = 1;
for i = 1:gnum
	cd(glist(i).name)
	% get cells
	clist = nptDir('cluster*');
	% get number of cells
	cnum = size(clist,1);
	for j = 1:cnum
		cd(clist(j).name)
		r{isIndex} = ispikes('auto');
		isIndex = isIndex + 1;
		cd ..
	end
	cd ..
end
