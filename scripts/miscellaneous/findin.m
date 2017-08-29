function I=findin(A,b)
% A is a matrix and b is a column vector
% This function returns a column vector of indices I
% such that A(I)==b if the elements of b are in A.
% If b(k) is not in A, then I(k) is Inf.
%
% Written by Steve Lord (slord@mathworks.com)
% with input/suggestions from Tim Burke
%
% Download this file from MATLAB Central
%   (http://www.mathworks.com/matlabcentral)

Av=A(:);
Bv=b(:);
Q1=kron(Av',ones(size(Bv)));
Q2=kron(ones(size(Av')),Bv);
I=(Q1==Q2).*kron(1:length(Av),ones(size(Bv)));
I(I==0)=Inf;
I=min(I')';