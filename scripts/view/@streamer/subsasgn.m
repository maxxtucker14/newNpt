function obj = subsref(obj,index,value)
%STREAMER/SUBSASGN Assignment function for STREAMER object.
%
%   Dependencies: @nptdata/subsasgn.

unknown = 0;

switch index(1).type
case '.'
	switch index(1).subs
	case 'sessionname'
		obj.sessionname = value;
	case 'channel'
		obj.channel = value;
	case 'numTrials'
		obj.nptdata.number = value;
	otherwise 
		unknown = 1;
	end
otherwise
	unknown = 1;
end

if unknown == 1
	obj.nptdata = subsasgn(obj.nptdata,index,value);
end