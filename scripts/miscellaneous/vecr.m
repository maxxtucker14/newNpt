function vr = vecr(a)
%VECR Convert to row vector
%   V = VECR(A) checks A to see if it is a N by 1 vector and converts
%   it to a 1 by N vector. Otherwise, the function returns A.

% get size of a
as = size(a);
% take transpose only if number of columns is 1 and number of rows is
% greater than 1
if( (as(1)>1) && (as(2)==1) )
	vr = a';
else
	vr = a;
end
