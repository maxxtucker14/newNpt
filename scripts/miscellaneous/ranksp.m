function ranks = ranksp(x)
%RANKSP Computes rank for Spearman correlation
%   RANKSP(X) ranks the values in X with equivalent values 
%   set to the mean rank).

[sortedx,xi] = sort(x);
[sortedx,xrank] = sort(xi);

y = flipud(x);
[sortedy,yi] = sort(y);
[sortedy,yi2] = sort(yi);
yrank = flipud(yi2);

ranks = (xrank+yrank)/2;
