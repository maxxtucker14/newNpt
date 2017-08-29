function display(sdata)
%STREAMER/DISPLAY Command window display of a STREAMER object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\tstreamer object from %s with fields:\n',sdata.sessionname); 
fprintf('\tsessionname\n');
fprintf('\tchannel\n');
fprintf('\tnumTrials\n');
fprintf('\tholdaxis\n');
