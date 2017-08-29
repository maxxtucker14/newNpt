function b = loadobj(a)
%@ispikes/nptdata Function to update old saved objects

% constants
holdAxis = 1;

b = a;

if ~(isa(a,'ispikes'))
	fprintf('Converting ispikes object...\n');
	% ispikes now inherits from nptdata directly instead of inheriting
	% from streamer so check if there is a streamer object
	if(isfield(a,'streamer'))
		c.data = a.data;
		if(a.data.numChunks)
			nd = nptdata(a.data.numChunks,holdAxis);
		else
			nd = nptdata(a.data.numTrials,holdAxis);
		end
		b = class(c,'ispikes',nd);
	end
end
