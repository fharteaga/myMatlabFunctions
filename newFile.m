function newFile(~)

% Genera un mFile a partir de la plantilla
templateMFile='/Users/felipe/Dropbox/_plantillas/mFile.m';
if(nargin==1)
    edit(templateMFile)
else
    copyMFile='/Users/felipe/Dropbox/_plantillas/mFile_copy_borrar.m';
    copyfile(templateMFile,copyMFile)
    edit(copyMFile)
    %delete(copyMFile)
end