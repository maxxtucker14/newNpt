function times = ConvertTimes(times,duration,binsize,samplingRate)



for count=1:length(times)
    spiketrial = floor(times(count)/duration);
    spiketime = times(count) - spiketrial*duration + spiketrial*binsize*(10^6)/samplingRate;
    times(count) = spiketime;
end
