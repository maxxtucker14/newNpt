function r = plus(p,q,varargin)

% get name of class
classname = mfilename('class');

% check if first input is the right kind of object
if(~isa(p,classname))
	% check if second input is the right kind of object
	if(~isa(q,classname))
		% both inputs are not the right kind of object so create empty
		% object and return it
		r = feval(classname);
	else
		% second input is the right kind of object so return that
		r = q;
	end
else
	if(~isa(q,classname))
		% p is the right kind of object but q is not so just return p
		r = p;
    elseif(isempty(p))
        % p is right object but is empty so return q, which should be
        % right object
        r = q;
    elseif(isempty(q))
        % p are q are both right objects but q is empty while p is not
        % so return p
        r = p;
	else
		% both p and q are the right kind of objects so add them 
		% together
		% assign p to r so that we can be sure we are returning the right
		% object
		r = p;
		r.data.sacStart = [p.data.sacStart; q.data.sacStart];
		r.data.sacEnd = [p.data.sacEnd; q.data.sacEnd];
		r.data.sacMaxVel = [p.data.sacMaxVel; q.data.sacMaxVel];
		r.data.sacMaxVelTime = [p.data.sacMaxVelTime; q.data.sacMaxVelTime];
		r.data.sacAmpl = [p.data.sacAmpl; q.data.sacAmpl];
        q.data.sacSetIndex(:,1) = q.data.sacSetIndex(:,1) + p.data.sacSetIndex(end,1);
        q.data.sacSetIndex(:,2) = q.data.sacSetIndex(:,2) + p.data.sacSetIndex(end,2);
		r.data.sacSetIndex = [p.data.sacSetIndex; q.data.sacSetIndex];
		
		r.data.fixStart = [p.data.fixStart; q.data.fixStart];
		r.data.fixEnd = [p.data.fixEnd; q.data.fixEnd];
		r.data.fixMaxVel = [p.data.fixMaxVel; q.data.fixMaxVel];
		r.data.fixMaxVelTime = [p.data.fixMaxVelTime; q.data.fixMaxVelTime];
		r.data.fixAmpl = [p.data.fixAmpl; q.data.fixAmpl];
        q.data.fixSetIndex(:,1) = q.data.fixSetIndex(:,1) + p.data.fixSetIndex(end,1);
        q.data.fixSetIndex(:,2) = q.data.fixSetIndex(:,2) + p.data.fixSetIndex(end,2);
		r.data.fixSetIndex = [p.data.fixSetIndex; q.data.fixSetIndex];
		
        r.data.fixMeanVel = [p.data.fixMeanVel; q.data.fixMeanVel];
		
		
		% useful fields for most objects
		r.data.numSets = p.data.numSets + q.data.numSets;
		r.data.setNames = {p.data.setNames{:} q.data.setNames{:}};
		
		% add nptdata objects as well
		r.nptdata = plus(p.nptdata,q.nptdata);
	end
end
