function pan(steps)
%PAN Pans through figure
%   PAN(STEPS) pans through current figure in steps of STEPS.

% get y-axis limits
ax1 = axis;

% start from the beginning
xmin = 0;
xmax = steps;
axis([xmin xmax ax1(3) ax1(4)])
while 1
	% get keyboard input to see what to do next
	key = input('RETURN - Next; p - Previous; q - Quit: ','s');
	if strcmp(key,'q')
		break;
	elseif strcmp(key,'p')
		xmin = xmin - steps;
		xmax = xmax - steps;
	else
		xmin = xmin + steps;
		xmax = xmax + steps;
	end
	axis([xmin xmax ax1(3) ax1(4)])
end
