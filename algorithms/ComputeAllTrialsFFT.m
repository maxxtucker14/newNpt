function allfft = ComputeAllTrialsFFT(channel,linenoise)

dirlist = dir(['*.0*']);
trials = size(dirlist,1);
for i = 1:trials
   fprintf('Trial %i of %i\n',i,trials);
    [data,num_channels,sampling_rate,scan_order]=nptReadStreamerFile(dirlist(i).name);
    if linenoise==1
        b = nptRemoveLineNoise(data(channel,:),60,sampling_rate);
    elseif linenoise==0
        b = data(channel,:);
    end
   f = nptFFT(b,sampling_rate);
   if i==1
       allfft = f;
       la = length(allfft);
   end
   lf = length(f);
   if lf<la
       allfft = allfft(1:lf) + f;
       la = lf;
   else
       allfft = allfft + f(1:la);
   end
end
allfft = allfft/trials;
