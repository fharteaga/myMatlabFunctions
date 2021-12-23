function beamer=addSlide(beamer,varargin)

beamer.n=beamer.n+1;
slide=struct;
slide.n=beamer.n;

figures={};
tables={};
items={};
text={};
code={};
codeSize='\normalsize';  % \normalsize \small \footnotesize \ \fontsize{8}{9}\selectf
title=sprintf('Frame %i',slide.n);



    

% Loading optional arguments
if(~isempty(varargin))
    % This checks a few things, also if there is struct called "opts"
    varargin=checkVarargin(varargin);
    while ~isempty(varargin)
        switch lower(varargin{1})
            case {'figures'}
                figures= varargin{2};
            case {'items'}
                items= varargin{2};
            case {'title'}
                title= varargin{2};
            case {'text'}
                text= varargin{2};
            case {'code'}
                code= varargin{2};
            case {'codesize'}
                codeSize= varargin{2};
            otherwise
                error(['Unexpected option: ' varargin{1}])
        end
        varargin(1:2) = [];
    end
end


slide.title=title;

figStructs=cell(size(figures));

for f=1:length(figures)
    beamer.nFig=beamer.nFig+1;
    fig=figures{f};
    name=sprintf('figures/fig%i.png',beamer.nFig);
    movefile(fig.fileAndPath,[beamer.dir,name]);
    fig.file=name;
    figStructs{f}=fig;
end


slide.fig=figStructs;
slide.items=items;
slide.text=text;

slide.code=code;
slide.codeSize=codeSize;

beamer.(sprintf('slide%i',slide.n))=slide;

end



