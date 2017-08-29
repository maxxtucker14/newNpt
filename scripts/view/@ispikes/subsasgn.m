function obj = subsasgn(obj,index,value)
%ISPIKES/SUBSASGN Assignment function for ISPIKES object
%
%   Dependencies: None.

unknown = 0;
myerror = 0;

switch index(1).type
case '.'
   switch index(1).subs
   case 'title'
      obj.data.title = value;   
   case 'sessionname'
      obj.data.sessionname = value;
   case 'groupname'
      obj.data.groupname = value;
   case 'duration'
      obj.data.duration = value;
   case 'min_duration'
      obj.data.min_duration = value;
   case 'signal'
      obj.data.signal = value;
   case 'means'
      obj.data.means = value;
   case 'thresholds'
      obj.data.thresholds = value;
   case 'trial'
      switch length(index)
      case 1
         obj.data.trial = value;
      case 2
         obj.data.trial(index(2).subs{:}) = value;
      case 3
         obj.data.trial(index(2).subs{:}).cluster = value;
      case 4
         obj.data.trial(index(2).subs{:}).cluster(index(4).subs{:}) = value;
      case 5
         switch index(5).subs
         case 'spikecount'
            obj.data.trial(index(2).subs{:}).cluster(index(4).subs{:}).spikecount = value;
         case 'spikes'
            obj.data.trial(index(2).subs{:}).cluster(index(4).subs{:}).spikes = value;
         end
      case 6
         obj.data.trial(index(2).subs{:}).cluster(index(4).subs{:}).spikes(index(6).subs{:}) = value;
      otherwise
      	 myerror = 1;
      end
   case 'numTrials'
	  obj.streamer.numTrials = value;
   case 'numClusters'
      obj.data.numClusters = value;
   otherwise 
      unknown = 1;
   end
otherwise
	unknown = 1;
end

if unknown == 1
	b = subsasgn(obj.streamer,index,value);
elseif myerror == 1
    error('Invalid field name');
end

