function  [numChunks,chunkSize] = getChunkInfo(sessionname,varargin)
%[numChunks,chunkSize] = getChunkInfo(sessionname,chunkSize)
%
%reads the streamer file in the session dir to figure out how many chunks
%of data are in it.
if nargin>1
    chunkSize=varargin{1};
end

pdir = pwd;
p = getDataDirs('session');
cd(p)
filelist = nptDir([sessionname '.bin']);
if isempty(filelist)
    warning('Could not find streamer file.')
    numChunks=0;
    chunkSize=0;
    cd(pdir)
else
    dtype = DaqType(filelist(1).name);
    if strcmp(dtype,'Streamer')
        [num_channels,sampling_rate,scan_order]=nptReadStreamerFileHeader(filelist(1).name);
        headersize = 73;
        if ~exist('chunkSize','var')
            chunkSize=17;
        end

    elseif strcmp(dtype,'UEI')
        data = ReadUEIFile('FileName',filelist(1).name,'Header');
        sampling_rate = data.samplingRate;
        num_channels = data.numChannels;
        headersize = 90;
        if ~exist('chunkSize','var')
            chunkSize=1;
        end
    else
        error('unknown file type')
    end
    if length(chunkSize)>1
        chunkSize = chunkSize(2)/sampling_rate;
    end
    chunkSize = ceil(chunkSize); %round up to the nearest second
    numChunks = ceil((filelist(1).bytes-headersize)/2/num_channels/(chunkSize*sampling_rate));
    cd(pdir)
end



