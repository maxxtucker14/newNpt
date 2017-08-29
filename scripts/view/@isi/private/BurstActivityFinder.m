function [BurstSpikesIndex,PercBurstSpikes,MeanFR] = BurstActivityFinder(spiketrain,stimInfo,Args)
% This private isi function will calculate the bursting activity within the
% spiketrain based on the intra and inter burst intervals.

isis = diff(spiketrain);
stim_duration = stimInfo.data.framePoints(end)/stimInfo.data.catInfo.samplingrate;
MeanFR = length(spiketrain)/stim_duration;
IntraBurstInd = find(isis < Args.IntraBI);
burst_index=0;
if ~isempty(IntraBurstInd)
    for ii = 1:length(IntraBurstInd)
        if IntraBurstInd(ii) == 1
            burst_index = IntraBurstInd(ii);
        elseif IntraBurstInd(ii) == length(isis)
            burst_index = [burst_index IntraBurstInd(ii)];
        else
            if burst_index(end)+1 == IntraBurstInd(ii)
                burst_index = [burst_index IntraBurstInd(ii)];
            elseif isis(IntraBurstInd(ii)-1) > Args.InterBI
                burst_index = [burst_index IntraBurstInd(ii)];
            end
        end
    end
    if burst_index(1)==0
        burst_index(1)=[];
    end
    ex_index = find(diff(burst_index)>1);
    burst_index = sort([burst_index (burst_index(ex_index))+1 burst_index(end)+1]);
    BurstSpikesIndex = burst_index';
    PercBurstSpikes = (length(burst_index)/length(spiketrain))*100;
else
    BurstSpikesIndex = [];
    PercBurstSpikes = 0;
end