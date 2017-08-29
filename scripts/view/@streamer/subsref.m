function b = subsref(obj, index)
%STREAMER/SUBSREF Index function for STREAMER object.
%
%   Dependencies: @nptdata/subsref.

unknown = 0;

switch index(1).type
case '.'
	switch index(1).subs
	case 'sessionname'
		b = obj.sessionname;
	case 'channel'
		b = obj.channel;
	case 'numTrials'
		b = get(obj,'Number');
	otherwise 
		unknown = 1;
	end
otherwise
	unknown = 1;
end

if unknown == 1
	b = subsref(obj.nptdata,index);
end