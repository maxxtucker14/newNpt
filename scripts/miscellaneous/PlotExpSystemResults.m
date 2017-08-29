function [iTrials,eTrials] = PlotExpSystemResults(results,dmins,mmins,varargin)
%PlotExpSystemResults Plot results from nptCheckExpSystem
%   [ITRIALS,ETRIALS] = PlotExpSystemResults(RESULTS,DMINS,MMINS,
%      TRIG_LENGTH,THRESHOLD) plots the results returned from 
%   nptCheckExpSystem and returns ITRIALS, which are the trial
%   numbers containing interleaved data, and ETRIALS, which are
%   the trial numbers missing end triggers. TRIG_LENGTH and 
%   THRESHOLD are optional arguments. The default values are 305
%   (data points) and 2500 (mV) respectively.
%
%   Dependencies: None.

% set default values of trigLength and threshold
trigLength = 305;
threshold = 2500;

% get optional arguments if present
if nargin>3
   trigLength = varargin{1};
end
if nargin>4
   threshold = varargin{2};
end

% set column numbers so we can change more easily
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

% get trials from the 1st column
trial = results(:,1);

% get number of columns in results
rC = size(results,2);
% check to make sure we have the right number of columns
if rC~=iLeavedC
	fprintf('Incorrect number of columns: %i instead of %i.\n',rC,iLeavedC);
	iTrials = [];
	eTrials = [];
	return
end

% set number subplots so we don't have to change every subplot 
% command when we change the number of subplots
% avoid errors, clear each axis before plotting
% don't want to do clf since this is used by InspectGUI when 
% plotting checksystem objects
n = 6; i = 1;
subplot(1,n,i)
cla
plot(trial, results(:,numChanC),'.')
title('Number of channels')
zoom on
i = i + 1; subplot(1,n,i)
cla
plot(trial, results(:,trialLengthC),'.')
hold on
eTrials = find(results(:,trigEndC)<threshold);
plot(eTrials,results(eTrials,trialLengthC),'r.')
hold off
title('Trial length (ms)')
zoom on
i = i + 1; subplot(1,n,i)
cla
plot(trial, results(:,triggerLengthC),'.')
title('Control trigger pts')
zoom on
i = i + 1; subplot(1,n,i)
cla
plot(trial, results(:,maxMC:minDC),'.')
title('Max+Min pts b/w syncs')
zoom on
i = i + 1; subplot(1,n,i)
cla
plot(trial, results(:,trigEndC),'.')
hold on
iTrials = find(results(:,iLeavedC));
plot(iTrials, results(iTrials,trigEndC),'r.')
hold off
title('End Trigger/Interleaved')
% grab the axis since the next plot might not have all trials
ax1 = axis;
zoom on
i = i + 1; subplot(1,n,i)
cla
if ~isempty(dmins)
   plot(dmins(:,1),dmins(:,2),'.')
	hold on
end
if ~isempty(mmins)
   plot(mmins(:,1),mmins(:,2),'r.')
end
ax2 = axis;
% rescale axis so that they correspond to other plots
axis([ax1(1) ax1(2) ax2(3) ax2(4)])
title('Min sync interval index')
hold off
zoom on

% std of trial durations in ms
tlstd = std(results(:,trialLengthC));
fprintf('Trial length std: %f\n',tlstd);
% number of long triggers
ltn = length(find(results(:,triggerLengthC)>trigLength));
fprintf('Num. of trials with long start triggers: %i\n',ltn);
% number of trials missing end triggers
eTrials = find(results(:,trigEndC)<threshold);
etn = length(eTrials);
fprintf('Num. of trials missing end triggers: %i\n',etn);
% number of trials with interleaved data
itn = length(iTrials);
fprintf('Num. of trials with interleaved data: %i\n',itn);
