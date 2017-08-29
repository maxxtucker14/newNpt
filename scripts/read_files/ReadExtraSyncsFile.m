% function extrasyncs = ReadExtraSyncsFile(extrasyncs_file);
%
% Reads the extrasync information into a matlab struct
%
% extrasyncs_file:	string containing path and filename
%
% extrasyncs:		struct containing fields
%                       trials =  vector of trial numbers that contain extra syncs
%                       numFrames = number of frames with extra syncs in this trial
%                       frames = n x 1 array of containing framenumbers 
%                       numExtraS = n x 1 array containing number of extra syncs per frame
%
% returns an empty matrix if no extrasyncs in any trial
%
%
% Original Author: Bruno Olshausen, 9/5/01
% Updated 5/12/03 to use sscanf; structure altered slightly

function extrasyncs = ReadExtraSyncsFile(extrasyncs_file);

fid = fopen(extrasyncs_file,'r');

extrasyncs = [];
counter=0;
eof = 0;
while ~eof
    line = fgetl(fid);
    if line(1) == -1
        eof = 1;
        if i == 0
            extrasyncs = [];
        end
	elseif length(line)>=7 & strcmp(line(1:7), 'Version')
    else
        phase = NaN;
        %read all extrasyncs info
        all = sscanf(line,'%*[^=]=%d');
        if size(all,1)==4
            trialNum = all(1, 1);
            syncs = all(4, 1);
            field2 = sscanf(line,'%*s %[^=]', 1);
            if strcmp(field2, 'Loop')       %Old Presenter
                frameNum = all(3, 1);
                loop = all(2, 1);
            elseif strcmp(field2, 'Frame')  %New Gabor and Grating
                frameNum = all(2, 1);
                phase = all(3, 1); 
            end
        elseif size(all,1)==3   %New Presenter 
            trialNum = all(1, 1);
            frameNum = all(2, 1);
            syncs = all(3, 1);
        else
            all = sscanf(line,'%d %d');
            if length(all)==2
                trialNum = 1;
                frameNum = all(1);
                syncs = all(2);
            else
                return
            end
        end
       
        counter = counter +1;
        extrasyncs.phase(counter) = phase;
        extrasyncs.trials(counter) = trialNum;
        extrasyncs.frames(counter) = frameNum;
        extrasyncs.numExtraS(counter) = syncs;
    end  
end

fclose(fid);
if isempty(extrasyncs)
    extrasyncs.phase = [];
    extrasyncs.trials= [];
    extrasyncs.frames = [];
    extrasyncs.numExtraS = [];
end