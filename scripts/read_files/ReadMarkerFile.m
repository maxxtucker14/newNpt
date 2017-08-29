function [markers,records] = ReadMarkerFile(filename)
%ReadMarkerFile	Opens and reads marker files created by Control III
%	[MARKERS,RECORDS] = ReadMarkerFile(FILENAME) opens and reads FILENAME
%	and returns the time markers in MARKERS and the number of markers in RECORDS.
%	Column 1 in MARKERS is the marker id and Column 2 is the time the marker was
%	created. 
%
%   Dependencies: None.

fid = fopen(filename,'r','ieee-le');

markers = fread(fid,[2,inf],'uint32');

% the row number that corresponds to 255 marks the end of the session
I = find(markers(1,:) == 255);

% case when the session was not fully recorded or when the 255 was just
% skipped
if isempty(I)
    II = find(markers(1,:) == 0);
    I = II(end);
end

records = max(I);

% stop "markers" at the end of the session, and transpose
markers = markers(:,1:records)';

fclose(fid);
