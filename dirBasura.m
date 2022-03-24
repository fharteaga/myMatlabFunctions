function fileBasura=dirBasura(fileName,varargin)

dirBasura_='/Users/felipe/Dropbox/myMatlabFunctions/_basura/';
printLinkToFolder=true;

if(~isempty(varargin))
    
    % This checks a few things, including if there is a struct called "opts"
    varargin=checkVarargin(varargin);
    
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'printlinktofolder','pl'}
                printLinkToFolder= varargin{2};
                
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


if(not(exist(dirBasura_,'dir')==7))
    dirBasura_=tempdir;
    printLinkToFolder=false;
end

if(nargin>=1)
    fileBasura=[dirBasura_,fileName];
else
    fileBasura=[dirBasura_,'borrar'];
end


if(printLinkToFolder)
    fprintf('<a href="matlab: unix(''open %s'');">Open basura folder</a>\n',dirBasura_);
end

