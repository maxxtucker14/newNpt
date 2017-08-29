function r = zerolog(h)
%zerolog Takes the log of non-zero entries to avoid log of zero warning
%   R = zerolog(H) takes the log of only the non-zero entries of H to avoid
%   the log of zero warning.

% get indices which are not zero
h1 = find(h);
% take the log of non-zero entries
lh = log(h(h1));
% create matrix of nan's to match h
r = repmat(nan,size(h));
% replace entries in lall with lh
r(h1) = lh;
