function c = concatenate (a,b,varargin)
%CONCATENATE Concatenate two row vectors
%   C = CONCATENATE(A,B) concatenates two row vectors 
%   (i.e. C = [A; B]). The shorter vector is padded with NaNs.
%   Empty vectors are concatenated as well, i.e. if A and B 
%   are both of size [0 0], C will be of size [2 0].
%
%   C = CONCATENATE(A,B,VALUE) pads the shorter vector with
%   VALUE instead. 
%   e.g. C = CONCATENATE(A,B,0) pads the shorter vector with 0's.
%
%   C = CONCATENATE(A,B,'Columnwise') concatenates two column vectors.
%
%   C = CONCATENATE(...,'DiscardEmptyA') returns B if A is 
%   of size [0 0]. If B is also of size [0 0], an empty matrix
%   of size [1 0] will be returned.  
%
%   Dependencies: None.

Args = struct('Columnwise',0,'DiscardEmptyA',0);
Args.flags = {'Columnwise','DiscardEmptyA'};
Args = getOptArgs(varargin,Args);
if(~isempty(Args.NumericArguments))
    pad = Args.NumericArguments{1};
else
    pad = NaN;
end

% get size of a and b
[arows acols] = size(a);
[brows bcols] = size(b);
% check if a or b are 0 by 0
if(sum([arows acols])==0)
    a0 = 1;
else
    a0 = 0;
end
if(sum([brows bcols])==0)
    b0 = 1;
else
    b0 = 0;
end

if(a0)
    % a is 0 by 0
    if(Args.DiscardEmptyA)
        if(b0)
            % both a and b are 0 by 0 but we are going to disregard a
            % so return matrix that is 1 by 0 or 0 by 1
            if(Args.Columnwise)
                c = repmat(pad,0,1);
            else
                c = repmat(pad,1,0);
            end
        else % if(b0)
            % a is 0 by 0 but b is not so just return b
            c = b;
        end % if(b0)
    else % if(Args.DiscardEmptyA)
        if(b0)
            % both a and b are 0 by 0 so return matrix that is 2 by 0 or 0
            % by 2
            if(Args.Columnwise)
                c = repmat(pad,0,2);
            else
                c = repmat(pad,2,0);
            end
        else % if(b0)
            % a is 0 by 0 but b is not, so resize a to b and concatenate
            if(Args.Columnwise)
                c = [repmat(pad,brows,1) b];
            else
                c = [repmat(pad,1,bcols); b];
            end
        end % if(b0)
    end % if(Args.DiscardEmptyA)
else % if(a0)
    % a is not 0 by 0
    if(b0)
        % a is not 0 by 0 but b is, so resize b to a and concatenate
        if(Args.Columnwise)
            c = [a repmat(pad,arows,1)];
        else
            c = [a; repmat(pad,1,acols)];
        end
    else % if(b0)
        % both a and b are not 0 by 0 so do normal concatenation which may
        % include empty matrices that have one non-zero dimension
        if(Args.Columnwise)
            if(arows>brows)
                % pad b before concatenating
                c = [a [b; repmat(pad,arows-brows,bcols)]];
            elseif(brows>arows)
                % pad a before concatenating
                c = [[a; repmat(pad,brows-arows,acols)] b];
            else
                % a and b are the same size so just concatenate
                c = [a b];
            end
        else % if(Args.Columnwise)
            if(acols>bcols)
                % pad b before concatenating
                c = [a; [b repmat(pad,brows,acols-bcols)]];
            elseif(bcols>acols)
                % pad a before concatenating
                c = [[a repmat(pad,arows,bcols-acols)]; b];
            else
                % a and b are the same size so just concatenate
                c = [a; b];
            end
        end % if(Args.Columnwise)
    end % if(b0)
end % if(a0)
