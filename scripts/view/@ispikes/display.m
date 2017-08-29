function display(sp)
%ISPIKES/DISPLAY Command window display of an ISPIKES object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\nispikes object from %s\n',sp.data.sessionname); 

% fprintf('\nispikes object from %s with fields:\n',sp.data.sessionname); 
% fprintf('\tsessionname\n');
% fprintf('\tgroupname\n');
% fprintf('\tduration\n');
% fprintf('\tmin_duration\n');
% fprintf('\tsignal\n');
% fprintf('\tmeans\n');
% fprintf('\tthresholds\n');
% fprintf('\ttrial\n');
% fprintf('\tnumTrials\n');
% fprintf('\tchannel\n');
% fprintf('\tnumClusters\n');
   