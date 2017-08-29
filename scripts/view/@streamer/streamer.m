function sdata = streamer(varargin)
%STREAMER Constructor function for the STREAMER class
%   S = STREAMER(SESSIONNAME,CHANNEL) instantiates a STREAMER object
%   using the signal specified by CHANNEL in the data file
%   SESSIONNAME.0001.  This function automatically cds to the
%   session directory. Additionally if the sessionname
%   contains a 'highpass' or 'lfp' string then it automatically goes to that
%   directory instead.  A directory listing is performed to determine
%   the number of trials in the session.  
%
%
%   S = STREAMER(SESSIONNAME,CHANNEL,NUMBER_TRIALS) also instantiates a
%   STREAMER object but it takes the number of trials as an argument
%   instead of performing a directory listing.
%
%   The object contains the following fields:
%      SDATA.sessionname
%      SDATA.channel
%      SDATA.numTrials
%      SDATA.holdaxis
%      SDATA.chunkSize
%      SDATA.numChunks
%
%   Dependencies: nptdata.




% property of nptdata base class
holdAxis = 1;

[p,cdir] = getDataDirs('session','CDNow');

if(nargin==0)
    sdata = CreateEmptyStreamerObject;
elseif( (nargin==1) & (isa(varargin{1},'streamer')) )
    sdata = varargin{1};
else
    if findstr(varargin{1},'highpass')
        [p,cdir] = getDataDirs('highpass','CDNow');
    elseif findstr(varargin{1},'lfp')
        [p,cdir] = getDataDirs('lfp','CDNow');
     end
        
    switch(nargin)
        case 1
            warning('Does not make sense to just have a sessioname without a channel.')
            sdata = CreateEmptyStreamerObject;
        case 2
            s.sessionname = varargin{1};
            s.channel = varargin{2};
            % initialize fields so the order of the fields won't change
            s.numTrials = 0;
            s.chunkSize = 0;
            s.numChunks = 0;
            % get list of files
            filelist = nptDir([s.sessionname '*.0*']);
            if ~isempty(filelist)
                s.numTrials = size(filelist,1);
            else
                [s.numChunks,s.chunkSize] = getChunkInfo(s.sessionname)
            end
            if s.numChunks
                n = nptdata(s.numChunks,holdAxis,p);
            else
                n = nptdata(s.numTrials,holdAxis,p);
            end
            sdata = class(s,'streamer',n);
        case 3
            s.sessionname = varargin{1};
            s.channel = varargin{2};
            s.numTrials = varargin{3};
            s.chunkSize = 0;
            s.numChunks = 0;
            n = nptdata(s.numTrials,holdAxis,p);
            sdata = class(s,'streamer',n);
        case 4
            s.sessionname = varargin{1};
            s.channel = varargin{2};
            s.numTrials = varargin{3};
            [numChunks,chunkSize] = getChunkInfo(s.sessionname,varargin{4});
            holdAxis = 0;
            s.chunkSize = chunkSize;
            s.numChunks = numChunks;
            if s.numChunks
                n = nptdata(s.numChunks,holdAxis,p);
            else
                n = nptdata(s.numTrials,holdAxis,p);
            end
            sdata = class(s,'streamer',n);
        otherwise
            error('Wrong number of input arguments')
    end
end



function obj = CreateEmptyStreamerObject
% property of nptdata base class
holdAxis = 1;

s.sessionname = '';
s.channel = 1;
s.numTrials = 0;
s.chunkSize = 0;
s.numChunks = 0;
n = nptdata(0,holdAxis);
obj = class(s,'streamer',n);
