function openSystem(fileOrDir)

tipoArchivo=exist(fileOrDir,'file');

if(ismember(tipoArchivo,[2 7])) % file or folder

    system(sprintf('open "%s"',fileOrDir))
else
    % Trata de probar si es un archivo matlab
    if(not(strcmp(fileOrDir(end-3:end),'.mat')))

        fileOrDir=[fileOrDir,'.mat'];
        openSystem(fileOrDir)
    end

end