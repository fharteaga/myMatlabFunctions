function output=compileLatex(code,varargin)

createTex=true;
addPreCode=true;

paths=pathsLatex();
latexPreTexPath=paths.latexPreTexPath;
latexTempfilesPath=paths.latexTempfilesPath;
latexExecutablePath=paths.latexExecutablePath;


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
                latexTempfilesPath = varargin{2};
            case {'texfile'}
                texFile = varargin{2};
            case {'createtex'}
                createTex = varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end

ftex=[latexTempfilesPath,texFile,'.tex'];

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

fpdf=[latexTempfilesPath,texFile,'.pdf'];delete(fpdf);

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
system([sprintf('cd %s;',latexTempfilesPath),...
    sprintf('"%s" -halt-on-error -output-directory="%s" "%s"',latexExecutablePath,latexTempfilesPath,ftex)]); %


if(isfile(fpdf))
    %movefile('tempTexFile.pdf',fpdf)
    open(fpdf)
end
warning('off','MATLAB:DELETE:FileNotFound')
delete([latexTempfilesPath,texFile,'.aux'])
%delete([latexTempfilesPath,texFile,'.log'])
delete([latexTempfilesPath,texFile,'.out'])
warning('on','MATLAB:DELETE:FileNotFound')


fprintf('Done!\n\n');

if(nargin>0)
   output=struct;
   output.texFileWithDir=ftex;
   output.pdfFileWithDir=fpdf;
end

