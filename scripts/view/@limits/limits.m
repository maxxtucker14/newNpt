function lm = limits(varargin)
%LIMITS Constructor function for LIMITS class
%   L = LIMITS(MIN,MAX) instantiates an object that contains
%   the following data structure:
%      L.min
%      L.max
%
%   Dependencies: None.

switch nargin
case 0
	l.min = 0;
	l.max = 0;
	lm = class(l,'limits');
	
case 1
	if(isa(varargin{1},'limits'))
		lm = varargin{1};
	else
		error('Wrong argument type')
	end
	
case 2
	l.min = varargin{1};
	l.max = varargin{2};
	if l.min > l.max
		temp = l.min;
		l.min = l.max;
		l.max = temp;
	end
	lm =  class(l,'limits');
	
otherwise
	error('Wrong number of input arguments')

end
	