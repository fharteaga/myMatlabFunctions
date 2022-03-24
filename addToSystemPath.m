function addToSystemPath(newPathOrProgram,varargin)

first=true;

pyMini='/opt/anaconda3/bin/python';
pyMacbook='/usr/local/anaconda3/bin/python';
if(exist(pyMini,'file')>0)
    pythonPath=pyMini(1:length(pyMini)-7);
else
    pythonPath=pyMacbook(1:length(pyMacbook)-7);
end


latexPath='/Library/TeX/texbin/';
localBinPath='/usr/local/bin/';

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'first'}
                first= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

isPath=(newPathOrProgram(1)=='/'&&newPathOrProgram(end)=='/');

if(isPath)
    newPath=newPathOrProgram;

else

    switch lower(newPathOrProgram)
        case 'python'
            newPath=pythonPath;
        case 'local'
            newPath=localBinPath;
        case 'stata'
            newPath=stataPath;
        otherwise
            error('Sorry, there is a problem')
    end
end


path0 = getenv('PATH');
if(not(contains(path0,newPath)))
    
    if(first)
        path1 = [newPath,':',path0];
    else
        path1 = [path0,':',newPath];
    end
    setenv('PATH', path1)
end