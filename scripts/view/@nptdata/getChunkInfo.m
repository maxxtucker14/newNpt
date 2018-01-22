function  [numChunks,chunkSize] = getChunkInfo(sessionname,chunkSize)

pdir = pwd;
p = getDataDirs('session');
cd(p)
filelist = nptDir([sessionname '.bin']);
if ~isempty(filelist)
	[num_channels,sampling_rate,scan_order]=nptReadStreamerFileHeader(filelist(1).name);
	chunkSize = ceil(chunkSize); %round up to the nearest second
	numChunks = ceil((filelist(1).bytes-73)/2/num_channels/(chunkSize*sampling_rate)); 
	cd(pdir)
else
	chunkSize = 0;
	numChunks = 0;
end
