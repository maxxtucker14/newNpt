function [r,varargout] = get(obj,varargin)
%eyemvt/get Get function for EYEMVT objects
%   [numevents,dataindices] = get(obj,'Number') returns 
%   all the trial numbers and the indices of those trials corresponding 
%   to the SetIndex field of the EYEMVT object. ObjectLevel by defautl is
%   SESSIONOBJECT
%
%   [numevents,dataindices,Mark] = get(obj,'Number','SessionBySession')
%   returns the indices for the saccades belonging to each session.
% 
%   [numevents,dataindices] = get(obj,'Number','Fix') process the fixations 
%   instead of the saccades (default). 
% 
%   [numevents,dataindices,mark] = get(obj,'Number','Threshold',T,'Parameter',...
%   'P','Condition','C') enables to select a set of saccades/fixations according 
%   to the threshold T applied to the parameter P and with a certain condition C.
%   If a certain threshold criteria has been used to select specific saccades 
%   and/or fixations, MARK will be set to 1 in order to point them out during the 
%   plotting.
%   
%   P has to be one of the following parameter:
%                     
%            maxvelocity: maximum velocity of saccades/fixations [degree/ms]
%            meanvelocity: mean velocity of fixations [degree/ms] 
%            beginning:  start of saccades/fixations [ms]
%            finish: end of saccades/fixations [ms]
%            maxvelocitytime: occurence of the maximum velocity of the saccades/fixations [ms]
%            amplitude:  Amplitude of the saccades/fixations [degree]
%                     
%
%   Ex.: 
%   [numevents,dataindices,mark] = get(obj,'Number','Threshold',100,'Parameter',
%   'maxvel','Condition','<')  is going to return the indices of the
%   saccades whose maximum velocities are below 100 [degree/s].
%
%   
%
%   
%   Dependencies: EYEMVT
%  
Args = struct('Number',0,'All',0,'SessionBySession',0,'Fix',0,'ObjectLevel',0,'Threshold',[],'Parameter',[],'Condition','>');
Args.flags = {'Number','SessionBySession','Fix','ObjectLevel'};
Args = getOptArgs(varargin,Args,'remove',{'Threshold','Parameter','Condition'});

varargout{1} = {''};
varargout{2} = 0;

if(Args.Fix)
    SetIndex = obj.data.fixSetIndex;
    maxvelocity = obj.data.fixMaxVel;
    meanvelocity = obj.data.fixMeanVel;
    beginning = obj.data.fixStart;  
    finish = obj.data.fixEnd;
    maxvelocitytime = obj.data.fixMaxVelTime;
    amplitude = obj.data.fixAmpl;
else
    SetIndex = obj.data.sacSetIndex;
    maxvelocity = obj.data.sacMaxVel;
    beginning= obj.data.sacStart;
    finish = obj.data.sacEnd;
    maxvelocitytime = obj.data.sacMaxVelTime;
    amplitude = obj.data.sacAmpl;
end

if(Args.Number && Args.SessionBySession)
    % return total number of events
    r = length(obj.data.setNames);
    % find the transition point between sessions
    sdiff = diff(SetIndex(:,1));
    stransition = [0; vecc(find(sdiff))];
    stransition = [stransition; length(SetIndex)];
    rind = [];
    for idx = 1:r
        value = vecc((stransition(idx)+1):stransition(idx+1));
        % grab the indices corresponding to session idx
        rind = [rind; [repmat(idx,length(value),1) value]];
    end
    varargout(1) = {rind};
elseif Args.Number && ~Args.SessionBySession && isempty(Args.Threshold) && ~Args.All
    [B,I,J] = unique(SetIndex(:,2));
    rind = [I B SetIndex(I,3)];
%     rind = SetIndex(:,2);
%     rind = repmat(unique(rind),1,2);
    r = size(rind,1);
    varargout(1) = {rind};
    % if we don't recognize and of the options, pass the call to parent
    % in case it is to get number of events, which has to go all the way
	% nptdata/get
elseif Args.Number && Args.All && isempty(Args.Threshold) % case where all the events are given
    rind = [(1:size(SetIndex,1))' SetIndex(:,2:3) ones(size(SetIndex,1),1)]; %get all the data and put 1
     r = size(rind,1);
    varargout(1) = {rind};
    
elseif Args.Number && ~isempty(Args.Threshold) % selection with a certain criteria
    
    measure = eval(Args.Parameter);
    
    [rawindices,colindices] = eval(sprintf('find(measure %s %d)',Args.Condition,Args.Threshold));
%     rind = SetIndex(rawindices,[2 4]);
    rind = [rawindices SetIndex(rawindices,2) SetIndex(rawindices,3)];
    varargout(1) = {rind};
    r = size(rind,1);
    varargout(2) = {1};
elseif(Args.ObjectLevel)
    r = 'Session';
else
	r = get(obj.nptdata,varargin{:});
    
end
