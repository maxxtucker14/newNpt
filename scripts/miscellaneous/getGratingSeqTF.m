function r = getGratingSeqTF(filename,varargin)
%getGratingSeqTF Converts grating sequence into velocity
%   R = getGratingSeqTF(FILENAME,VARARGIN) converts the grating 
%   sequence stored in FILENAME and returns the temporal frequency. 
%   FILENAME is assumed to be a text file containing a few lines of 
%   comments, indicated by a "#", followed by a number indicating 
%   the number of phases. The 0-indexed phase sequence then follows, 
%   one per line.
%
%   The optional input arguments are:
%      'framerate' - number indicating the frame rate at which the 
%                    grating was presented in Hz (default: 25).

Args = struct('FrameRate',25);

Args = getOptArgs(varargin,Args);

% read the grating sequence file
[phaseseq,nphases] = readGratingSeq(filename);

% get difference between phase indices
dps = diff(phaseseq);

% get length of dps
dpsl = length(dps);

% create alternative dps which represents an equivalent shift from the
% other direction
% this will take care of a shift of +24 which should really be -1
dps1 = dps - nphases;
% this will take care of a shift of -21 which should really be +4
dps2 = dps + nphases;
% put all three together and pick out the one which is the smallest
% difference in phase index
alldps = [dps dps1 dps2];
dpsabs = abs(alldps);
[dpmin,dpminj] = min(dpsabs');
i = 1:dpsl;
alldpsind = sub2ind([dpsl 3],i,dpminj);
% select the minimum phase difference and make that the phase difference 
% prepend 0 so that output argument will be same length as phaseseq
dpsfinal = [0; vecc(alldps(alldpsind))];
% convert to temporal frequency
r = dpsfinal/nphases * Args.FrameRate;
