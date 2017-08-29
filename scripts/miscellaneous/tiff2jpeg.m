function status = tiff2jpeg(varargin)
%status = tiff2jpeg(varargin)
%
%converts all tiff files in the current directory to jpegs.

Args = struct('Mode','lossy','Quality',75);
Args = getOptArgs(varargin,Args);

dirlist = nptDir('*.tif');
for ii=1:length(dirlist)
    dirlist(ii).name
    f = imread(dirlist(ii).name);
    [p,n,e] = fileparts(dirlist(ii).name);
    filename = [n '.jpg'];
    imwrite(f,filename,'Mode',Args.Mode,'Quality',Args.Quality);
end

status=1;