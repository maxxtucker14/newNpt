function b = subsref(obj,index)
%WAVEFORMS/SUBSREF Indexing function for WAVEFORMS object.
%
%   Dependencies: None.

unknown = 0;
myerror = 0;

switch index(1).type
    case '.'
        switch index(1).subs
            case 'numWaves'
                b = obj.nptdata.number;
            case 'wave'
                b=obj.data(index(2).subs{:});
            case 'time'
                b=obj.time(index(2).subs{:});
            otherwise
                myerror = 1;
        end
    otherwise
        unknown = 1;	
end

if unknown == 1
    b = subsref(obj.nptdata,index);
elseif myerror == 1
    error('Invalid field name');
end
