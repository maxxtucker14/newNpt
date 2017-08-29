function iniInfo = ReadIniFileWrapper(filename)
%init_info = ReadIniFileWrapper(filename)
%
% This function attempts to read an ini file in multiple ways and returns an
% init_info structure containing all relevant info from the file.
% 07/21/06 Added a flag for the new presenter ini files

%1st try new format 
try
    [iniInfo, status] = ReadRevCorrIni(filename);
catch
    [iniInfo, status] = ReadRevCorrIniJonathan(filename);
    if strcmp(iniInfo.Date,'UEI') % Flag for new INI file reader, new fields using the new UEI DAQ
        [iniInfo, status] = ReadUEIJonathanIni(filename);
        iniInfo.DAQ = 'UEI';
        iniInfo.frames_displayed = iniInfo.total_number_frames_displayed;
    elseif iniInfo.Date(3) < 2004 %%% Since we have some really old INI files.
        date = iniInfo.Date; %%% This is so that date formats are consistent
        [iniInfo] = ReadOldRevCorrIni(filename);
        iniInfo.Date = date;
        iniInfo.still_images = 0; %% This is a flag for monkey data needed so it won't crash
        iniInfo.DAQ = 'NI';
    else
        iniInfo.still_images = 0; %% This is a flag for monkey data needed so it won't crash
        iniInfo.DAQ = 'NI';
    end       
end

if status
    return
end

%try older format
%iniInfo = read_init_info(filename);





