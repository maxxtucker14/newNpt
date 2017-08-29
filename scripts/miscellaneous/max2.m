function [y,r,c]= max2(matrix)
%[y,r,c]= max2(matrix)
%
%finds the max value in a matrix
%  y - value
%  r - row
%  c - column

[y,ii] = max(matrix);
[y,c] = max(y);
r=ii(c);