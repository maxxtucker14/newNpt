function dxy = nptReadDXYFile(filename)
%nptReadDXYFile Reads DXY files created from eye calibration sessions
%   DXY = nptReadDXYFile(FILENAME) reads eye calibration data from
%   FILENAME. The following fields are returned in the DXY structure:
%      DXY.ScreenHeight
%      DXY.ScreenWidth
%      DXY.GridRows
%      DXY.GridCols
%      DXY.Xsize
%      DXY.Ysize
%      DXY.CenterX
%      DXY.CenterY
%      DXY.NumBlocks
%      DXY.NumberOfPoints
%      DXY.NumberOfTrials
%      DXY.meanVHmatrix
%      DXY.avgVH
%
%   dxy = nptReadDXYFile(filename);

fid = fopen(filename,'r','ieee-le');

% read in variables
dxy.ScreenHeight = fread(fid, 1, 'int32');
dxy.ScreenWidth = fread(fid, 1, 'int32');
dxy.GridRows = fread(fid, 1, 'int32');
dxy.GridCols = fread(fid, 1, 'int32');
dxy.Xsize = fread(fid, 1, 'int32');
dxy.Ysize = fread(fid, 1, 'int32');
dxy.CenterX = fread(fid, 1, 'int32');
dxy.CenterY = fread(fid, 1, 'int32');
dxy.NumBlocks = fread(fid, 1, 'int32');
dxy.NumberOfPoints = dxy.GridRows*dxy.GridCols;
dxy.NumberOfTrials = dxy.NumberOfPoints*dxy.NumBlocks;
%meanVH is the average voltage of the last fixation for each trial.  This was used to create avgVH in ProcessSession
%but it is not used anymore.
dxy.meanVHmatrix(1:2,1:dxy.NumberOfTrials) = fread(fid, [2,dxy.NumberOfTrials], 'double');
%avgVh is the average voltage for each grid point.
dxy.avgVH(1:2,1:dxy.NumberOfPoints) = fread(fid, [2,dxy.NumberOfPoints], 'double');

fclose(fid);
