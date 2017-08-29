function res = veccat(v1,v2)
%VECCAT Concatenates value to a vector
%   RES = VECCAT(VECTOR,VALUE) appends VALUE as a new row if VECTOR
%   is a column vector (i.e. RES = [VECTOR; VALUE]) and appends 
%   VALUE as a new column if VECTOR is a row vector 
%   (i.e. RES = [VECTOR VALUE]).
%
%   RES = VECCAT(VALUE,VECTOR) inserts VALUE instead of appending.

v1s = size(v1);
v2s = size(v2);

if (v2s(1)==1) & (v2s(2)==1) & isvector(v1)
	if isrowvector(v1)
		res = [v1 v2];
	else
		res = [v1; v2];
	end
elseif (v1s(1)==1) & (v1s(2)==1) & isvector(v2)
	if isrowvector(v2)
		res = [v1 v2];
	else
		res = [v1; v2];
	end
else
	error('The arguments have to be a scalar and a vector!')
end
