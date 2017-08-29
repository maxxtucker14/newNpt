function [y,r,c,p]= min3(matrix)
%[y,r,c]= min3(matrix)
%
%finds the max value in a matrix
%  y - value
%  r - row
%  c - column
%  p - page

[y,iii] = min(matrix);

[y,ii] = min(y);
[y,p]=min(y);
c=ii(p);
r = iii(:,c,p);