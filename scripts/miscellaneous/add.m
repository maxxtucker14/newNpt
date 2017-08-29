function c = add (a,b)
%function c = add (a,b)
%
%this function adds two vectors of unequal length
%the shorter vector is padded with zeros
%c = a + b

if min(size(a))>1 | min(size(b))>1
   error('error both inputs to plus must be vectors')
end

%find length of vectors and orientation
if ~isempty(a)
   [alen,aind] = max(size(a));
else
   alen=0;
   aind=2;
end
if ~isempty(b)
   [blen,bind] = max(size(b));
else
   blen=0;
   bind=2;
end


%change to row vectors
if aind == 1
   a=a';
end
if bind ==1
   b=b';
end

%pad with zeros
if alen<blen
   a = [a zeros(1,blen-alen)];
else
   b = [b zeros(1,alen-blen)];
end
c = a+b;

if aind==1 & bind==1
   c=c';
end
