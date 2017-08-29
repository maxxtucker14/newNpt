function r = isempty(e)
%eyes/isempty True for empty EYES objects
%   isempty(E) returns 1 if E is an empty EYES object and 0 otherwise.

if(isempty(e.sessionname))
	r = 1;
else
	r = 0;
end
