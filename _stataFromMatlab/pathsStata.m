function paths=pathsStata()

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


elseif(strcmp(pcName,'Andrés Arteaga'))

    paths.stataProgramsPath='C:\Users\arart\Downloads/myMatlabFunctions/_stataFromMatlab/programs/';
    paths.stataTempfilesPath='C:\Users\arart\Downloads/myMatlabFunctions/_stataFromMatlab/_tempFiles/';
    paths.stataExecutablePath='C:\Program Files\Stata16\StataMP-64.exe';


else
    error('The name "%s" is not in the list.\n Add  "elseif(strcmp(pcName,''%s'')"  and the right paths',pcName,pcName)
end

%
if(not(exist(paths.stataExecutablePath,'file')==2))
    error('Stata executable is not in "%s". \n\n Please change "paths.stataExecutablePath" on pathsStata.m',paths.stataExecutablePath)
end
if(not(exist(paths.stataProgramsPath,'file')==7))
    error('Folder "%s" does not exist. \n\n Please change "paths.stataProgramsPath" on pathsStata.m',paths.stataProgramsPath)
end
if(not(exist(paths.stataTempfilesPath,'file')==7))
    error('Folder "%s" does not exist. \n\n Please change "paths.stataTempfilesPath" on pathsStata.m',paths.stataTempfilesPath)
end