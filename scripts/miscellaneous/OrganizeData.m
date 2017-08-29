function OrganizeData

% OrganizeData	reorganizes old data hierarchy.
%   Must be run in the data directory
%   and loops over all days.
%
%   The function will take the pre-existing data hierarchy
%   of /data/day/session and reorganize it into /data/day/site/session
%
%   Example. Recording Day or Experiment named A1 with the sessions
%   a101 - a107. The first four were from one recording site
%   and the later three are from the second recording site. 
%   The data should be organized in a /data/a1 directory with the sub-
%   directories a101 - a107. This function will reorganized the data into
%   /data/a1/site01/session01 for a101 session.  For monkeys, a directory
%   structure such as /animalname/day/site/session is equivalent.
%
%   The recording site information should be contained in a text file
%   name recording_site_information.txt, which contains the experiments
%   name, the total number of recording sites, the total number of sessions
%   and then the site and session values.  One blank line has to be left
%   between each day.  This file should be put in the data or animalname
%   directory. 
%
%   
%   Experiment a1
%   Sites 2
%   Sessions 7
%   Site    Session
%   1       01
%   1       02
%   1       03
%   1       04
%   2       05
%   2       06
%   2       07
%
%   Experiment b1
%   Sites 2
%   Sessions 7
%   Site    Session
%   1       01
%   1       02
%   1       03
%   1       04
%   2       05
%   2       06
%   2       07
%   Currently it is setup to be run one time, is it's run over a previously
%   create data hierarchy, you will get an error in copying the files


%%%%%%%%%%% READ SITE INFORMATION FILE %%%%%%%%%%%%%%%%%
dirlist = nptDir('recording_site_information.txt','CaseInsensitive');
dataDir=pwd;
if isempty(dirlist.name)
    errordlg('Recording Site Information file does not exist','ERROR')
    return
end    
%open init file
fid=fopen(dirlist.name,'rt');
if fid==-1
    errordlg('Recording Site Information file could not be opened','ERROR')
    return
end
% loop through lines of .INI file, copying desired variables by section
eof=0;
while ~eof
    eod=0;
    site_info=[];
    while ~eod
        line=fgetl(fid);            
        if isempty(line)       
            eod=1;        %end of day
        elseif line(1)==-1  
            eof=1; eod=1;       
        else
            % get first word
            word1 = sscanf(line,'%s',1);
            switch word1
                case 'Experiment'
                    site_info.experiment_name = sscanf(line,'%*s %s',1);
                case 'Sites'
                    site_info.number_of_sites = sscanf(line,'%*s %i',1);
                case 'Sessions'
                    site_info.number_of_sessions = sscanf(line,'%*s %i',1);            
                case 'Site'
                    for j=1:site_info.number_of_sessions
                        line = fgetl(fid);
                        site_info.site(j) = sscanf(line,'%i',1);        		
                        site_info.session(j) = sscanf(line,'%*i %i',1);
                    end
            end 
        end
    end %while day   
    
    
    %%%%%%%% Create the site and session directories and move the data %%%%%
    
    dayDir = [dataDir filesep site_info.experiment_name];
    cd(dayDir)
    if ispresent('01','dir')
        monkey=1;
    else
        monkey=0;
    end
    site_numbers = unique(site_info.site); 
    for s = 1:site_info.number_of_sites
        %%%% Check and then Make the Site Directory and move into it %%%%    
        eval(['mkdir site' sprintf('%02d',site_numbers(s))]);
        siteDir = [dayDir filesep 'site' sprintf('%02d',site_numbers(s))];
        cd(siteDir); 
        session_numbers = site_info.session(find(site_info.site == site_numbers(s)));   
        for ss = 1:length(session_numbers)
            %%% Create the Session Directories %%%%%%%
            eval(['mkdir session' sprintf('%02d',session_numbers(ss))])
            sessionDir = [pwd filesep 'session' sprintf('%02d',session_numbers(ss))];
            %%%% Copy all the files over to the new directory %%%%
            if ~monkey
                source = [dataDir filesep site_info.experiment_name filesep site_info.experiment_name sprintf('%02d',session_numbers(ss))];
            else
                source = [dataDir filesep site_info.experiment_name filesep sprintf('%02d',session_numbers(ss))];
            end
            
            [s,m,mid] = copyfile(source,sessionDir);
            if s == 0
                errordlg(['Error in Copying Files: ' m],'ERROR')
                return
            end
            cd(siteDir)    %return to experiment dir
            [s,m,mid]= rmdir(source,'s');
            if s == 0
                errordlg(['Error Deleting Files: ' m],'ERROR')
                return
            end
            fprintf(['Done With ' site_info.experiment_name ' Session ' num2str(session_numbers(ss)) '\n'])
        end % Number of Sessions 
        cd ..
    end % Number of Sites
    cd ..
end %while file