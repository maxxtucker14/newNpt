function r = welch(n)
%WELCH Welch window.
%   WELCH(N) returns the N-point welch window in a column vector.
%   Equation obtained from following URL:
%   http://www.clecom.co.uk/science/autosignal/help/Data_Tapering_Windows.htm

n1 = n - 1;
i = (0:n1)';
r = 1 - ((n1-2*i)/n1).^2;
