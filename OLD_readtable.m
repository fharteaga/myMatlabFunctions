function tabla=readtable(file,varargin)

% This function checks that the file opened with buil-in function
% "readtable()" has more than 0 rows. This is because of the dropbox app is
% not downloading files on-the-fly, so matlab thinks they are empty files.



folderWhereFunctionNameLives='/Applications/MATLAB_R2023a.app/toolbox/matlab/iofun/';
currentFolder = pwd; % Save original folder
cd(folderWhereFunctionNameLives); % Change to the folder of the functionName that you WANT to run lives.
% Now it will no longer see the first functionName, unless it's in the current folder.
% 
% if(nargin==1)
% varargin={};
% end
% asd

tabla=readtable(file,varargin{:});
if(height(tabla)==0)
    fprintf('Corriendo el readtable que chequea que el archivo no está online only (dropbox)\n\n')
    openSystem(file);

    counter=0;
    while(height(tabla)==0)
        pause(3)
        tabla=readtable(file,varargin{:});
        counter=counter+1;
        if(counter==100)
            break
        end
    end
end

cd(currentFolder);




