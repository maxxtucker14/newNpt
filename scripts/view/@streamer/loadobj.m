function b = loadobj(a)
%@Function to update old saved objects

b=a;

if ~(isa(a,'streamer'))
	fprintf('Converting streamer object...\n');
    % added numChunk (6/17/04)
    if(~isfield(a,'numChunk'))
        s.sessionname = a.seesionname;
        s.channel = a.channel;
        s.numTrials = a.numTrials;
        % reversed order of chunkSize and numChunks
        s.chunkSize = 0;
        s.numChunks = 0;
        n = nptdata(a.numTrials,1);
        b = class(s,'streamer',n);
    else
        s.sessionname = a.seesionname;
        s.channel = a.channel;
        s.numTrials = a.numTrials;
        % reversed order of chunkSize and numChunks
        s.chunkSize = a.chunkSize;
        s.numChunks = a.numChunks;
        n = nptdata(a.numTrials,1);
        b = class(s,'streamer',n);
    end   
end
