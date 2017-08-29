function status = CreateIspikesFiles
%this function loops over all .cut files and creates and saves the ispikes

status=0;
dirlist = nptDir('*.cut');
for ii=1:length(dirlist)
    [path,name,ext] = nptFileParts(dirlist(ii).name);
    group=name(length(name)-12:length(name)-9);
    fprintf('Creating ispikes for Group %s\n',group)
    obj = ispikes(group,1);
    save([name(1:length(name)-9) '_ispike'],'obj')
end
status=1;