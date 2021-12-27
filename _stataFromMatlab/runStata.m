function out=runStata(code,data,varargin)


openLogWhenDone=false;
openLogIfError=false;
getLog=false;
getFinalDataset=false;
addPreCode=true;

assert(istable(data))
assert(ischar(code))

paths=pathsStata();

tempDir=paths.stataTempfilesPath;
filePreCodePath=[paths.stataProgramsPath,'preCode.do'];
stataExecutablePath=paths.stataExecutablePath;


if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'openlog'}
                openLogWhenDone = varargin{2};
            case {'getlog','readlog'}
                getLog = varargin{2};
            case {'getfinaldataset'}
                getFinalDataset = varargin{2};
            case {'addprecode'}
                addPreCode = varargin{2};
            otherwise
                error(['Unexpected option: ',varargin{1}])
        end
        varargin(1:2) = [];
    end
end
assert(not(getFinalDataset&&nargout==0),'Si vay a rescatar el dateset, ústalo pa algo!')


warning('off','MATLAB:DELETE:FileNotFound')
fcode=[tempDir,'tempDoFile.do'];delete(fcode);
flog=[tempDir,'tempDoFile.log'];delete(flog);
fdataIn=[tempDir,'tempDataIn.csv'];delete(fdataIn);
fdataOut=[tempDir,'tempDataOut.csv'];delete(fdataOut);
warning('on','MATLAB:DELETE:FileNotFound')
% Create doFile to erase


% Add program
if(addPreCode)
    preCode=fileread(filePreCodePath);
else
    preCode='';
end

% Add code to import data:

if(height(data)>0)
    numeric=varfun(@(v)isnumeric(v)|islogical(v),data,'OutputFormat','uniform');
    string=varfun(@(v)iscellstr(v)|iscategorical(v),data,'OutputFormat','uniform'); %#ok<ISCLSTR>
    assert(all(numeric|string))
    classVars=sprintf('numericcols(%s) stringcols(%s)',sprintf('% i',find(numeric)),sprintf('% i',find(string)));
    importDataCode=sprintf('import delimited using "%s",delimiter(",") clear varnames(1)  case(preserve)  %s \n',fdataIn,classVars);
    
    %importDataCode=sprintf('import delimited using "%s",delimiter(",") clear varnames(1)  case(preserve) asdouble \n destring *, force replace\n',fdataIn);
else
    importDataCode='';
end


if(getFinalDataset)
    % Add to the code to export de data (to be open in matlab)
    exportDataCode=sprintf('\nexport delimited using "%s",delimiter(",") replace',fdataOut);
else
    exportDataCode='';
end


code=sprintf('%s\n%s%s%s%s','set linesize 120',preCode,importDataCode,code,exportDataCode);

fileID = fopen(fcode,'w');
fprintf(fileID,'%s',code);
fclose(fileID);
writetable(data,fdataIn,'Delimiter',',')

%% Run stata
% stataPath='/Applications/Stata/StataMP.app/Contents/MacOS/StataMP';
% path0 = getenv('PATH');
% if(not(contains(path0,stataPath)))
%     path1 = [path0 ':' stataPath];
%     setenv('PATH', path1)
% end


fprintf('STATA is running... ');
system(['"',stataExecutablePath,'" -e -q do ',fcode]); % -q	suppress initialization messages
% move log:
movefile('tempDoFile.log',flog)
% Check log


fid = fopen(flog,'r');     %# Open the file as a binary
offset = 1;                      %# Offset from the end of file
fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
newChar = fread(fid,1,'*char');  %# Read one character
while (~strcmp(newChar,char(newline))) || (offset == 1)
    offset = offset+1;
    fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
    newChar = fread(fid,1,'*char');  %# Read one character
end
lastLine=fgetl(fid);

if(lastLine(1)=='r')
    
    % Busca el error:
    offset = 38;                      %# Offset from the end of file
    fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
    newChar = fread(fid,1,'*char');  %# Read one character
    while (~strcmp(newChar,char(newline)))
        offset = offset+1;
        fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
        newChar = fread(fid,1,'*char');  %# Read one character
    end
    errorLine=fgetl(fid);
    
    fclose(fid);  %# Close the file
    if(openLogIfError)
        uiopen(flog,1)
    end
    error('Error en stata (<a href="matlab:openStataLog;">open log</a>): \n\n\t%s (%s)   ',erase(errorLine,newline),erase(lastLine,newline))
    
    
else
    fclose(fid);  %# Close the file
end
if(openLogWhenDone)
    uiopen(flog,1)
end

fprintf('Done!: %s (<a href="matlab:openStataLog;">open log</a>)\n\n',erase(lastLine,newline));

if(nargout==1)
    out=struct;
end


% Open final dataset
if(getFinalDataset)
    out.dataOutput=readtable(fdataOut);
end
if(getLog)
    out.log=fileread(flog);
end


