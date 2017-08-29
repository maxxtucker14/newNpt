function h = TwoDimGaussFilter(siz,sigma,center,ar)
%h = TwoDimGaussFilter(size,std)
%
%returns a 2 dimensional normalized.
%filter.  Use surf(h) to view.
%
%siz is 2d vector of order of filter (x,y)
%       or 1d if x=y.
%sigma is the standard deviation.
%ar is aspect ratio of sigma.
%theta is orientation.


if nargin<4
    ar=1;
end
if nargin<3
    center=[0 0];
end
if length(siz)==1
    siz = [siz siz];
end

 siz   = (siz-1)/2;
 [x,y] = meshgrid(-siz(2):siz(2),-siz(1):siz(1));



arg = -((x-center(1)).^2 + ar^2*(y-center(2)).^2)/(2*sigma^2);
h =  exp(arg);

%x1 = x*cos(theta) + y*sin(theta);
%y1 = -x*sin(theta) + y*cos(theta);


h(h<eps*max(h(:))) = 0;

sumh = sum(h(:));
if sumh ~= 0,
    h  = h/sumh;
end;
