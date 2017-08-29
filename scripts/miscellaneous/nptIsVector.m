function res = isvector(data)
%ISVECTOR Returns 1 if argument is a vector
%   RES = ISVECTOR(DATA) returns 1 if DATA is a vector
%   and 0 otherwise.
%
%   Dependencies: None.

ds = size(data);
if (ds(1)==1) | (ds(2)==1)
	res = 1;
else
	res = 0;
end
