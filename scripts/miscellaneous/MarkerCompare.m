function [lengthCompare, dTrials] = MarkerCompare(markerfile, results)
%MarkerCompare  Compares Control Markers (a '.mrk' file) to the 
%   Streamer-recorded trial lengths (as contained in the "results" matrix 
%   produced by nptCheckExpSystem).
%   The output variable lengthCompare is a matrix with the following columns:
%     [Trial number
%      Trigger-adjusted streamer trial duration (from nptCheckExpSystem)
%      Trigger-adjusted control trial duration (from the .mrk file)
%      Difference between the two durations, where a positive number
%      indicates that the streamer duration was longer]
%   dTrials contains the trials which differed and the size (in ms) of the diff.
%   dtrials can be plotted with PlotExpSystemResults by including it
%   as the fourth argument.

%Get the trial markers
markers = ReadMarkerFile(markerfile);
tmarkers = MarkersToTrials(markers);

% set column numbers of 'results' so we can change more easily
indexC = 1;
numChanC = 2;
trialLengthC = 3;
triggerLengthC = 4;
maxMC = 5;
minMC = 6;
maxDC = 7;
minDC = 8;
trigEndC = 9;
iLeavedC = 10;

% get trials from the 1st column of results, and the number of trials marked.
trial = results(:,1);
records = size(tmarkers, 2);

% check to make sure that the number of trials marked and trials recorded match.
if trial ~= records
   fprintf('Number of trials recorded: %i .  Number of trials marked: %i.\n', trial, records);
   return
end

%Putting the endmarkers from each trial marker into 'endmarkers'
endmarkers = [];
for i = 1:length(trial)
   lastmarker = size(tmarkers(i).markers, 1);
   endmarker = tmarkers(i).markers(lastmarker,2);
   endmarkers = [endmarkers; (endmarker-10)];   %Removing the trigger duration
end

%Removing the trigger duration from the 'Results' trial lengths
trialLength = results(:,trialLengthC) * 30;
triggerLength = results(:,triggerLengthC);
tLength = trialLength - triggerLength;
%Rounding the trial lengths from 'Results' to 1 kHz precision
streamerLength = round(tLength/30);
%Finding the differences between the streamer and control trial durations
lengthDiff = streamerLength - endmarkers;

lengthCompare = [trial streamerLength endmarkers lengthDiff];

diffTrials = find((lengthDiff < -1) | (lengthDiff > 1));
dtn = length(diffTrials);
dTrials = [diffTrials lengthDiff(diffTrials)];
fprintf('Num. of trials w/diff. durations from Control and Streamer: %i\n',dtn);

%figure
%plot(trial, streamerLength,'.')
%hold on;
%plot(trial, endmarkers, 'ro')
%hold off;
