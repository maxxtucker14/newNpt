function res = nptCheckEndData(data)
%nptCheckEndData Check function generator channels for data interleaving
%   RES = nptCheckEndData(DATA,CHANNELS) returns 1 if it looks
%   like there might be some data interleaving at the end of
%   a trial and 0 otherwise. DATA is a matrix containing data 
%   from the 2 function generator channels.
%   e.g. nptCheckEndData(data(6:7,:))

% window is 1.5 ms at 30 kHz which is 45 points
window = 45;

points = size(data,2);
if points < 46
   res = 0;
   return
end
spoint = points - window;
d = data(:,spoint:points)';
dDiff = abs(diff(d));
[maxD,maxI] = max(dDiff);
% find out how close the two max values are in datapoints
% should be either the same of at most 1 point apart
dm = abs(diff(maxI));
if dm>1
   res = 0;
   return;   
else
   % find the std for the diff values before the maximum diff
   % dSTD3 = 3 * std(dDiff(1:maxI(1)-1,:));
   
   % find the std for dDiff instead of just before the max
   % to prevent false positives when the max is in the first 
   % few points for trials with no interleaved data
   % dSTD3 = 3 * std(dDiff);
   % mCompare = maxD > dSTD3;
   
   % in case there are cases where the interleaving starts
   % one point apart, we set the maxI to the later data point
   % of the two
   if dm==1
      maxI = max(maxI) * [1 1];
   end
   
   % find the max for diff values before the maximum diff
   % but check for case when the 1st or last points are 
   % the max
   if maxI(1)<3
      m1 = dDiff(1,:);
   else
      m1 = max(dDiff(1:maxI(1)-1,:));
   end
   if window-maxI(1)<3
      m2 = dDiff(window,:);
   else
      m2 = max(dDiff(maxI(1)+1:window,:));
   end
   mCompare = m1 > 3*m2;
   
   if sum(mCompare)>0
      res = 1;
   else
      res = 0;
   end
end