function b = loadobj(a)
%@eyejitter/loadobj Modifies object during load

if isa(a,'eyejitter')
	% changes beyond the first level are not visible so we should check
	% in there to see if there are fields missing
	if(~isfield(a.data,'hchan'))
		b = UpdateObject(a);
	else
		b = a;
	end
else
	% check to see what is missing
	if(~isfield(a.data,'hchan'))
		b = UpdateObject(a);
	end
end

function b = UpdateObject(a)

% create new structure without parent objects
c.data.datastart = a.data.datastart;
c.data.dataend = a.data.dataend;
c.data.mean = a.data.mean;
c.data.stdev = a.data.stdev;
% this change added hchan, vchan and onsetArg fields
c.data.hchan = 2;
c.data.vchan = 1;
c.data.onsetArg = 'PresenterTrigger';
fprintf('Converting eyejitter object...\n');
b = class(c,'eyejitter',a.eyes);
