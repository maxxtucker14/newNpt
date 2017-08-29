% function scanlines = ReadScanlinesFile(filename)
%
% Reads the scanlines information into a matlab struct
%
% filename:	string containing path and filename
%
% scanlines:		    struct containing fields
%                       trials =  vector of trial numbers that contain scanlines
%                       frames = n x 1 array of containing framenumbers 
%                       numScanlines = n x 1 array containing number of scanlines
%
% returns an empty matrix if no scanlines in any trial

function scanlines = ReadScanlinesFile(filename);

fid = fopen(filename,'r');

scanlines = [];
counter=0;
eof = 0;

while ~eof
    line = fgetl(fid);
    if line(1) == -1
        eof = 1;
    elseif length(line)>=7 & strcmp(line(1:7), 'Version')
    else
		phase = NaN;
        %read all scanlines info
        all = sscanf(line,'%*[^=]=%d');
        if size(all,1)==4
            trialNum = all(1, 1);
            Scanlines = all(4, 1);
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
            Scanlines = all(3, 1);
        else
            all = sscanf(line,'%d %d');
            if length(all)==2
                trialNum = 1;
                frameNum = all(1);
                Scanlines = all(2);
            else
                return
            end
        end
        
        counter = counter +1;
        scanlines.phase(counter) = phase;
        scanlines.trials(counter) = trialNum;
        scanlines.frames(counter) = frameNum;
        scanlines.numScanlines(counter) = Scanlines;
        
    end
end

fclose(fid);