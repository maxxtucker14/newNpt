function  [u,stdev]  = calcSTD(sumX,sumX2,n,extract_sigma);

%[tmean,std]  = calcSTD(sumX,sumX2,extract_sigma)
%
%calculates the mean and std for different channels.
%
%inputs
%sumX - cumalitive sum of all data points
%sumX2 - cumulative sum of all squared data points.
%n - number of datapoints
%
%solve for variance as follows:
%  v = (1/n-1) * sum(( x-u)^2)
%  v = (1/n-1) * sum( x^2 - 2xu + u^2)
%  v = (1/n-1) * sum(x^2) -2u*sum(x) + u^2;
%  
%...using the mean
%  u = sum(x)/n
%
%... and finally
%  stdev = sqrt(v);


%sum across trials
sumX = sum(sumX,3);
sumX2 = sum(sumX2,3);
n = sum(n,2);


u = sumX./(n*ones(1,size(sumX,2)));
%stdev = sqrt((1./(n-1)) .* (sumX2 - 2*u.*sumX + u.^2));
summ = sumX2 - 2*u.*sumX + u.^2;
v = 1./((n*ones(1,size(sumX,2)))-1) .* summ;
stdev = sqrt(v);