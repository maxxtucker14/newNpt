% fit_power.m - fits power law function to data distribution
%
% function [x0 alpha] = fit_power(x,P)
% 
% fits a power law function of the form P = 1/(x0 + x)^alpha
%
% x:  firing rate values
% P:  normalized data distribution
%
% x0: power law offset
% alpha: power law exponent

function [x0,alpha] = fit_power(x,P)

num_iterations=1000;
eta=.01;

x0=1;
alpha=2;

Z=sum(1./(x0+x).^alpha);
Ph=1./(Z*(x0+x).^alpha);

loglog(x,P)
hold on
h=loglog(x,Ph,'k--','EraseMode','xor');
drawnow

for i=1:num_iterations

    dalpha = eta * sum((Ph-P).*log(x0+x));
    dx0 = eta * alpha*sum((Ph-P)./(x0+x));

    x0=x0+dx0;
    alpha=alpha+dalpha;

    Z=sum(1./(x0+x).^alpha);
    Ph=1./(Z*(x0+x).^alpha);

    set(h,'YData',Ph)
    drawnow


end
hold off

