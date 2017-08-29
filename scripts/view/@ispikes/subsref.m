function [b,res] = subsref(obj,index)
%ISPIKES/SUBSREF Index function for object.
%
%   Dependencies: None.

res = 1;
myerror = 0;
unknown = 0;

indlength = length(index);

switch index(1).type
case '.'
	switch index(1).subs
	case 'data'
		% if this is the only index, just return the entire thing
		if(indlength==1)
			b = obj.data;
		else
			% there are more than 1 index so pass on the subsref call
			b = subsref(obj.data,index(2:end));
		end
	otherwise 
		unknown = 1;
	end
otherwise
	unknown = 1;
end

if unknown == 1
	% pass to parent to see if they know what to do with this index
	[b,res] = subsref(obj.nptdata,index);
end
