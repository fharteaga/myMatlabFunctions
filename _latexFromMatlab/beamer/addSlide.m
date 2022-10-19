function beamer=addSlide(beamer,varargin)


% To add a button define the label paramater of the slide, and add in the 
% text one of the folowing options:
%   \hyperlink{label}{\beamerbutton{text on the button}}
%   \hyperlink{label}{\beamergotobutton{text on the button}}
%   \hyperlink{label}{\beamerskipbutton{text on the button}}
%   \hyperlink{label}{\beamerreturnbutton{text on the button}}

beamer.n=beamer.n+1;
slide=struct;
slide.n=beamer.n;

figures={};
tables={};
items={}; % Second column (optional) defines indending of the list 
text={};
code={};
codeSize='\normalsize';  % \normalsize \small \footnotesize \ \fontsize{8}{9}\selectf
title=sprintf('Frame %i',slide.n);
label='';

moveOrCopyFigureFile='copy';

objectsOrder='fitc';% figures, items, text, code
objectsOrderInput='';% figures, items, text, code
    

% Loading optional arguments
if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'figures','figure'}
                figures= varargin{2};
            case {'items'}
                items= varargin{2};
            case {'title'}
                title= varargin{2};
            case {'text'}
                text= varargin{2};
            case {'code'}
                code= varargin{2};
            case {'label'}
                label= varargin{2};
            case {'codesize'}
                codeSize= varargin{2};
            case {'objectsorder'}
                objectsOrderInput= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end

if(not(isempty(objectsOrderInput)))
    assert(all(ismember(objectsOrderInput,objectsOrder)))
    objectsOrderInput=unique(objectsOrderInput,"stable");
    objectsOrder=[objectsOrderInput,objectsOrder(not(ismember(objectsOrder,objectsOrderInput)))];
end



slide.title=title;
if(not(isempty(label)))
    slide.label=label;
end


if(isstruct(figures))
figures={figures};
end

figStructs=cell(size(figures));

for f=1:length(figures)
    beamer.nFig=beamer.nFig+1;
    fig=figures{f};
    
    % Check that there is no another file with the same name:

    files=dir(beamer.dirFigures);
    files={files.name};
    fileName=fig.file;
    % Avoid spaces (latex print the words after spaces)
    fileName=fileName(regexp(fileName,'[0-9A-Za-z-_.]'));
    % Avoid more than one dot
    assert(ischar(fileName))
    dots=fileName=='.';
    if(sum(dots)>1)
        posDots=find(dots);
        fileName(posDots(1:end-1))='';
    end
    
    counter=0;
    while(ismember(fileName,files)&&counter<100)
        counter=counter+1;
        extensionPos=find(fig.file=='.',1,'last');
        fileName=sprintf('%s_%i.%s',fig.file(1:extensionPos-1),counter,fig.file(extensionPos+1:end));
     end
   assert(counter<100)
       

    if(strcmp(moveOrCopyFigureFile,'move'))
        movefile(fig.fileAndPath,[beamer.dirFigures,fileName]);
    elseif(strcmp(moveOrCopyFigureFile,'copy'))
        copyfile(fig.fileAndPath,[beamer.dirFigures,fileName]);
    else
        error('acá')
    end

    fig.file=[extractAfter(beamer.dirFigures, beamer.dir),fileName];
    figStructs{f}=fig;
end

% Check if second columns defines the indentig of the list:
if(not(isempty(items)))
    if(size(items,2)==1)
        items=[items,repmat({1},size(items,1),1)];
    else
        assert(size(items,2)==2)
    end
end

slide.objectsOrder=objectsOrder;
slide.fig=figStructs;
slide.items=items;
slide.text=text;
slide.code=code;
slide.codeSize=codeSize;

beamer.(sprintf('slide%i',slide.n))=slide;

end



