function paths=pathsLatex(paths,dirToSave)



if(nargin==0)
    if(exist('pathsLatexSaved.mat','file')==2)
        load('pathsLatexSaved.mat','paths')
    else
        paths=struct;

        pcName=char(java.lang.System.getProperty('user.name'));
        if(strcmp(pcName,'felipe'))

            paths.latexPreTexPath='/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/preTex.txt';
            paths.latexTempfilesPath='/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/_tempFiles/';
            paths.latexExecutablePath='/Library/TeX/texbin/pdflatex';

        elseif(strcmp(pcName,'ericsPcName'))


        else
            error('The name "%s" is not in the list.\n Add  "elseif(strcmp(pcName,''%s'')"  and the right paths',pcName,pcName)
        end

    end
else
   
    save([dirToSave,'pathsLatexSaved.mat'],'paths')

end

%
if(not(exist(paths.latexPreTexPath,'file')==2))
    error('preTex file is not in "%s". \n\n Please change "paths.latexPreTexPath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsLatexSaved.mat")',paths.latexPreTexPath)
end
if(not(exist(paths.latexTempfilesPath,'file')==7))
    error('Folder "%s" does not exist. \n\n Please change "paths.latexTempfilesPath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsLatexSaved.mat")',paths.latexTempfilesPath)
end
if(not(exist(paths.latexExecutablePath,'file')==2))
    error('Executable "%s" does not exist. \n\n Please change "paths.latexExecutablePath" definition \n(Hint: if changing path does not work, find and erase the file  "pathsLatexSaved.mat")',paths.latexExecutablePath)
end