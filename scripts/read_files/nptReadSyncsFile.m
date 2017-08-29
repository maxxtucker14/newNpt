function [syncs,dataFilename,records,meanF,stdF] = nptReadSyncsFile(sncfile)
%nptreadSyncsFile Function to read binary SNC files from DataStreamer
%   [SYNCS,DATA_FILENAME,RECORDS,MEANF,STDF] = nptReadSyncsFile(FILENAME)
%   opens the file FILENAME and returns the syncs table in SYNCS. 
%   The associated data file name is returned in DATA_FILENAME,
%   RECORDS is the number of syncs, MEANF and STDF are the mean 
%   frequency and standard deviation of the syncs.
%	e.g.
%      [syncs,dfilename,records,meanF,stdF] = nptReadSyncsFile('a101.snc');
%   reads the syncs from a single-trial session.
%
%   Dependencies: None.

% get this function's name
fnName = mfilename;

fid = fopen(sncfile,'r','ieee-le');
headerSize=fread(fid, 1, 'int32');
dName=fread(fid, 260, 'char');
dataFilename = sprintf('%c',dName');
records=fread(fid, 1, 'int32');
meanF = fread(fid,1,'float64');
stdF = fread(fid,1,'float64');
% rewind to beginning of file and move to start of data in case header has
% changed
frewind(fid);
% check for invalid headerSize
if (isempty(headerSize) | headerSize < 1)
    % problem with file so print error,return default values and close fid
    fprintf('%s: Invalid headerSize for %s.\n',fnName,sncfile);
    syncs = [];
    dataFilename = '';
    records = 0;
    meanF = 0;
    stdF = 0;
    fclose(fid);
    return
end
fseek(fid,headerSize,'bof');
[syncs,count]=fread(fid, inf, 'int32');
fclose(fid);
if count~=records
    fprintf('%s: Mismatch in number of records!\nHeader: %i Syncs: %i\n',fnName,records,count);
    fprintf('Re-Writing the Sync monitor File')
    syncs = syncs(1:records);
    fid=fopen(sncfile,'w','ieee-le');
    fwrite(fid, headerSize, 'int32');   % 4 bytes reserved for header size which is 73 bytes
    fwrite(fid, dName, 'char');		    % 1 byte
    fwrite(fid, records, 'int32');	    % 4 bytes
    fwrite(fid, meanF, 'float64');		% 1 byte for datatype
    fwrite(fid, stdF, 'float64');		% skip to the end of headersize
    fwrite(fid, syncs, 'int32');        % write the data
    fclose(fid);       
end
