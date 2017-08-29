function time = StretchTimes(time,num_spikes,duration)
%times = StretchTimes(times,num_spikes,duration)
%
%this function stretches the times for each trial by duration
%so that they are in consequetive order when passed into the sorting
%program.
%times is a column of timestamps
%num_spikes is a row vector of num of spikes per trial
%duration is the duration that each trial is stretched by.
%
%times are integers in microseconds
%durations are in seconds

duration=duration*10^6;

start=1;
for i=1:length(num_spikes)
    endex = sum(num_spikes(1:i));
    time(start:endex) = time(start:endex)+duration*(i-1);
    start = start + num_spikes(i);
end
