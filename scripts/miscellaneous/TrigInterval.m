% TrigInterval - script to compare the trigger intervals in a 
% continuous recording to the trial intervals of a trial-based recording.
% Both file types need to be in the same folder
% In command line, set trial = number of trials in session,
% session = 'session name',
% trigChan = num of trigger in continuous data,
% trigChannel = num of trigger in trial-based data, and
% syncChannel = num of sync in trial-based data.

[data,nc,sr,so,points] = nptReadStreamerFile([session '.bin']);
[triggers,tIntervals,sMean,sStd,sMax,sMin,sMinI] = nptComputeSyncDataStats(data(trigChan,:));
evens = 2:2:(size(tIntervals, 1));
odds = 1:2:(size(tIntervals, 1));
TrigInt = tIntervals(odds);
ITI = tIntervals(evens);
fprintf('Num triggers = %i\n',(size(triggers, 1)))

minSync = 352;
trigLength = 305;
threshold = 2500;
samplesPerMS = 30;
[results,imins,pmins,resSort,eSort] = nptCheckExpSystem(session,trial,syncChannel,minSync,trigChannel,trigLength,threshold,samplesPerMS);

figure
plot(results(:,3),'b.')
hold on
plot(TrigInt/30,'r.')
title('Trial length (blue), Trigger Interval (red) (in ms)')
hold off