function display(sdata)
%DATAFILE/DISPLAY Command window display of a DATAFILE object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\tdatafile object from %s with fields:\n',sdata.sessionname); 
fprintf('\tsessionname\n');
fprintf('\tchannel\n');
fprintf('\tnumTrials\n');
fprintf('\tholdaxis\n');
