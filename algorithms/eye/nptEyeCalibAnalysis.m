%	function meanVHmatrix = nptEyeCalibAnalysis(data , G , sigma, SamplesPerMS, display_p);
%	
% This program gets subsampled and filtered eyecoil data,
% determines whether there are any saccades,
% finds the end of the last saccade (the
% beginning of the last stable fixation), and
% then calculates the mean vertical and horiz-
% ontal eye position over the course of the
% last fixation.
%	
%	data is the eyecoil data
%	G is the guassian used by the first lowpass filter defined by sigma and sampling rates
%	sigma = SamplesPerMS/2, from -3*sigma to 3*sigma
%	SamplesPerMS is dependent on original sampling rate and resample rate
%	display_p is optional and gives a graphical output to the calculations
%
%revised 8/6/01
%===========================================


function meanVHmatrix = nptEyeCalibAnalysis(data , G , sigma, SamplesPerMS, display_p);


meanVHmatrix = zeros(2,1);


% make gaussian derivative filter
dG = G.*(3*sigma:-1:-3*sigma);
% make another gaussian filter, sigma=SamplesPerMS*3, from -3*sigma to 3*sigma
sigma2 = SamplesPerMS * 3;
G2 = exp(-(-3*sigma2:3*sigma2).^2/(2*sigma2^2));
G2 = G2 / sum(G2(:));

% smooth data by convolving with gaussian mask 'G'
dataconv = conv2( data, G, 'same' );
% calculate a smoothed derivative of data
ddtdata = conv2( data, dG, 'same' );
% calculate instantaneous speed
speed = sqrt( sum(ddtdata.^2) );
% double smooth and subsample approximately every millisecond
start=3*sigma;
finish=length(speed)-3*sigma;
speed = conv2( speed(start:finish), G2, 'same' );
% calculate mean and standard deviation of speed
validi=3*sigma2:(length(speed)-3*sigma2);
meanspeed = mean(speed(validi));
stdevspeed = std(speed(validi));
% calculate the histogram of speed values
speedhist = hist(speed(validi), 100 );
ratiohist = sum(speedhist(1:39)) / sum(speedhist(40:100));

% if saccade, then get first mean+stdev crossing (end of last saccade,
% beginning of last fixation) and calculate mean over this interval
if ratiohist > 8     % i.e., if there is a saccade
   saccade_ind = find(speed >= (meanspeed + stdevspeed));
   place=start+saccade_ind(end)-1;
else
   place = start;
end
meanpos = mean( data(:,place:finish), 2 );

% position = StimulusSequence(l)+1;
% y = int((position-1)/GridCols)+1;
% x = position - y*GridCols;

% save meanpos in a matrix for this .INI file's session,
% indexed first by V=1 or H=2 or grid position=3, then by trial number 'l'
meanVHmatrix(1:2,1) = meanpos;





% flag for plotting saccade statistics for each trial within a calibration run, as well as final result
if nargin==4
   display_p = 0;
else
   display_p = 1;
   figure
end

if display_p 
   
   % plot vertical eye movements with derivative
   clf;
   ssi=start:sigma:finish;
   subplot(3,2,1);
   plot(ssi, dataconv(1,ssi))
   hold on
   plot(ssi, ddtdata(1,ssi), 'r')
   Title('Vertical Eye Movements')
   % plot horizontal eye movements with derivative
   subplot(3,2,3);
   plot(ssi, dataconv(2,ssi))
   hold on
   plot(ssi, ddtdata(2,ssi), 'r')
   Title('Horizontal Eye Movements')
   % plot vertical vs. horizontal eye movements
   subplot(3,2,2);
   plot(dataconv(2,start:sigma:place),dataconv(1,start:sigma:place),'k')
   hold on
   plot(dataconv(2,place:sigma:finish),dataconv(1,place:sigma:finish),'b')
   axis image
   % plot mean vertical vs. horizontal eye position during last fixation
   plot(meanpos(1), meanpos(2), 'xr')
   Title('Vertical vs. Horizontal Eye Movements')
   % plot speed vs. time, mean+stdev
   subplot(3,2,4);
   plot(validi,speed(validi), 'r' )
   hold on
   plot([validi(1) validi(end)], (meanspeed+stdevspeed)*[1 1], 'k' );
   Title('speed')
   % plot histogram of speed values
   subplot(3,2,6);
   plot(speedhist );
   Title('Histogram of speed values');
   
   fprintf('\n hit key to continue\n');
   pause
   
   
   
   clf
   hold on
   for i=1:NumberOfPoints
      ind=find(StimulusSequence==(i-1));
      plot(meanVHmatrix(2,ind),meanVHmatrix(1,ind),'.')
   end
   drawnow
   hold off
end
