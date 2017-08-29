% function extrasyncs=read_extrasyncs_struct(extrasyncs_file)
%
% Reads the extrasync information into a matlab struct
%
% extrasyncs_file:	string containing path and filename
%
% extrasyncs:		struct containing fields
%                       trial = trial number
%                       n = number of frames with extra syncs in this trial
%                       frame = n x 1 array of containing framenumbers 
%                       num_extra = n x 1 array containing number of extra syncs per frame
%
% returns -1 if no extrasyncs in any trial
%
% See also:         read_extrasyncs

%
% Author: Bruno Olshausen, 9/5/01
%

function extrasyncs=read_extrasyncs_struct(extrasyncs_file)

fid=fopen(extrasyncs_file,'r');

i=0;
eof=0;
while ~eof
    
    line=fgetl(fid);
    
    if line(1)==-1
        eof=1;
        if i==0
            extrasyncs=-1;
        end
    else
        %read all extrasyncs info
        [trial_num loop frame_num syncs]=strread(line, 'Trial=%u Loop=%u Frame=%u Syncs=%d');
        [trial_num loop frame_num syncs]=sscanf(line, 'Trial=%d Loop=%d Frame=%d Syncs=%d');

        if exist('extrasyncs','var')
            if extrasyncs(i).trial==trial_num
                extrasyncs(i).n=extrasyncs(i).n+1;
                extrasyncs(i).frame=[extrasyncs(i).frame; frame_num];
                extrasyncs(i).num_extra=[extrasyncs(i).num_extra; syncs];
            else
                i=i+1;
                extrasyncs(i).trial=trial_num;
                extrasyncs(i).n=1;
                extrasyncs(i).frame=frame_num;
                extrasyncs(i).num_extra=syncs;
            end
        else
            i=i+1;
            extrasyncs(i).trial=trial_num;
            extrasyncs(i).n=1;
            extrasyncs(i).frame=frame_num;
            extrasyncs(i).num_extra=syncs;
        end
        
    end
    
end
