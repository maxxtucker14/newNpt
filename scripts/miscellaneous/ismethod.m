function r = ismethod(classname,methodname)
%ISMETHOD True for objects with the method defined
%   R = ISMETHOD(OBJECT,METHOD) returns true is METHOD is defined
%   for an OBJECT. This function can only check methods defined
%   directly for a class and not any inherited methods.
%
%   Dependencies: None.

if ~isempty(find(strcmp(methods(class(classname)),methodname)>0))
	r = 1;
else
	r = 0;
end
