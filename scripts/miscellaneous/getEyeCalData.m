function e = getEyeCalData(varargin)
%getEyeCalData Get eye calibration grid corrections
%   E = getEyeCalData(VARARGIN) returns data necessary for plotting 
%   the eye calibration corrections in 2D. The function calls 
%   getDXYData to look for DXY files contained in sub-directories 
%   of the current directory. The structure E contains the following
%   fields:
%      E.vchan - Indicates the channel to corresponds to vertical 
%                eye position. Usually set to 1.
%      E.hchan - Indicates the channel to corresponds to horizontal 
%                eye position. Usually set to 2.
%      E.screenx - Array consisting of the x coordinates of points
%                  used in the eye calibration.
%      E.screeny - Array consisting of the y coordinates of points
%                  used in the eye calibration.
%      E.gridx - Array consisting of the x coordinates of the 
%                corrected eye calibration grid.
%      E.gridy - Array consisting of the y coordinates of the 
%                corrected eye calibration grid.
%
%   The optional input arguments are:
%      'Dir' - Specifies another directory instead of the current
%              directory in which to look for DXY files (default is
%              '').
%      'GridSteps' - Specifies the step size of the gridx and gridy
%                    (default is 25).
%      'InterpAlg' - Specifies the interpolation algorithm (default
%                      is 'v4').
%
%   e = getEyeCalData('Dir','','GridSteps',25,'InterpAlg','v4');

Args = struct('Dir','','GridSteps',25,'InterpAlg','v4');
Args = getOptArgs(varargin,Args);

if(~isempty(Args.Dir))
	% get current directory before switching directories
	cwd = pwd;
	% we should be in the eye directory of a session so we need to go
	% up two levels
	cd(Args.Dir);
end

% open up dxy files
ec = getDXYData;

if(~isempty(Args.Dir))
	% go back to previous directory
	cd(cwd);
end

% code from Eyecoil2Screen.m
e.vchan=1;
e.hchan=2;

eyey=reshape(ec.eyecoilcoords(e.vchan,:),ec.GridCols(1),ec.GridRows(1))';
eyex=reshape(ec.eyecoilcoords(e.hchan,:),ec.GridCols(1),ec.GridRows(1))';

starty = ec.CenterY(1) - ec.Ysize(1)/2;
startx = ec.CenterX(1) - ec.Xsize(1)/2;
xincrement = ec.Xsize(1)/(ec.GridCols(1) - 1);
yincrement = ec.Ysize(1)/(ec.GridRows(1) - 1);

[e.screenx e.screeny] = meshgrid(startx+xincrement*[0:(ec.GridCols(1)-1)],...
						starty+yincrement*[0:(ec.GridRows(1)-1)]);

% get range of recorded eye position signals
max_eye=max(ec.eyecoilcoords,[],2);
min_eye=min(ec.eyecoilcoords,[],2);
eyerange=max_eye-min_eye;
% set up GridStepsxGridSteps grid for visualization
[eyegridx eyegridy]=meshgrid(min_eye(e.hchan):eyerange(e.hchan)/Args.GridSteps:max_eye(e.hchan),...
  min_eye(e.vchan):eyerange(e.vchan)/Args.GridSteps:max_eye(e.vchan));
e.gridx = griddata(eyex, eyey, e.screenx, eyegridx, eyegridy,Args.InterpAlg);
e.gridy = griddata(eyex, eyey, e.screeny, eyegridx, eyegridy,Args.InterpAlg);
