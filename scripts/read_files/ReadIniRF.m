function r = ReadIniRF(filename)
%ReadIniRF Reads receptive field information from INI files
%   R = ReadIniRF(FILENAME) opens FILENAME and reads receptive
%   field information.

r = ReadIniSession(filename);
ini_fid = fopen(filename,'rt','ieee-le');
tmpline = '';
while(~strcmp(tmpline,'[RECEPTIVE FIELDS]'))
	tmpline = fgetl(ini_fid);
end

% read version of RF section
fieldname = fscanf(ini_fid,'%[^=]',1);
if strcmp(fieldname,'Section Version')
	rfversion = fscanf(ini_fid,'=%i\n',1);
else
	error('Unexpected format!')
end

if(rfversion==1)
	% read number of RFs keep as variable so we don't have to keep doing
	% math on the structure to access the numRFs field
	numRFs = fscanf(ini_fid,'%*[^=]=%i\n',1);
	r.numRFs = numRFs;
	% initialize memory
	r.type = zeros(numRFs,1);
	r.pts = zeros(numRFs,8);
	r.centerx = zeros(numRFs,1);
	r.centery = zeros(numRFs,1);
	r.ori = zeros(numRFs,1);
	r.uDim = zeros(numRFs,1);
	r.vDim = zeros(numRFs,1);
	r.sf = zeros(numRFs,1);
	r.vel = zeros(numRFs,1);
	r.mark = zeros(numRFs,1);
	for i = 1:numRFs
		% get all parameters for this RF
		r.type(i) = fscanf(ini_fid,'%*[^=]=%i\n',1);
		% skip over "{0} Pts={"
		fscanf(ini_fid,'%*c%*[^=]%*c%c',1);
		r.pts(i,:) = fscanf(ini_fid,'%d,%d',8);
		% get the rest in 1 read
		params = fscanf(ini_fid,'%*[^=]=%f\n',8);
		r.centerx(i) = params(1);
		r.centery(i) = params(2);
		r.ori(i) = params(3);
		r.uDim(i) = params(4);
		r.vDim(i) = params(5);
		r.sf(i) = params(6);
		r.vel(i) = params(7);
		r.mark(i) = params(8);
	end
end

fclose(ini_fid);
