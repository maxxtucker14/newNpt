function [y,r,c]= min2(matrix)
%[y,r,c]= min2(matrix)
%
%finds the min value in a matrix
%  y - value
%  r - row
%  c - column

[y,ii] = min(matrix);
[y,c] = min(y);
r=ii(c);