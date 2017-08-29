function [b,res] = subsref(obj,index)
%CHECKSYSTEM/SUBSREF Index method for CHECKSYSTEM object
%
%   Dependencies: None.

myerror = 0;
unknown = 0;
res = 1;

il = length(index);
if il>0 & strcmp(index(1).type,'.')
	switch index(1).subs
	case 'sessions'
		b = obj.sessions;
	case 'path'
		if il==1
			b = obj.path;
		elseif strcmp(index(2).type,'()')
			if il==2
				b = obj.path{index(2).subs{:}};
			else
				myerror = 1;
			end
		else
			myerror = 1;
		end
	otherwise
		unknown = 1;
	end
else
	unknown = 1;
end

if unknown == 1
	% pass to parent to see if they know what to do with this index
	[b,res] = subsref(obj.nptdata,index);
end

if (myerror == 1) | (res == 0)
	if isempty(inputname(1))
		% means some other function is calling this function, so we 
		% just return error instead of printing error
		res = 0;
		b = 0;
	else
		error('Invalid field name')
	end
end
