function graylevels = showGratingSeq(nphases,r,varargin)
%showGratingSeq Shows animated grating sequence
%   GRAYLEVELS = showGratingSeq(NUM_PHASES,SEQ,VARARGIN) animates a 
%   grating using NUM_PHASES colormaps and the colormap sequence SEQ.
%   The gray levels of each distinct pixel is returned in GRAYLEVELS,
%   with each pixel in a different column, i.e. each column is the 
%   evolution of the graylevel over frames.
%
%   The optional input arguments are:
%      'GratingSize' - defines the size of the grating in pixels
%                      (default is 100).
%      'GratingSF' - defines the number of pixels that make up one
%                    cycle of the grating (default is 10).
%      'FramePause' - defines how long to pause between animating 
%                     frames of the grating in seconds (default is 0.1).
%
%   graylevels = showGratingSeq(nphases,seq,'gratingsize',100,'gratingsf',10,...
%       'framepause',0.1)

Args = struct('GratingSize',100, ...
			  'GratingSF',10, ...
			  'FramePause',0.1);
			  
Args = getOptArgs(varargin,Args);

a = 1:Args.GratingSize;
a1 = repmat(a,Args.GratingSize,1);
% wrap around spatial frequency, but add 1 and shift otherwise values
% will go from 1 to 0. This way values will go from 1 to Args.GratingSF. 
% Since a2 is of type double and not uint8, index 1 (not index 0) 
% corresponds to first palette entry.
a2 = circshift(rem(a1,Args.GratingSF) + 1,[0 1]);

% create colormap
% theta corresponds to spatial phase
twoPi = 2*pi;
tstep = twoPi/Args.GratingSF;
theta = (0:tstep:(twoPi-tstep))';
% phi corresponds to temporal phase
pstep = twoPi/nphases;
phi = 0:pstep:(twoPi-pstep);
% create matrices for matrix multiplication
m1 = [theta ones(Args.GratingSF,1)];
m2 = [ones(1,nphases); phi];
m = m1 * m2;
% compute grayscale in cycle and set range to [0 1]
cmap = (cos(m)+1)*0.5;
% repmat so we set rgb values to all be the same
colormaps = repmat(cmap,[1 1 3]);
% rearrange so that rgb values are more easily accessible
cmaps = permute(colormaps,[1 3 2]);
% return graylevels from 0 to 255
graylevels = floor(cmap(:,r)' * 255);

% show grating
h = imshow(a2,cmaps(:,:,1),'notruesize');
set(h,'EraseMode','xor');
set(gcf,'DoubleBuffer','on');

% let user hit return to start animation
display('Hit return to start animation');
pause

for ci = 1:length(r)
	colormap(cmaps(:,:,r(ci)));
	pause(Args.FramePause);
end
