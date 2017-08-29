function controlspikes = EventControl(spikes, binsize);

refrac = 1;

%Set basic parameters according to the input data
numtrials = spikes.numTrials;
trialdur = 1000 * spikes.duration;
numclusts = spikes.numClusters - 1;

bin = [0.001:0.001:binsize];

controlspikes = ispikes;
controlspikes.numClusters = numclusts;
controlspikes.numTrials = numtrials;
controlspikes.duration = spikes.duration;

for j = 1:numclusts					%For each cluster...
   fprintf('%i\n',j)
   for k = 1:numtrials				%For each trial...
      fprintf('%i ',k)
      times = spikes.trial(k).cluster(j).spikes;		%Find the spiketimes
      if ~isempty(times)
         control = [];
   		for m = 1:size(times, 2)
           	numbin = floor(times(m)/binsize);
           	b = (numbin * binsize) + bin;
         	if max(b) > trialdur
           		b = [(min(b)):0.001:trialdur];
         	end
            control = sort([control random('unif', min(b), max(b), 1, 1)]);
         end
         escape = 1;
         while escape
            if size(control, 2) > 1
               [tooclose, where, nothing] = intersect(diff(control),[0:0.001:refrac]);
               if ~isempty(tooclose)
                  control(where) = control(where) - 1;
                  escape = 1;
               else
                  escape = 0;
               end
            else
               escape = 0;
            end
         end
         controlspikes.trial(k).cluster(j).spikecount = size(control, 2);
         controlspikes.trial(k).cluster(j).spikes = control;
      else
         controlspikes.trial(k).cluster(j).spikecount = 0;
      end
   end
   fprintf('\n')
end