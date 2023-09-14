function output=compileLatex(code,varargin)

createTex=true;
addPreCode=true;

paths=pathsLatex();
latexPreTexPath=paths.latexPreTexPath;
latexFilesPath=paths.latexTempfilesPath;
latexExecutablePath=paths.latexExecutablePath;
copyPDFTo='';

texFile='tempTexFile';

assert(ischar(code)||isstring(code))

if(~isempty(varargin))
    % Loading optional arguments
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'addprecode'}
                addPreCode = varargin{2};
            case {'dirtex'}
                latexFilesPath = varargin{2};
            case {'texfile'}
                texFile = varargin{2};
            case {'createtex'}
                createTex = varargin{2};
            case {'copypdfto'}
                copyPDFTo= varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end

ftex=[latexFilesPath,texFile,'.tex'];

if(createTex)
    warning('off','MATLAB:DELETE:FileNotFound')
    delete(ftex);
    warning('on','MATLAB:DELETE:FileNotFound')
    
    % Create doFile to erase
    
    
    % Add program
    if(addPreCode)
        preCode=fileread(latexPreTexPath);
        endCode=sprintf('\n\\end{document}');
    else
        preCode='';
        endCode='';
    end
    
    
    
    code=[preCode,code,endCode];
    
    fileID = fopen(ftex,'w');
    fprintf(fileID,'%s',code);
    fclose(fileID);
    
end

fpdf=[latexFilesPath,texFile,'.pdf'];delete(fpdf);

%% Run PDFLatex
%
% latexPath='/Library/TeX/texbin/';
% path0 = getenv('PATH');
% if(not(contains(path0,latexPath)))
%     path1 = [path0 ':' latexPath];
%     setenv('PATH', path1)
% end


fprintf('LATEX is running... ');
% More opts with: !pdftex --help

% Need to change "cd" because if not it can't read figures in subfolders
system([sprintf('cd %s;',latexFilesPath),...
    sprintf('"%s" -halt-on-error -output-directory="%s" "%s"',latexExecutablePath,latexFilesPath,ftex)]); %


if(isfile(fpdf))
    %movefile('tempTexFile.pdf',fpdf)
    open(fpdf)
end
if(not(isempty(copyPDFTo)))
    copyfile(fpdf,copyPDFTo)
    
end
warning('off','MATLAB:DELETE:FileNotFound')
delete([latexFilesPath,texFile,'.aux'])
%delete([latexTempfilesPath,texFile,'.log'])
delete([latexFilesPath,texFile,'.out'])
warning('on','MATLAB:DELETE:FileNotFound')


fprintf('Done!\n\n');

if(nargin>0)
   output=struct;
   output.texFileWithDir=ftex;
   output.pdfFileWithDir=fpdf;
end

