function [data,num_spikes] = nptRemoveNoiseSpike(data,fs,displayflag)
%[fixeddata,num_spikes] = nptRemoveNoiseSpike(data,fs,displayflag)
%
%this function is used to remove noise spikes from data.
%ideally this function would be able to detect any noise spike.  Realistically
%this program will be optimized for our noise spikes within the eye data.  
%This program is written because noise spikes (from static electricity maybe) 
%appeared in our data.  The noise is present in both the eye signal and the nueral signals.  
%Because the nueral signals have been amplified, the noisespike amplitude 
%is within the noise level and so is harded to detect.
%So this program is meant to run on eye data only.  
%Furthermore to incorporate this program into the current batch processing 
%system, we will perform the algorithm on the eyefilt data before it is calibrated. 
%This program detects a start and end of a noise spike in the eye data
%and then replaces each noise spike with a straight line.
%
%input parameters
%data - data to be evaluated
%fs -  sample rate


%by filtering the absolute value of the acceleration
%we obtain a unimodal spike that is much larger than 
%any natural eyemovement.  This spike can then be detected 
%with a simple threshold crossing.


if nargin==3
   displayflag=1;
else 
   displayflag=0;
end



%first find the direvative of the position (velocity)
vel = gradient(data);
%[dmean,stddev] = nptThreshold(vel);
%threshold=mean(threshold);
%if displayflag
%   figure
%   plot(vel(1,:))
%   hold on 
%   plot(vel(2,:),'r')
%   title('velocity')
%   line([1,1;length(vel),length(vel)],[threshold;threshold])
%   line([1,1;length(vel),length(vel)],[-threshold;-threshold])
%end




%now the acceleration
acc = gradient(vel);
acc=abs(acc);
%filter the acceleration
Wn=500/1000;
[b,a] = fir1(8,Wn);
acc=transpose(filtfilt(b,1,acc'));

sigma=100;            %this works well
[dmean,stddev] = nptThreshold(acc');		
threshold = max(sigma*stddev+dmean);








%using the filtered absolute value acceleration with a 
%large sigma (~15) then we can simply
%threshold the signal and only get noise spikes.  The intersection is the 
%boundary points on the position data as well.  Pretty simple.
noisetf = acc(1,:) > threshold | acc(2,:) > threshold;
%now mark data by shifting and subtracting with itself
snoisetf = [noisetf(:,2:length(noisetf)) 0];
marker = noisetf-snoisetf;
%-1 marks position before increasing threshold crossing
%+1 marks postition at decreasing threshold crossing
start = find(marker==-1);
finish = find(marker==1)+1;
if length(start)~=length(finish)
   error('Spike Extraction Error!!')
end

%loop over spikes
num_spikes=0;
for s=1:size(start,2)
   if start(s)<finish(s)
     num_spikes = num_spikes+1;
      %create striaght line between start and end points.
      slope = (data(:,finish(s))-data(:,start(s)))/(finish(s)-start(s));
      x=1:(finish(s)-start(s));
      b = data(:,start(s));
      y = slope*x+diag(b)*ones(2,length(x));
      data = [data(:,1:start(s)) y data(:,finish(s)+1:length(data))];
   end
end

if displayflag
 
   
   figure
   plot(acc(1,:))
   hold on 
   plot(acc(2,:),'r')
   title('acceleration')
   line([1,1;length(acc),length(acc)],[threshold;threshold])
      line([1,1;length(acc),length(acc)],[stddev(1);stddev(2)])
   line([1,1;length(acc),length(acc)],[stddev(1);stddev(2)])

   figure(h1);
   hold on
   plot(data(1,:),'k')
   plot(data(2,:),'k')
   pause
end
