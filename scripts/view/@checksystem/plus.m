function r = plus(p,q,varargin)
%CHECKSYSTEM/PLUS Adds two CHECKSYSTEM objects
%   R = PLUS(P,Q) adds the sessions field of two CHECKSYSTEM
%   object, as well as the path field.
%
%   Dependencies: None.

% check for empty objects
if (q.sessions == 0)
	r = p;
elseif (p.sessions == 0)
	r = q;
else
	% make sure r is a checksystem object
	r = p;
	r.sessions = p.sessions + q.sessions;
	% update number in nptdata parent object
	r.nptdata.number = r.sessions;
	r.path = {p.path{:},q.path{:}};
end
