function paths=pathsStata(paths,dirToSave)


if(nargin==0)
    if(exist('pathsStataSaved.mat','file')==2)
        load('pathsStataSaved.mat','paths')
    else
        paths=struct;

        pcName=char(java.lang.System.getProperty('user.name'));
        if(strcmp(pcName,'felipe'))

            paths.stataProgramsPath='/Users/felipe/Dropbox/myMatlabFunctions/_stataFromMatlab/programs/';
            paths.stataTempfilesPath='/Users/felipe/Dropbox/myMatlabFunctions/_stataFromMatlab/_tempFiles/';
            paths.stataExecutablePath='/Applications/Stata/StataMP.app/Contents/MacOS/StataMP';

        elseif(strcmp(pcName,'ericsPcName'))


            paths.stataProgramsPath='';
            paths.stataTempfilesPath='';
            paths.stataExecutablePath='';

        else
            error('The name "%s" is not in the list.\n Add  "elseif(strcmp(pcName,''%s'')"  and the right paths',pcName,pcName)
        end
    end
else

    save([dirToSave,'pathsStataSaved.mat'],'paths')

end
%
if(not(exist(paths.stataExecutablePath,'file')==2))
    paths.stataExecutablePath='asdad';
    error('Stata executable is not in "%s". \n\n Please change "paths.stataExecutablePath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsStataSaved.mat")',paths.stataExecutablePath)
end
if(not(exist(paths.stataProgramsPath,'file')==7))
    error('Folder "%s" does not exist. \n\n Please change "paths.stataProgramsPath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsStataSaved.mat")',paths.stataProgramsPath)
end
if(not(exist(paths.stataTempfilesPath,'file')==7))
    error('Folder "%s" does not exist. \n\n Please change "paths.stataTempfilesPath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsStataSaved.mat")',paths.stataTempfilesPath)
end