function res = isrowvector(data)
%ISROWVECTOR Returns 1 if argument is a row vector
%   RES = ISROWVECTOR(DATA) returns 1 if DATA is a row vector
%   and 0 otherwise.
%
%   Dependencies: None.

ds = size(data);
if ds(1)==1 & ds(2)>1
	res = 1;
else
	res = 0;
end
