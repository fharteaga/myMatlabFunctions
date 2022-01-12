function fileBasura=dirBasura(file)

dirBasura='/Users/felipe/Dropbox/myMatlabFunctions/_basura/';

printLinkToFolder=true;
if(not(exist(dirBasura,'dir')==7))
    dirBasura=tempdir;
    printLinkToFolder=false;
end

if(nargin==1)
    fileBasura=[dirBasura,file];
else
    fileBasura=[dirBasura,'borrar'];
end


if(printLinkToFolder)
    fprintf('<a href="matlab: unix(''open %s'');">Open basura folder</a>\n',dirBasura);
end

