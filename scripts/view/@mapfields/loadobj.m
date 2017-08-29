function b = loadobj(a)
%@mapfields/loadobj Modified object during load

if isa(a,'mapfields')
	b = a;
else
	% check which fields are missing
	if(~isfield(a.data,'sessions'))
		fprintf('Converting mapfields object...\n');
		% add missing fields to data structure
		c.data = a.data;
		c.data.sessions = 1;
		c.data.sessionname = {c.data.sessionname};
		c.data.presenterversion = {c.data.presenterversion};
		c.data.numRFIndex = [0; c.data.numRFs];
		b = class(c,'mapfields',a.nptdata);
	end
end
