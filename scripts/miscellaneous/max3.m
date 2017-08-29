function [y,r,c,p]= max3(matrix)
%[y,r,c,p]= max3(matrix)
%
%finds the max value in a matrix
%  y - value
%  r - row
%  c - column
%  p - page

[y,iii] = max(matrix);

[y,ii] = max(y);
[y,p]=max(y);
c=ii(p);
r = iii(:,c,p);