function rejectTrials = ArtRemTrialsLFP(varargin)
% to be run into the session directory
% determine the trials in which any of the channels exceed 12 fold the
% standard deviation in the lfp.
% 
% option to use: - 'save' to save the file
%                - 'threshold',x for the x fold STD threshold 
%
% Dependencies: getOptArgs, nptDir, getDataDirs, nptReadStreamerFile

Args = struct('threshold',12,'save',0);
Args.flags = {'save'};
[Args,modvarargin] = getOptArgs(varargin,Args,'remove',{});

[pdir,cdir] = getDataDirs('lfp','relative','CDNow');

files = nptDir('*_lfp.*');
data = [];
trials = [];

for t = 1 : size(files,1)
    [lfp,num_channels,sampling_rate,scan_order,points] = nptReadStreamerFile(files(t).name);
    trials = [trials size(data,2)+1];
    data = [data single(abs(lfp))];
end

chstd = std(data,0,2);

noisyt = [];
for ch = 1 : size(data,1)
    datapoint = find(data(ch,:) > Args.threshold * chstd(ch));
    if ~isempty(datapoint)
        for d = 1 : length(datapoint)
            reject = find(trials <= datapoint(d));
            noisyt = [noisyt reject(end)];
        end
    end
end

rejectTrials = unique(noisyt); 
  
if Args.save
    save('rejectedTrials.mat','rejectTrials')
end

cd ..


