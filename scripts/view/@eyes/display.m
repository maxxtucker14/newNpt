function display(edata)
%EYES/DISPLAY Command window display of a EYES object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\teyes object from %s with fields:\n',edata.sessionname); 
fprintf('\tsessionname\n');
fprintf('\tchannel\n');
fprintf('\tnumTrials\n');
fprintf('\tholdaxis\n');
