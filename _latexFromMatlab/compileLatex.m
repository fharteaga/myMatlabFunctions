function output=compileLatex(code,varargin)

createTex=true;
addPreCode=true;
dirTex='/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/_tempFiles/';
dirPdflatex='/Library/TeX/texbin/pdflatex';
texFile='tempTexFile';

assert(ischar(code))

if(~isempty(varargin))
    % Loading optional arguments
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'addprecode'}
                addPreCode = varargin{2};
            case {'dirtex'}
                dirTex = varargin{2};
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

ftex=[dirTex,texFile,'.tex'];

if(createTex)
    warning('off','MATLAB:DELETE:FileNotFound')
    delete(ftex);
    warning('on','MATLAB:DELETE:FileNotFound')
    
    % Create doFile to erase
    
    
    % Add program
    if(addPreCode)
        preCode=fileread('/Users/felipe/Dropbox/myMatlabFunctions/_latexFromMatlab/preTex.txt');
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

fpdf=[dirTex,texFile,'.pdf'];delete(fpdf);

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
system(sprintf('%s -pdf -halt-on-error -output-directory=%s %s',dirPdflatex,dirTex,ftex)); %


if(isfile(fpdf))
    %movefile('tempTexFile.pdf',fpdf)
    open(fpdf)
end
warning('off','MATLAB:DELETE:FileNotFound')
delete([dirTex,texFile,'.aux'])
delete([dirTex,texFile,'.log'])
delete([dirTex,texFile,'.out'])
warning('on','MATLAB:DELETE:FileNotFound')


fprintf('Done!\n\n');

if(nargin>0)
   output=struct;
   output.texFileWithDir=ftex;
   output.pdfFileWithDir=fpdf;
end

