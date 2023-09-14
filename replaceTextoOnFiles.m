
% remplaza el "old" por "new" en todos los mFiles que encuentre en el rootFolder
% o en cualquier subfolder


rootFolder='/Users/felipe/Library/CloudStorage/Dropbox/';

new="myDir='/Users/felipe/Library/CloudStorage/Dropbox/';";
old="myDir='/Users/felipe/Dropbox/';";

% Buca todos los mFiles en carpetas no ocultas:
foldersToCheck={rootFolder};
while not(isempty(foldersToCheck))
    fprintf('\n\n=========================================================\n')
    fprintf('Bucenado en %s\n',foldersToCheck{1})
    fprintf('=========================================================\n\n')
    
    cd(foldersToCheck{1})
    files=dir;
    folder=files.folder;
    isDir=[files.isdir];
    files={files.name};
    folders=files(isDir&not(startsWith(files,'.')));
    files=files(endsWith(files,'.m'));

    if(not(isempty(folders)))
        fun=@(x)[folder,'/',x];
        
        foldersToCheck=[foldersToCheck,cellfun(fun,folders,'UniformOutput',false)];
    end

    % Abre el mFile
    % Revisa que exista el otro paths
    % Remplaza el path si es el caso
    for f=1:length(files)
        file=[folder,'/',files{f}];
        X = fileread(file) ;

        is=contains(X,old);

        if(is)
            fprintf('Archivo %s tiene old pattern, replacing it!\n',files{f})
            Y = strrep(X, old, new) ;
            fid2 = fopen(file,'wt') ;
            fwrite(fid2,Y) ;
            fclose (fid2) ;
        end

    end

    foldersToCheck=foldersToCheck(2:end);
end


