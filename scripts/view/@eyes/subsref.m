function [b,res] = subsref(obj, index)
%EYES/SUBSREF Index function for EYES object.
%
%   Dependencies: @nptdata/subsref.

res = 1;
unknown = 0;

switch index(1).type
case '.'
	switch index(1).subs
	case 'sessionname'
		b = obj.sessionname;
    case 'channel'
        b = obj.channel;
    case 'numTrials'
        b = obj.nptdata.number;
    
    otherwise 
        unknown = 1;
end
otherwise
	unknown = 1;
end

if unknown == 1
	[b,res] = subsref(obj.nptdata,index);
end

if res == 0
	if isempty(inputname(1))
		% means some other function is calling this function, so
		% just return error instead of printing error
		res = 0;
		b = 0;
	else
		error('Invalid field name');
	end
end
