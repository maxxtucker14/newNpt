function [r,nphases] = readGratingSeq(filename)
%readGratingSeq Reads the grating sequence file
%   [R,NPHASES] = readGratingSeq(FILENAME) reads the grating sequence file 
%   FILENAME and returns the sequence in R and the number of phases in NPHASES.
%   R is 1-indexed so it will be easier to use in other Matlab functions.

fid = fopen(filename,'rt');

% read a line
l = fgetl(fid);
% keep reading until first character is not '#'
while(l(1)=='#')
	l = fgetl(fid);
end

% read nphases, which should be 1-indexed
nphases = str2num(l);

% now read to end of file
r = fscanf(fid,'%d',inf);
% convert r which is 0-indexed to 1-indexed
r = r + 1;

fclose(fid);
