% read_seq.m - reads a .seq file of sparse noise display parameters
%
% function seq = read_seq(filename)
%
% seq is an N x 3 or 4 array whose columns are x, y, orientation, color
%
% For Gabor and Grating Tuning seq files
% seq is an N x 6 array whose columns are x, y, orientation, color,
% temporal frequency, spatial frequency.

function seq = read_seq(filename)

if nargin==0
  fprintf('must provide filename\n');
  return
end

%open init file
fid=fopen(filename,'r');
if fid==-1
  errordlg('sequence file could not be opened','ERROR')
  return
end

seqSize = [];
dummy = 1;
while dummy
	line = fgetl(fid);
	if strcmp(line, 'Spot')
		seqSize = 3;
	elseif strcmp(line, 'Square')
		seqSize = 3;
	elseif strcmp(line, 'Bar')
		seqSize = 4;
    elseif strcmp(line, 'Gabor and Grating')
        seqSize = 4;
    elseif strcmp(line, 'Gabor and Grating tuning')
        seqSize = 6;
	elseif ~isempty(str2num(line))
		firstRow = str2num(line);
		break
	end
end

if isempty(seqSize)
	seqSize = 4;
end

% read sequence data
seq = [firstRow'; fscanf(fid,'%d')];
fclose(fid);

N = length(seq)/seqSize;
seq = reshape(seq, seqSize, N)';
