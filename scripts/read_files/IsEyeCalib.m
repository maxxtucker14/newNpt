function status = IsEyeCalib(filename)
%status = IsEyeCalib(filename)
%
%reads the init file and determines if the session is a Eye calibration
%session.

status=0;
if nargin==0
    fprintf('must provide filename\n');
    return
end

%open init file
fid=fopen(filename,'rt');
if fid==-1
    errordlg('The init file for this processed data could not be opened','ERROR')
    return
end

% loop through lines of .INI file, copying desired variables by section
eof=0;
while ~eof
    line=fgetl(fid);
    if line==-1
        eof=1;
    elseif strcmp(line,'[STIMULUS INFO]')
        % get type
        line = fgetl(fid);
        % textstring=strread(line,'%s','delimiter','=');
        textstring = sscanf(line,'%*[^=]=%[^\n]');
        if strcmp(textstring,'Eye Calibration')
            status = 1;
            return
        end
    end
end % while ~eof

fclose(fid);