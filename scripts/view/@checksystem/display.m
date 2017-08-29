function display(w)
%CHECKSYSTEM/DISPLAY Displays fields of an CHECKSYSTEM object
%
%   Dependencies: None.

fprintf('\n%s =\n',inputname(1));
fprintf('\t%s object with fields:\n',class(w));
fprintf('\t\tsessions\n');
fprintf('\t\tpath()\n');
