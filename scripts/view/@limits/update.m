function [lm,lmin,lmax] = update(lm,imin,imax)
%LIMITS/UPDATE Updating function for LIMITS method
%   [L,L_MIN,L_MAX] = UPDATE(MIN,MAX) updates the min and max values
%   of a LIMITS object and returns the min and max in MIN and MAX 
%   respectively.
%
%   Dependencies: None.

if imin < lm.min
	lm.min = imin;
end

if imax > lm.max
	lm.max = imax;
end

lmin = lm.min;
lmax = lm.max;
